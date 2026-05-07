import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ota_update_state.dart';

class OtaUpdateCubit extends Cubit<OtaUpdateState> {
  OtaUpdateCubit() : super(OtaUpdateState.initial()) {
    _listenScanResults();
  }

  // ===== UUIDs from python =====
  static final Guid uartServiceUuid =
  Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  static final Guid uartTxCharUuid =
  Guid("49535343-1e4d-4bd9-ba61-23c647249616"); // device -> phone notify
  static final Guid uartRxCharUuid =
  Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e"); // phone -> device write

  // ===== Protocol =====
  static const int otaSof = 0xAA;

  static const int cmdOtaBegin = 0x01;
  static const int cmdOtaChunk = 0x02;
  static const int cmdOtaEnd = 0x03;
  static const int cmdOtaAbort = 0x04;
  static const int cmdPing = 0x05;

  static const int rspOk = 0x00;
  static const int rspErrCrc = 0x01;
  static const int rspErrSeq = 0x02;
  static const int rspErrFlash = 0x03;
  static const int rspErrImgCrc = 0x04;
  static const int rspErrOverflow = 0x05;
  static const int rspErrNoSession = 0x06;
  static const int rspPong = 0x10;

  // ===== Match python =====
  static const int chunkSize = 256;
  static const int maxRetries = 3;
  static const int windowSize = 16;

  static const int packetFragmentSize = 3;
  static const int packetFragmentDelayMs = 3;

  static const Duration ackTimeout = Duration(seconds: 15);
  static const Duration scanTimeout = Duration(seconds: 8);

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;

  final StreamController<int> _rspController =
  StreamController<int>.broadcast();
  final StreamController<String> _textController =
  StreamController<String>.broadcast();

  final List<int> _rspBuf = [];
  final List<int> _textBuf = [];

  // ===== important python-like window ack handling =====
  bool _inWindow = false;
  final Queue<int> _ackQueue = Queue<int>();
  Completer<int>? _ackWaiter;

  bool _readySeen = false;
  DateTime? _otaStartedAt;

  void _log(String message) {
    if (kDebugMode) {
      print("🟦 OTA_UPDATE | $message");
    }

    final next =
    state.logText.isEmpty ? message : "${state.logText}\n$message";

    emit(state.copyWith(
      logText: next,
      status: message,
    ));
  }

  String rspName(int rsp) {
    switch (rsp) {
      case rspOk:
        return "OK";
      case rspErrCrc:
        return "ERR_CRC";
      case rspErrSeq:
        return "ERR_SEQ";
      case rspErrFlash:
        return "ERR_FLASH";
      case rspErrImgCrc:
        return "ERR_IMG_CRC";
      case rspErrOverflow:
        return "ERR_OVERFLOW";
      case rspErrNoSession:
        return "ERR_NO_SESSION";
      case rspPong:
        return "PONG";
      case -1:
        return "TIMEOUT";
      default:
        return "UNKNOWN($rsp)";
    }
  }

  String deviceNameFromScan(ScanResult result) {
    final advName = result.advertisementData.advName.trim();
    final platformName = result.device.platformName.trim();

    if (advName.isNotEmpty) return advName;
    if (platformName.isNotEmpty) return platformName;
    return "Unknown Device";
  }

  void _listenScanResults() {
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final Map<String, ScanResult> filtered = {};

      for (final result in results) {
        final name = deviceNameFromScan(result);
        if (name.toLowerCase().contains("respyr")) {
          filtered[result.device.remoteId.str] = result;
        }
      }

      emit(state.copyWith(devices: filtered.values.toList()));
    });
  }

  Future<void> startScan() async {
    try {
      emit(state.copyWith(
        isScanning: true,
        devices: [],
        status: "Scanning Respyr devices...",
      ));

      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
      }

      await FlutterBluePlus.startScan(timeout: scanTimeout);
      await Future.delayed(scanTimeout);

      emit(state.copyWith(
        isScanning: false,
        status: state.devices.isEmpty
            ? "No Respyr device found"
            : "Scan complete",
      ));
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        status: "Scan failed: $e",
      ));
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}

    emit(state.copyWith(
      isScanning: false,
      status: "Scan stopped",
    ));
  }

  Future<void> connect(ScanResult result) async {
    try {
      await stopScan();

      emit(state.copyWith(
        isConnecting: true,
        status: "Connecting to ${deviceNameFromScan(result)}...",
      ));

      _device = result.device;

      try {
        await _device!.disconnect();
      } catch (_) {}

      await _device!.connect(
        timeout: const Duration(seconds: 15), license: License.free,
      );

      _connSub?.cancel();
      _connSub = _device!.connectionState.listen((connectionState) {
        final connected =
            connectionState == BluetoothConnectionState.connected;

        emit(state.copyWith(
          isConnected: connected,
          connectedDeviceName: connected ? deviceNameFromScan(result) : '',
          connectedDeviceId: connected ? _device!.remoteId.str : '',
          status: connected ? "Connected" : "Disconnected",
        ));
      });

      try {
        final mtu = await _device!.requestMtu(512);
        _log("MTU negotiated: $mtu");
      } catch (e) {
        _log("MTU request skipped: $e");
      }

      await _discoverCharacteristics();
      await _startNotify();

      emit(state.copyWith(
        isConnecting: false,
        isConnected: true,
        connectedDeviceName: deviceNameFromScan(result),
        connectedDeviceId: _device!.remoteId.str,
        status: "Connected to ${deviceNameFromScan(result)}",
      ));
    } catch (e) {
      emit(state.copyWith(
        isConnecting: false,
        isConnected: false,
        status: "Connect failed: $e",
      ));
    }
  }

  Future<void> _discoverCharacteristics() async {
    if (_device == null) {
      throw Exception("No device selected");
    }

    final services = await _device!.discoverServices();

    BluetoothCharacteristic? foundNotify;
    BluetoothCharacteristic? foundWrite;

    for (final service in services) {
      if (service.uuid != uartServiceUuid) continue;

      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == uartTxCharUuid) {
          foundNotify = characteristic;
        }
        if (characteristic.uuid == uartRxCharUuid) {
          foundWrite = characteristic;
        }
      }
    }

    if (foundNotify == null || foundWrite == null) {
      throw Exception("OTA characteristics not found");
    }

    _notifyChar = foundNotify;
    _writeChar = foundWrite;
  }

  Future<void> _startNotify() async {
    if (_notifyChar == null) {
      throw Exception("Notify characteristic missing");
    }

    await _notifyChar!.setNotifyValue(true);

    _notifySub?.cancel();
    _notifySub = _notifyChar!.lastValueStream.listen((data) {
      if (data.isEmpty) return;

      final receivedText =
      String.fromCharCodes(data).replaceAll('\u0000', '').trim();

      if (receivedText.isNotEmpty) {
        emit(state.copyWith(receivedText: receivedText));
      }

      // OTA_READY text detection
      _textBuf.addAll(data);
      final text = String.fromCharCodes(_textBuf);

      if (text.contains("OTA_READY")) {
        _readySeen = true;
        _textController.add("OTA_READY");
        _textBuf.clear();
        _rspBuf.clear();
        return;
      } else if (text.contains('\n')) {
        _textBuf.clear();
      }

      // Binary response parsing
      _rspBuf.addAll(data);

      while (_rspBuf.length >= 3) {
        if (_rspBuf.first != otaSof) {
          _rspBuf.removeAt(0);
          continue;
        }

        final rsp = _rspBuf[1];
        _rspBuf.removeRange(0, 3);

        if (_inWindow) {
          if (_ackWaiter != null && !(_ackWaiter!.isCompleted)) {
            _ackWaiter!.complete(rsp);
            _ackWaiter = null;
          } else {
            _ackQueue.addLast(rsp);
          }
        } else {
          _rspController.add(rsp);
        }
      }
    });
  }

  Future<void> disconnect() async {
    try {
      await _notifyChar?.setNotifyValue(false);
    } catch (_) {}

    try {
      await _device?.disconnect();
    } catch (_) {}

    emit(state.copyWith(
      isConnected: false,
      isConnecting: false,
      isRunningOta: false,
      connectedDeviceName: '',
      connectedDeviceId: '',
      status: "Disconnected",
    ));
  }

  int crc16(Uint8List data) {
    int crc = 0xFFFF;
    for (final b in data) {
      crc ^= (b << 8);
      for (int i = 0; i < 8; i++) {
        crc = ((crc & 0x8000) != 0)
            ? (((crc << 1) ^ 0x1021) & 0xFFFF)
            : ((crc << 1) & 0xFFFF);
      }
    }
    return crc & 0xFFFF;
  }

  int crc32(Uint8List data) {
    int crc = 0xFFFFFFFF;
    for (final b in data) {
      crc ^= b;
      for (int i = 0; i < 8; i++) {
        final mask = -(crc & 1);
        crc = (crc >> 1) ^ (0xEDB88320 & mask);
      }
    }
    return (~crc) & 0xFFFFFFFF;
  }

  Uint8List _u16le(int v) =>
      Uint8List.fromList([v & 0xFF, (v >> 8) & 0xFF]);

  Uint8List _u32le(int v) => Uint8List.fromList([
    v & 0xFF,
    (v >> 8) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 24) & 0xFF,
  ]);

  Uint8List buildPacket(int cmd, [Uint8List? payload]) {
    payload ??= Uint8List(0);

    final header = Uint8List.fromList([
      otaSof,
      cmd,
      payload.length & 0xFF,
      (payload.length >> 8) & 0xFF,
    ]);

    final crcSource = Uint8List.fromList([
      cmd,
      payload.length & 0xFF,
      (payload.length >> 8) & 0xFF,
      ...payload,
    ]);

    final crc = crc16(crcSource);

    return Uint8List.fromList([
      ...header,
      ...payload,
      crc & 0xFF,
      (crc >> 8) & 0xFF,
    ]);
  }

  Uint8List buildPing() => buildPacket(cmdPing);

  Uint8List buildAbort() => buildPacket(cmdOtaAbort);

  Uint8List buildEnd() => buildPacket(cmdOtaEnd);

  Uint8List buildBegin(int imageSize, int imageCrc, int totalChunks) {
    final payload = Uint8List.fromList([
      ..._u32le(imageSize),
      ..._u32le(imageCrc),
      ..._u16le(chunkSize),
      ..._u16le(totalChunks),
    ]);
    return buildPacket(cmdOtaBegin, payload);
  }

  Uint8List buildChunk(int seq, Uint8List data) {
    final payload = Uint8List.fromList([
      ..._u16le(seq),
      ...data,
    ]);
    return buildPacket(cmdOtaChunk, payload);
  }

  Future<void> _sendPacket(Uint8List packet) async {
    if (_writeChar == null) {
      throw Exception("Write characteristic missing");
    }

    for (int i = 0; i < packet.length; i += packetFragmentSize) {
      final end = min(i + packetFragmentSize, packet.length);

      await _writeChar!.write(
        packet.sublist(i, end),
        withoutResponse: false,
      );

      await Future.delayed(
        const Duration(milliseconds: packetFragmentDelayMs),
      );
    }
  }

  Future<void> sendRaw(Uint8List data) async {
    if (_writeChar == null) {
      throw Exception("Write characteristic missing");
    }

    await _writeChar!.write(
      data,
      withoutResponse: false,
    );
  }

  Future<int> sendRecv(
      Uint8List packet, {
        Duration timeout = ackTimeout,
      }) async {
    _inWindow = false;

    final responseFuture = _rspController.stream.first.timeout(timeout);
    await _sendPacket(packet);

    try {
      return await responseFuture;
    } catch (_) {
      return -1;
    }
  }

  Future<int> _nextAck({Duration timeout = ackTimeout}) async {
    if (_ackQueue.isNotEmpty) {
      return _ackQueue.removeFirst();
    }

    _ackWaiter = Completer<int>();

    try {
      return await _ackWaiter!.future.timeout(timeout);
    } catch (_) {
      if (_ackWaiter != null && !(_ackWaiter!.isCompleted)) {
        _ackWaiter = null;
      }
      return -1;
    }
  }

  void _resetWindowAckState() {
    _ackQueue.clear();
    _ackWaiter = null;
  }

  Future<bool> waitForReady({double timeoutSeconds = 6.0}) async {
    if (_readySeen) {
      _readySeen = false;
      return true;
    }

    try {
      await _textController.stream.first.timeout(
        Duration(milliseconds: (timeoutSeconds * 1000).toInt()),
      );
      _readySeen = false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _doDashAndPing(String label) async {
    _log("Sending '-' ($label)...");
    await sendRaw(Uint8List.fromList('-'.codeUnits));
    _log("'-' sent — waiting for OTA_READY...");

    if (await waitForReady(timeoutSeconds: 6.0)) {
      _log("OTA_READY received");
    } else {
      _log("No OTA_READY within 6s — trying PING anyway");
    }

    await Future.delayed(const Duration(milliseconds: 300));

    _log("Pinging...");
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final rsp = await sendRecv(
        buildPing(),
        timeout: const Duration(seconds: 10),
      );

      if (rsp == rspPong) {
        _log("PONG received");
        return true;
      }

      _log("Ping attempt ${attempt + 1}: ${rspName(rsp)}");
    }

    _log("No PONG");
    return false;
  }

  Future<Uint8List> _loadFirmwareFromAssets(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }

  Uint8List _padFirmware(Uint8List firmware) {
    final remainder = firmware.length % chunkSize;
    if (remainder == 0) return firmware;

    final padding = chunkSize - remainder;
    return Uint8List.fromList([
      ...firmware,
      ...List<int>.filled(padding, 0xFF),
    ]);
  }

  Future<bool> _reconnectToSameDevice() async {
    if (_device == null) return false;

    try {
      await _device!.disconnect();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await _device!.connect(
          timeout: const Duration(seconds: 15), license: License.free,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        await _discoverCharacteristics();
        await _startNotify();
        return true;
      } catch (e) {
        _log("Reconnect attempt ${attempt + 1}: $e");
        await Future.delayed(const Duration(seconds: 4));
      }
    }

    return false;
  }

  Future<bool> _sendChunks(Uint8List firmware, int totalChunks) async {
    int acked = 0;
    int sent = 0;

    final Map<int, Uint8List> inFlight = {};
    final Map<int, int> errors = {};

    Future<void> sendSeq(int seq) async {
      final start = seq * chunkSize;
      final chunk = firmware.sublist(start, start + chunkSize);
      final packet = buildChunk(seq, chunk);
      inFlight[seq] = packet;
      await _sendPacket(packet);
    }

    _inWindow = true;
    _resetWindowAckState();

    while (acked < totalChunks) {
      while (sent < totalChunks && (sent - acked) < windowSize) {
        await sendSeq(sent);
        sent++;
      }

      final rsp = await _nextAck(timeout: ackTimeout);
      final seq = acked;

      if (rsp == rspOk) {
        inFlight.remove(seq);
        acked++;

        final elapsed =
            DateTime.now().difference(_otaStartedAt!).inMilliseconds / 1000.0;
        final rate =
        elapsed > 0 ? ((acked * chunkSize) / elapsed / 1024.0) : 0.0;

        emit(state.copyWith(
          progressCurrent: acked,
          progressTotal: totalChunks,
          elapsedSeconds: elapsed.floor(),
          speedKbPerSec: rate,
          status: "Sending chunks...",
        ));
      } else if (rsp == -1) {
        _log("Timeout (acked=$acked) — retransmitting window");
        for (int seqToResend = acked; seqToResend < sent; seqToResend++) {
          if (inFlight.containsKey(seqToResend)) {
            await _sendPacket(inFlight[seqToResend]!);
          }
        }
      } else if (rsp == rspErrSeq) {
        _log("ERR_SEQ at seq=$seq — retransmitting window");
        sent = acked;
        inFlight.clear();
        _resetWindowAckState();
      } else {
        errors[seq] = (errors[seq] ?? 0) + 1;

        if ((errors[seq] ?? 0) >= maxRetries) {
          _log("Chunk $seq failed ${maxRetries}x (${rspName(rsp)}) — aborting");
          _inWindow = false;
          return false;
        }

        _log("Chunk $seq: ${rspName(rsp)} (attempt ${errors[seq]}) — retrying");
        sent = acked;
        inFlight.clear();
        _resetWindowAckState();
      }
    }

    _inWindow = false;
    _resetWindowAckState();
    return true;
  }

  Future<void> startOtaFromAssets(String assetPath) async {
    if (!state.isConnected) {
      emit(state.copyWith(status: "Connect device first"));
      return;
    }

    try {
      _rspBuf.clear();
      _textBuf.clear();
      _readySeen = false;
      _inWindow = false;
      _resetWindowAckState();

      emit(state.copyWith(
        isRunningOta: true,
        progressCurrent: 0,
        progressTotal: 0,
        elapsedSeconds: 0,
        speedKbPerSec: 0,
        status: "Loading firmware...",
      ));

      final rawFirmware = await _loadFirmwareFromAssets(assetPath);
      final firmware = _padFirmware(rawFirmware);

      final imageSize = firmware.length;
      final imageCrc = crc32(firmware);
      final totalChunks = imageSize ~/ chunkSize;

      _otaStartedAt = DateTime.now();

      _log("Firmware loaded: $assetPath");
      _log("Size: $imageSize bytes");
      _log("CRC32: 0x${imageCrc.toRadixString(16).toUpperCase()}");
      _log("Chunks: $totalChunks x $chunkSize");
      _log("Window size: $windowSize");
      _log("Write mode: 3 bytes, response=true, 3ms gap");

      _log("[0/4] Entering OTA mode...");
      final alive = await _doDashAndPing("initial");
      if (!alive) {
        throw Exception("Device not responding — aborting");
      }

      _log("[1/4] Device alive");
      _log("[2/4] Starting OTA session...");
      _log("(will erase Slot B)");

      int rsp = await sendRecv(
        buildBegin(imageSize, imageCrc, totalChunks),
        timeout: const Duration(seconds: 15),
      );

      if (rsp == rspErrNoSession) {
        _log("RSP_ERR_NO_SESSION — device rebooting SlotB→SlotA...");
        _log("Waiting 8s for reboot...");
        await Future.delayed(const Duration(seconds: 8));

        final currentState = await _device!.connectionState.first;
        final stillConnected =
            currentState == BluetoothConnectionState.connected;

        if (!stillConnected) {
          _log("Connection dropped — reconnecting...");
          final reconnected = await _reconnectToSameDevice();
          if (!reconnected) {
            throw Exception("Could not reconnect — aborting");
          }
          _log("Reconnected");
        } else {
          _log("Connection still alive");
          await _discoverCharacteristics();
          await _startNotify();
        }

        final aliveAgain = await _doDashAndPing("after SlotB→SlotA reboot");
        if (!aliveAgain) {
          throw Exception("Device not responding after reboot — aborting");
        }

        _log("Sending BEGIN on SlotA...");
        bool beginOk = false;

        for (int attempt = 0; attempt < maxRetries; attempt++) {
          rsp = await sendRecv(
            buildBegin(imageSize, imageCrc, totalChunks),
            timeout: const Duration(seconds: 15),
          );

          if (rsp == rspOk) {
            beginOk = true;
            break;
          }

          _log("BEGIN attempt ${attempt + 1}: ${rspName(rsp)}");
          await Future.delayed(const Duration(seconds: 2));
        }

        if (!beginOk) {
          throw Exception("BEGIN failed — aborting");
        }
      } else if (rsp != rspOk) {
        throw Exception("BEGIN failed: ${rspName(rsp)}");
      }

      _log("Session started — Slot B erased");
      _log("[3/4] Sending $totalChunks chunks...");

      final chunkSuccess = await _sendChunks(firmware, totalChunks);
      if (!chunkSuccess) {
        await sendRecv(
          buildAbort(),
          timeout: const Duration(seconds: 5),
        );
        throw Exception("Chunk transfer failed");
      }

      final elapsed =
          DateTime.now().difference(_otaStartedAt!).inMilliseconds / 1000.0;

      _log(
        "Done — ${(imageSize / 1024.0).toStringAsFixed(1)} KB in ${elapsed.toStringAsFixed(1)}s "
            "(${(imageSize / elapsed / 1024.0).toStringAsFixed(1)} KB/s avg)",
      );

      _log("[4/4] Committing — verifying CRC32 on device...");

      bool endOk = false;
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        final endRsp = await sendRecv(
          buildEnd(),
          timeout: const Duration(seconds: 15),
        );

        if (endRsp == rspOk) {
          endOk = true;
          _log("CRC32 verified — boot flag written");
          _log("Device rebooting into new firmware...");
          break;
        }

        _log("END attempt ${attempt + 1}: ${rspName(endRsp)}");
      }

      if (!endOk) {
        throw Exception("END failed — device stays on current firmware");
      }

      emit(state.copyWith(
        isRunningOta: false,
        progressCurrent: totalChunks,
        progressTotal: totalChunks,
        elapsedSeconds: elapsed.floor(),
        speedKbPerSec: imageSize / elapsed / 1024.0,
        status: "OTA complete",
      ));

      _log("── OTA complete ✓ ──");
    } catch (e) {
      _log("OTA failed: $e");
      emit(state.copyWith(
        isRunningOta: false,
        status: "OTA failed: $e",
      ));
    }
  }

  @override
  Future<void> close() async {
    await _scanSub?.cancel();
    await _connSub?.cancel();
    await _notifySub?.cancel();
    await _rspController.close();
    await _textController.close();
    return super.close();
  }
}