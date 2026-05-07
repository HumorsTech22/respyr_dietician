class CheckClientPlanData {
  final String? profileId;
  final int? clientId;
  final String? dieticianId;
  final String? planType;
  final String? planStatus;
  final bool? isFreeTrial;
  final int? subscriptionId;
  final String? couponCode;
  final String? planCode;
  final String? planName;
  final int? durationMonths;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final int? daysLeft;
  final int? trialDays;
  final String? trialStartDate;
  final String? trialEndDate;
  final bool? needsPurchase;

  CheckClientPlanData({
    this.profileId,
    this.clientId,
    this.dieticianId,
    this.planType,
    this.planStatus,
    this.isFreeTrial,
    this.subscriptionId,
    this.couponCode,
    this.planCode,
    this.planName,
    this.durationMonths,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.daysLeft,
    this.trialDays,
    this.trialStartDate,
    this.trialEndDate,
    this.needsPurchase,
  });

  factory CheckClientPlanData.fromJson(Map<String, dynamic> json) {
    return CheckClientPlanData(
      profileId: json["profile_id"]?.toString(),
      clientId: json["client_id"] is int
          ? json["client_id"]
          : int.tryParse(json["client_id"]?.toString() ?? ""),
      dieticianId: json["dietician_id"]?.toString(),
      planType: json["plan_type"]?.toString(),
      planStatus: json["plan_status"]?.toString(),
      isFreeTrial: json["is_free_trial"] == null
          ? null
          : json["is_free_trial"] == true,
      subscriptionId: json["subscription_id"] is int
          ? json["subscription_id"]
          : int.tryParse(json["subscription_id"]?.toString() ?? ""),
      couponCode: json["coupon_code"]?.toString(),
      planCode: json["plan_code"]?.toString(),
      planName: json["plan_name"]?.toString(),
      durationMonths: json["duration_months"] is int
          ? json["duration_months"]
          : int.tryParse(json["duration_months"]?.toString() ?? ""),
      subscriptionStartDate: json["subscription_start_date"]?.toString(),
      subscriptionEndDate: json["subscription_end_date"]?.toString(),
      daysLeft: json["days_left"] is int
          ? json["days_left"]
          : int.tryParse(json["days_left"]?.toString() ?? ""),
      trialDays: json["trial_days"] is int
          ? json["trial_days"]
          : int.tryParse(json["trial_days"]?.toString() ?? ""),
      trialStartDate: json["trial_start_date"]?.toString(),
      trialEndDate: json["trial_end_date"]?.toString(),
      needsPurchase: json["needs_purchase"] == null
          ? null
          : json["needs_purchase"] == true,
    );
  }
}