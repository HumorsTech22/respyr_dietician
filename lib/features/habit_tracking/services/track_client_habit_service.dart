import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackClientHabitService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/track_client_habit.php";

  static Future<void> trackHabit({
    required String profileId,
    required int habitId,
    required String trackingDate,
    required int completedCount,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "profile_id": profileId,
        "habit_id": habitId,
        "tracking_date": trackingDate,
        "completed_count": completedCount,
        "notes": notes ?? "",
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["status"] != true) {
      throw Exception(data["message"] ?? "Failed to track habit");
    }
  }
}