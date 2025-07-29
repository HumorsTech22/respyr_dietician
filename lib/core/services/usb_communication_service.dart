import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbCommunicationService {
  static final UsbCommunicationService _instance =
      UsbCommunicationService._internal();

  factory UsbCommunicationService() => _instance;

  UsbCommunicationService._internal() {
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      if (event.event == UsbEvent.ACTION_USB_ATTACHED) {
        _autoConnect();
      } else if (event.event == UsbEvent.ACTION_USB_DETACHED) {
        _disconnect();
      }
    });
  }

  UsbPort? _port;
  UsbDevice? device;
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  final StreamController<String> _dataController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  bool _isConnected = false;

  Stream<String> get dataStream => _dataController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  bool get isConnected => _isConnected;

  // Listener Callbacks
  void Function(String status)? _onConnectionStatusChanged;
  void Function(String data)? _onDataReceived;
  void Function(String command)? _onCommandSent;
  void Function(String error)? _onError;

  void setUsbSerialListener({
    void Function(String status)? onConnectionStatusChanged,
    void Function(String data)? onDataReceived,
    void Function(String command)? onCommandSent,
    void Function(String error)? onError,
  }) {
    _onConnectionStatusChanged = onConnectionStatusChanged;
    _onDataReceived = onDataReceived;
    _onCommandSent = onCommandSent;
    _onError = onError;
  }

  Future<void> connect() async {
    await _autoConnect();
  }

  Future<void> _autoConnect() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      await connectToDevice(devices.first);
    } else {
      _isConnected = false;
      _onConnectionStatusChanged?.call("disconnected");
      _connectionStatusController.add(false);
    }
  }

  Future<bool> connectToDevice(UsbDevice? usbDevice) async {
    _disconnect(); // Ensure clean state

    if (usbDevice == null) {
      _isConnected = false;
      _onConnectionStatusChanged?.call("disconnected");
      _connectionStatusController.add(false);
      return false;
    }

    try {
      _port = await usbDevice.create();
      if (_port == null || !await _port!.open()) {
        _onError?.call("Failed to open USB port");
        _connectionStatusController.add(false);
        return false;
      }

      device = usbDevice;

      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      _isConnected = true;
      _onConnectionStatusChanged?.call("connected");
      _connectionStatusController.add(true);

      _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>,
        Uint8List.fromList([13, 10]), // \r\n
      );

      _subscription = _transaction!.stream.listen(
        (String line) {
          _safeAddData(line);
          _onDataReceived?.call(line);
        },
        onError: (error) {
          _onError?.call("Read error: $error");
        },
      );

      return true;
    } catch (e) {
      _onError?.call("Connection error: $e");
      _isConnected = false;
      _connectionStatusController.add(false);
      return false;
    }
  }

  Future<void> sendData(String data) async {
    try {
      if (_port != null) {
        await _port!.write(Uint8List.fromList(("$data\r\n").codeUnits));
        _onCommandSent?.call(data);
      } else {
        _onError?.call("No USB port open");
      }
    } catch (e) {
      _onError?.call("Send error: $e");
    }
  }

  void _safeAddConnectionStatus(bool status) {
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  void _safeAddData(String data) {
    if (!_dataController.isClosed) {
      _dataController.add(data);
    }
  }

  void _disconnect() {
    _subscription?.cancel();
    _transaction?.dispose();
    _port?.close();

    _subscription = null;
    _transaction = null;
    _port = null;
    device = null;
    _isConnected = false;

    _onConnectionStatusChanged?.call("disconnected");
    _safeAddConnectionStatus(false);
  }

  Future<List<UsbDevice>> listDevices() async {
    return await UsbSerial.listDevices();
  }

  void dispose() {
    _disconnect();
    _dataController.close();
    _connectionStatusController.close();
  }
}
