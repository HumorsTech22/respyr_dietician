import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckClientHabitsResponse {
  final bool status;
  final String message;
  final String profileId;
  final int levelType;
  final bool isHabitAdded;
  final int totalHabits;
  final List<ClientSelectedHabitData> data;

  CheckClientHabitsResponse({
    required this.status,
    required this.message,
    required this.profileId,
    required this.levelType,
    required this.isHabitAdded,
    required this.totalHabits,
    required this.data,
  });

  factory CheckClientHabitsResponse.fromJson(Map<String, dynamic> json) {
    return CheckClientHabitsResponse(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      profileId: json["profile_id"]?.toString() ?? "",
      levelType: int.tryParse(json["level_type"]?.toString() ?? "1") ?? 1,
      isHabitAdded: json["is_habit_added"] == true,
      totalHabits: int.tryParse(json["total_habits"]?.toString() ?? "0") ?? 0,
      data: json["data"] is List
          ? (json["data"] as List)
          .map((e) => ClientSelectedHabitData.fromJson(e))
          .toList()
          : [],
    );
  }
}

class ClientSelectedHabitData {
  final int id;
  final String profileId;
  final int habitId;
  final int levelId;
  final String startDate;
  final String? endDate;
  final String status;
  final String selectedAt;
  final String updatedAt;

  ClientSelectedHabitData({
    required this.id,
    required this.profileId,
    required this.habitId,
    required this.levelId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.selectedAt,
    required this.updatedAt,
  });

  factory ClientSelectedHabitData.fromJson(Map<String, dynamic> json) {
    return ClientSelectedHabitData(
      id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
      profileId: json["profile_id"]?.toString() ?? "",
      habitId: int.tryParse(json["habit_id"]?.toString() ?? "0") ?? 0,
      levelId: int.tryParse(json["level_id"]?.toString() ?? "1") ?? 1,
      startDate: json["start_date"]?.toString() ?? "",
      endDate: json["end_date"]?.toString(),
      status: json["status"]?.toString() ?? "",
      selectedAt: json["selected_at"]?.toString() ?? "",
      updatedAt: json["updated_at"]?.toString() ?? "",
    );
  }
}

class CheckClientHabitsService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/check_client_habits_added.php";

  static Future<CheckClientHabitsResponse> checkClientHabitsAdded({
    required String profileId,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "profile_id": profileId,
      }),
    );

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format");
    }

    final result = CheckClientHabitsResponse.fromJson(decoded);

    if (response.statusCode == 200 && result.status) {
      return result;
    }

    throw Exception(result.message.isNotEmpty
        ? result.message
        : "Failed to check client habits");
  }
}