import 'dart:convert';
import 'package:http/http.dart' as http;

class SaveSelectedHabitsService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/save_client_selected_habits.php";

  static Future<bool> saveSelectedHabits({
    required String profileId,
    required int levelId,
    required List<int> habitIds,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "profile_id": profileId,
        "level_id": levelId,
        "habit_ids": habitIds,
      }),
    );

    print(jsonEncode({
      "profile_id": profileId,
      "level_id": levelId,
      "habit_ids": habitIds,
    }));
    print(response.body);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == true) {
      return true;
    }

    throw Exception(data["message"] ?? "Failed to save habits");
  }
}