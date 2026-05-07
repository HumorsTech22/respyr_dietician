import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';

class ClientHabitService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/get_client_selected_habits_status.php";

  Future<ClientHabitStatusResponse> fetchClientHabits({
    required String profileId,
    required String trackingDate,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "profile_id": profileId,
        "tracking_date": trackingDate,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ClientHabitStatusResponse.fromJson(json);
    } else {
      throw Exception(json["message"] ?? "Failed to fetch habits");
    }
  }
}