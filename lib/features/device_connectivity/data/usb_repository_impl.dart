import 'package:respyr_dietitian/core/services/usb_communication_service.dart';
import 'package:respyr_dietitian/features/device_connectivity/domain/usb_repository.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbRepositoryImpl implements UsbRepository {
  final UsbCommunicationService usbService;

  UsbRepositoryImpl(this.usbService);

  @override
  Future<List<UsbDevice>> listDevices() => usbService.listDevices();

  @override
  Future<void> connectToDevice(UsbDevice device) =>
      usbService.connectToDevice(device);

  @override
  void sendData(String data) => usbService.sendData(data);

  @override
  void setUsbListener({
    required void Function(String status) onConnectionStatusChanged,
    required void Function(String data) onDataReceived,
    required void Function(String command) onCommandSent,
    required void Function(String error) onError,
  }) {
    usbService.setUsbSerialListener(
      onConnectionStatusChanged: onConnectionStatusChanged,
      onDataReceived: onDataReceived,
      onCommandSent: onCommandSent,
      onError: onError,
    );
  }
}
