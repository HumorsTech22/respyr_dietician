import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';

class FetchUserHabitsService {
  static const String _url = "https://humorstech.com/dietitian/api/app/fetch_user_habits.php";

  static Future<UserHabitsModel?> fetchUserHabits({
    required String profileId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "profile_id": profileId,
        }),
      );

      print(response.body.toString());
      print("Profile id :" + profileId);

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      final bool status = jsonMap["status"] == true;

      if (!status) {
        return null;
      }

      final dynamic data = jsonMap["data"];

      if (data == null || data is! Map<String, dynamic>) {
        return null;
      }

      return UserHabitsModel.fromJson(data);
    } catch (e) {
      throw Exception("Failed to fetch user habits: $e");
    }
  }
}