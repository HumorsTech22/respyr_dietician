import 'package:respyr_dietitian/features/account_subscription/data/model/user_plan_model.dart';

class FetchUserPlansResponse {
  final bool status;
  final String message;
  final List<UserPlanModel> data;

  FetchUserPlansResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchUserPlansResponse.fromJson(Map<String, dynamic> json) {
    return FetchUserPlansResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List?)
          ?.map((e) => UserPlanModel.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
    );
  }
}