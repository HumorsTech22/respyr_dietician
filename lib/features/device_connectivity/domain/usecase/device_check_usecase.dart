// domain/usecase/clinical_device_check_usecase.dart
import 'package:respyr_dietitian/features/device_connectivity/data/repository/device_check_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceCheckUsecase {
  final DeviceCheckRepo api;

  DeviceCheckUsecase(this.api);

  Future<DeviceCheckResult> checkSignal(
    String deviceId, {
    int? lastAbortTime,
    int? counter,
  }) async {
    try {
      final data = await api.fetchDeviceData(deviceId);

      String signal = '{';
      bool isReady = false;

      if (data.containsKey("count") && data.containsKey("lastDataTime")) {
        final int count = int.tryParse(data['count'].toString()) ?? 0;
        final int lastDataTime =
            int.tryParse(data["lastDataTime"].toString()) ?? 0;

        // ✅ Case 1: device is connected but never sent data yet
        if (count == 0 && lastDataTime == 0) {
          signal = '{';
          isReady = true; // treat as ready to proceed
        }
        // ✅ Case 2: device has valid data
        else if (count > 0) {
          final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final int diff = now - lastDataTime;

          if (diff <= 600) {
            signal = '#';
            isReady = true;
          } else if (diff <= 3600) {
            signal = '\$';
          } else {
            signal = '{';
          }
        }

        // Apply abort-time logic
        if (signal == '{' && lastAbortTime != null && counter != null) {
          final int nowMillis = DateTime.now().millisecondsSinceEpoch;
          final double timeDiffMinutes = (nowMillis - lastAbortTime) / 60000.0;
          if (timeDiffMinutes > 10) {
            signal = '\$';
          } else {
            signal = '#';
            isReady = true;
          }
        }
      }

      // 🔑 Save into SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("isFirstReading", signal);
      await prefs.setBool("is_device_ready", isReady);

      return DeviceCheckResult(signal: signal, isReady: isReady);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("isFirstReading", "{");
      await prefs.setBool("is_device_ready", false);

      return DeviceCheckResult(signal: '{', isReady: false); // fallback
    }
  }
}

class DeviceCheckResult {
  final String signal;
  final bool isReady;

  DeviceCheckResult({required this.signal, required this.isReady});
}
