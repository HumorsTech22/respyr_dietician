import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getOsVersion() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    return android.version.release ?? 'unknown';
  }

  if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    return ios.systemVersion ?? 'unknown';
  }

  return 'unknown';
}