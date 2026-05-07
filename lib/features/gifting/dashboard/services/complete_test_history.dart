import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';
import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';

class TestHistoryCompleteService {
  static const String _baseUrl =
      'https://humorstech.com/dietitian/api/app/get_test_data_by_id.php';

  static const String _baseUrlNew =
      'https://humorstech.com/dietitian/api/app/get_test_data_by_id_new.php';

  static Future<GeneratingResultModel> fetchTestHistoryComplete({
    required String dietitianId,
    required String profileId,
    required int testId,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl);

      final body = jsonEncode({
        "dietitian_id": dietitianId,
        "profile_id": profileId,
        "test_id": testId.toString(),
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      final model = GeneratingResultModel.fromJson(jsonMap);

      if (!model.success) {
        throw Exception('API error: ${model.message}');
      }

      return model;
    } catch (e) {
      rethrow;
    }
  }

  static Future<RespyrUnifiedResponse> fetchTestHistoryCompleteNew({
    required String dietitianId,
    required String profileId,
    required int testId,
  }) async {
    try {
      final uri = Uri.parse(_baseUrlNew);

      final body = jsonEncode({
        "dietitian_id": dietitianId,
        "profile_id": profileId,
        "test_id": testId.toString(),
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      Map<String, dynamic> respyrJson;

      // case 1: wrapped response
      if (jsonMap['success'] == true && jsonMap['respyr_response'] is Map) {
        respyrJson = Map<String, dynamic>.from(jsonMap['respyr_response']);

        if ((respyrJson['date_time'] ?? '').toString().trim().isEmpty) {
          respyrJson['date_time'] = (jsonMap['date_time'] ?? '').toString();
        }
      }
      // case 2: already direct unified response
      else {
        respyrJson = Map<String, dynamic>.from(jsonMap);
      }

      final model = RespyrUnifiedResponse.fromJson(respyrJson);

      return model;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}