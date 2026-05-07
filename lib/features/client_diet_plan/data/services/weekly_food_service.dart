import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';

class WeeklyFoodService {
  static const String _baseUrl =
      'https://humorstech.com/dietitian/api/web/get_weekly_food_json_suggestions_weeks.php';

  static Future<WeeklyFoodResponse> fetchWeeklyFood({
    required String profileId,
    required String dietitianId,
    required String weekStartDate,
    required String weekEndDate,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'profile_id': profileId,
        'dietitian_id': dietitianId,
        'week_start_date': weekStartDate,
        'week_end_date': weekEndDate,
      }),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return WeeklyFoodResponse.fromJson(jsonData);
    } else {
      throw Exception(jsonData['message'] ?? 'Failed to fetch diet plan');
    }
  }
}