import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodLogApi {
  static const String _baseUrl =
      "https://humorstech.com/dietitian/api/app/insert_food_log.php"; // 🔁 replace with actual path

  /// Inserts a food log entry and returns the decoded JSON response
  static Future<Map<String, dynamic>> insertFoodLog({
    required String dieticianId,
    required String profileId,
    required String dietPlanId,
    required String mealTitle,
    required String mealName,
    required String mealValues,
    String? dttm,
  }) async {
    final Map<String, dynamic> body = {
      "dietician_id": dieticianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
      "meal_title": mealTitle,
      "meal_name": mealName,
      "meal_values": mealValues,
      "dttm": dttm ?? DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );



      if (response.statusCode == 200) {



        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "error": "HTTP Error: ${response.statusCode}",
          "body": response.body
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
