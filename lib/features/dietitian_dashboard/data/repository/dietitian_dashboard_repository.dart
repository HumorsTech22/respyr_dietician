// dietitian_dashboard_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';

class DietitianDashboardRepository {
  final String _baseUrl =
      "https://humorstech.com/dietitian/api/app/get_diet_by_day.php";

  Future<DietitianDashboardMealModel> fetchDailyMealPlan({
    required String loginId,
    required String profileId,
    required String day, // e.g., "monday"
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: {
        'login_id': loginId,
        'profile_id': profileId,
        'day': day.toLowerCase(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody =
          json.decode(response.body) as Map<String, dynamic>;
      if (jsonBody['status'] == 'success') {
        return DietitianDashboardMealModel.fromJson(jsonBody);
      } else {
        throw Exception(
          "API returned failure: ${jsonBody['message'] ?? 'Unknown error'}",
        );
      }
    } else {
      throw Exception("HTTP error: ${response.statusCode}");
    }
  }
}
