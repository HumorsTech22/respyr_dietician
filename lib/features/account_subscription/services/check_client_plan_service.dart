import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/account_subscription/data/model/check_client_plan_data.dart';

class CheckClientPlanService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/check_client_plan.php";

  Future<CheckClientPlanResponse> checkClientPlan({
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

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      return CheckClientPlanResponse.fromJson(jsonMap);
    } catch (e) {
      return CheckClientPlanResponse(
        status: false,
        message: "Something went wrong: $e",
        data: null,
      );
    }
  }
}

class CheckClientPlanResponse {
  final bool status;
  final String message;
  final CheckClientPlanData? data;

  CheckClientPlanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CheckClientPlanResponse.fromJson(Map<String, dynamic> json) {
    return CheckClientPlanResponse(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null
          ? CheckClientPlanData.fromJson(json["data"])
          : null,
    );
  }
}

