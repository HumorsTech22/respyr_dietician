// data/api/clinical_device_check_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceCheckRepo {
  final http.Client client;

  DeviceCheckRepo({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchDeviceData(String deviceId) async {
    final url =
        'https://humorstech.com/humors_app/app_final/clinical/api/fetch/fetch_last_data_time2.php?hwid=$deviceId';

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to fetch device data");
    }
  }
}
