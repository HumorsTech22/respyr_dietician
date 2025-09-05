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
      print("📡 Raw API data for $deviceId => $data");

      String signal = '{';
      bool isReady = false;

      if (data.containsKey("count") && data.containsKey("lastDataTime")) {
        final int count = int.tryParse(data['count'].toString()) ?? 0;
        final int lastDataTime =
            int.tryParse(data["lastDataTime"].toString()) ?? 0;

        print("📊 Parsed: count=$count, lastDataTime=$lastDataTime");

        if (count == 0 && lastDataTime == 0) {
          // Case 1: device connected but no data yet
          signal = '{';
          isReady = true;
        } else if (count > 0) {
          final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          int diff = now - lastDataTime;

          // Handle future timestamps
          if (diff < 0) {
            print("⚠️ Future lastDataTime detected. Treating diff=0.");
            diff = 0;
          }

          print("⏱ now=$now, diff=$diff sec");

          if (diff <= 600) {
            signal = '#';
            isReady = true;
          } else if (diff <= 21600) {
            // ✅ within 6 hours
            signal = '\$';
            isReady = true; // <-- CHANGED (was false before)
          } else {
            signal = '{';
            isReady = false;
          }
        }

        // Case 3: abort-time logic
        if (signal == '{' && lastAbortTime != null && counter != null) {
          final int nowMillis = DateTime.now().millisecondsSinceEpoch;
          final double timeDiffMinutes = (nowMillis - lastAbortTime) / 60000.0;
          print("🚨 Abort check: timeDiffMinutes=$timeDiffMinutes");

          if (timeDiffMinutes > 10) {
            signal = '\$';
          } else {
            signal = '#';
            isReady = true;
          }
        }
      }

      // Save state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("isFirstReading", signal);
      await prefs.setBool("is_device_ready", isReady);

      print("✅ Final Decision: signal=$signal, isReady=$isReady");

      return DeviceCheckResult(signal: signal, isReady: isReady);
    } catch (e, s) {
      print("❌ DeviceCheckUsecase error: $e\n$s");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("isFirstReading", "{");
      await prefs.setBool("is_device_ready", false);

      return DeviceCheckResult(signal: '{', isReady: false);
    }
  }
}

class DeviceCheckResult {
  final String signal;
  final bool isReady;

  DeviceCheckResult({required this.signal, required this.isReady});
}
