import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';

class TestHistoryCompleteService {
  // TODO: update API URL
  static const String _baseUrl =
      'https://humorstech.com/dietitian/api/app/get_test_data_by_id.php';

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
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
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
}
