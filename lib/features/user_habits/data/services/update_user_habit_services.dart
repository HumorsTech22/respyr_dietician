import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/user_habits/data/model/update_user_habit_request.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/update_user_habit_response.dart';

class UpdateUserHabitsService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/update_user_habits.php";

  static Future<UpdateUserHabitsResponse> updateUserHabits({
    required UpdateUserHabitsRequest request,
  }) async {
    try {
      final uri = Uri.parse(_url);

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      final dynamic decodedBody =
      jsonDecode(response.body.isNotEmpty ? response.body : "{}");

      if (response.statusCode == 200) {
        if (decodedBody is Map<String, dynamic>) {
          return UpdateUserHabitsResponse.fromJson(decodedBody);
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        if (decodedBody is Map<String, dynamic>) {
          return UpdateUserHabitsResponse(
            status: false,
            message: decodedBody["message"]?.toString() ??
                "Server error: ${response.statusCode}",
          );
        } else {
          return UpdateUserHabitsResponse(
            status: false,
            message: "Server error: ${response.statusCode}",
          );
        }
      }
    } catch (e) {
      return UpdateUserHabitsResponse(
        status: false,
        message: "Something went wrong: $e",
      );
    }
  }
}