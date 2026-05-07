class ActivateCouponResponse {
  final bool status;
  final String message;
  final ActivateCouponData? data;

  ActivateCouponResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ActivateCouponResponse.fromJson(Map<String, dynamic> json) {
    return ActivateCouponResponse(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null
          ? ActivateCouponData.fromJson(json["data"] as Map<String, dynamic>)
          : null,
    );
  }
}

class ActivateCouponData {
  final int? subscriptionId;
  final String? profileId;
  final int? clientId;
  final String? dieticianId;
  final String? couponCode;
  final String? planCode;
  final String? planName;
  final int? durationMonths;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String? subscriptionStatus;

  ActivateCouponData({
    this.subscriptionId,
    this.profileId,
    this.clientId,
    this.dieticianId,
    this.couponCode,
    this.planCode,
    this.planName,
    this.durationMonths,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionStatus,
  });

  factory ActivateCouponData.fromJson(Map<String, dynamic> json) {
    return ActivateCouponData(
      subscriptionId: _toInt(json["subscription_id"]),
      profileId: json["profile_id"]?.toString(),
      clientId: _toInt(json["client_id"]),
      dieticianId: json["dietician_id"]?.toString(),
      couponCode: json["coupon_code"]?.toString(),
      planCode: json["plan_code"]?.toString(),
      planName: json["plan_name"]?.toString(),
      durationMonths: _toInt(json["duration_months"]),
      subscriptionStartDate: json["subscription_start_date"]?.toString(),
      subscriptionEndDate: json["subscription_end_date"]?.toString(),
      subscriptionStatus: json["subscription_status"]?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}