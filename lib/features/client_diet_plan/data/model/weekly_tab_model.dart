class WeeklyTabResponse {
  final bool status;
  final String message;
  final String profileId;
  final String dietitianId;
  final int totalWeeks;
  final List<WeeklyTabModel> data;

  WeeklyTabResponse({
    required this.status,
    required this.message,
    required this.profileId,
    required this.dietitianId,
    required this.totalWeeks,
    required this.data,
  });

  factory WeeklyTabResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyTabResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      dietitianId: json['dietitian_id']?.toString() ?? '',
      totalWeeks: int.tryParse(json['total_weeks'].toString()) ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => WeeklyTabModel.fromJson(e))
          .toList(),
    );
  }
}

class WeeklyTabModel {
  final int id;
  final int weekNoInMonth;
  final String weekLabel;
  final String monthLabel;
  final String dietitianId;
  final String profileId;
  final String weekStartDate;
  final String weekEndDate;
  final String weekRange;
  final int monthNo;
  final int yearNo;
  final String createdAt;
  final String updatedAt;

  WeeklyTabModel({
    required this.id,
    required this.weekNoInMonth,
    required this.weekLabel,
    required this.monthLabel,
    required this.dietitianId,
    required this.profileId,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.weekRange,
    required this.monthNo,
    required this.yearNo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyTabModel.fromJson(Map<String, dynamic> json) {
    return WeeklyTabModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      weekNoInMonth: int.tryParse(json['week_no_in_month'].toString()) ?? 0,
      weekLabel: json['week_label']?.toString() ?? '',
      monthLabel: json['month_label']?.toString() ?? '',
      dietitianId: json['dietitian_id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      weekStartDate: json['week_start_date']?.toString() ?? '',
      weekEndDate: json['week_end_date']?.toString() ?? '',
      weekRange: json['week_range']?.toString() ?? '',
      monthNo: int.tryParse(json['month_no'].toString()) ?? 0,
      yearNo: int.tryParse(json['year_no'].toString()) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}