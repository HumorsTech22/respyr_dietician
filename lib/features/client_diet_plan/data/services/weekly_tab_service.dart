import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_tab_model.dart';

class WeeklyTabService {
  static const String _baseUrl =
      'https://humorstech.com/dietitian/api/web/get-weekly-tab-list.php';

  static Future<WeeklyTabResponse> fetchWeeklyTabs({
    required String profileId,
    required String dietitianId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'profile_id': profileId,
          'dietitian_id': dietitianId,
        }),
      );

      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return WeeklyTabResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch weekly tabs');
      }
    } catch (e) {
      throw Exception('Weekly tab API error: $e');
    }
  }
}