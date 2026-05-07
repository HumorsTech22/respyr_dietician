class UserPlanModel {
  final int id;
  final String dieticianId;
  final String profileId;
  final String clientId;
  final String couponCode;
  final String planCode;
  final String planName;
  final int durationMonths;
  final String subscriptionStartDate;
  final String subscriptionEndDate;
  final String status;
  final String activatedAt;
  final String createdAt;
  final String updatedAt;

  UserPlanModel({
    required this.id,
    required this.dieticianId,
    required this.profileId,
    required this.clientId,
    required this.couponCode,
    required this.planCode,
    required this.planName,
    required this.durationMonths,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.status,
    required this.activatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPlanModel.fromJson(Map<String, dynamic> json) {
    return UserPlanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      dieticianId: json['dietician_id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      couponCode: json['coupon_code']?.toString() ?? '',
      planCode: json['plan_code']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? '',
      durationMonths: int.tryParse(json['duration_months'].toString()) ?? 0,
      subscriptionStartDate:
      json['subscription_start_date']?.toString() ?? '',
      subscriptionEndDate:
      json['subscription_end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      activatedAt: json['activated_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dietician_id': dieticianId,
      'profile_id': profileId,
      'client_id': clientId,
      'coupon_code': couponCode,
      'plan_code': planCode,
      'plan_name': planName,
      'duration_months': durationMonths,
      'subscription_start_date': subscriptionStartDate,
      'subscription_end_date': subscriptionEndDate,
      'status': status,
      'activated_at': activatedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}