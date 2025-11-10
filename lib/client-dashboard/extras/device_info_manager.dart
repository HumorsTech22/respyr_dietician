import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoManager{
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }
}