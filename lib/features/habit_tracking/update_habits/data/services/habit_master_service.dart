import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/habit_master_model.dart';

class HabitMasterService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/get_habit_master.php";

  Future<HabitMasterResponse> fetchHabitMaster({
    required int levelId,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "level_id": 1,
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return HabitMasterResponse.fromJson(decoded);
    } else {
      throw Exception(decoded["message"] ?? "Failed to fetch habits");
    }
  }
}