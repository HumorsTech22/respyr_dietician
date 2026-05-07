import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getPhoneModel() async {
  try {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;

      String code = iosInfo.utsname.machine ?? "Unknown";

      // Convert hardware code → marketing name
      return _iosModelMap[code] ?? code;
    }

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      String brand = androidInfo.brand;
      String model = androidInfo.model;

      return "$brand $model".trim();
    }

    return "Unknown Platform";
  } catch (e) {
    print("Error getting device model: $e");
    return "Unknown Device";
  }
}

const Map<String, String> _iosModelMap = {
  "iPhone15,2": "iPhone 14 Pro",
  "iPhone15,3": "iPhone 14 Pro Max",
  "iPhone15,4": "iPhone 14",
  "iPhone15,5": "iPhone 14 Plus",

  "iPhone16,1": "iPhone 15",
  "iPhone16,2": "iPhone 15 Plus",
  "iPhone16,3": "iPhone 15 Pro",
  "iPhone16,4": "iPhone 15 Pro Max",

  "iPhone17,1": "iPhone 17 Air",
  "iPhone17,2": "iPhone 17",
  "iPhone17,3": "iPhone 17 Pro",
  "iPhone17,4": "iPhone 17 Pro Max",
};