class ClientHabitStatusResponse {
  final bool status;
  final String message;
  final String profileId;
  final String trackingDate;
  final String weekStart;
  final String weekEnd;

  final int totalHabits;
  final int trackedHabits;
  final int notTrackedHabits;
  final int completedHabits;
  final int pendingHabits;

  final List<ClientHabitData> data;

  ClientHabitStatusResponse({
    required this.status,
    required this.message,
    required this.profileId,
    required this.trackingDate,
    required this.weekStart,
    required this.weekEnd,
    required this.totalHabits,
    required this.trackedHabits,
    required this.notTrackedHabits,
    required this.completedHabits,
    required this.pendingHabits,
    required this.data,
  });

  factory ClientHabitStatusResponse.fromJson(Map<String, dynamic> json) {
    return ClientHabitStatusResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      profileId: json['profile_id'] ?? '',
      trackingDate: json['tracking_date'] ?? '',
      weekStart: json['week_start'] ?? '',
      weekEnd: json['week_end'] ?? '',
      totalHabits: json['total_habits'] ?? 0,
      trackedHabits: json['tracked_habits'] ?? 0,
      notTrackedHabits: json['not_tracked_habits'] ?? 0,
      completedHabits: json['completed_habits'] ?? 0,
      pendingHabits: json['pending_habits'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ClientHabitData.fromJson(e))
          .toList(),
    );
  }

  ClientHabitStatusResponse copyWith({
    bool? status,
    String? message,
    String? profileId,
    String? trackingDate,
    String? weekStart,
    String? weekEnd,
    int? totalHabits,
    int? trackedHabits,
    int? notTrackedHabits,
    int? completedHabits,
    int? pendingHabits,
    List<ClientHabitData>? data,
  }) {
    return ClientHabitStatusResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      profileId: profileId ?? this.profileId,
      trackingDate: trackingDate ?? this.trackingDate,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      totalHabits: totalHabits ?? this.totalHabits,
      trackedHabits: trackedHabits ?? this.trackedHabits,
      notTrackedHabits: notTrackedHabits ?? this.notTrackedHabits,
      completedHabits: completedHabits ?? this.completedHabits,
      pendingHabits: pendingHabits ?? this.pendingHabits,
      data: data ?? this.data,
    );
  }

  factory ClientHabitStatusResponse.empty() {
    return ClientHabitStatusResponse(
      status: false,
      message: '',
      profileId: '',
      trackingDate: '',
      weekStart: '',
      weekEnd: '',
      totalHabits: 0,
      trackedHabits: 0,
      notTrackedHabits: 0,
      completedHabits: 0,
      pendingHabits: 0,
      data: [],
    );
  }
}

class ClientHabitData {
  final int selectedHabitId;
  final String profileId;
  final int habitId;
  final int levelId;

  final String category;
  final String habitName;
  final String habitDescription;

  final String frequencyType;
  final int targetCount;
  final String targetUnit;
  final String trackingType;

  final String selectedDate;
  final String? weekStart;
  final String? weekEnd;
  final String trackingDate;

  final int completedCount;
  final int requiredCount;

  final bool isTracked;
  final String trackedStatus;

  final int isCompleted;
  final String completionStatus;

  final String? notes;
  final String selectedStatus;
  final String startDate;

  ClientHabitData({
    required this.selectedHabitId,
    required this.profileId,
    required this.habitId,
    required this.levelId,
    required this.category,
    required this.habitName,
    required this.habitDescription,
    required this.frequencyType,
    required this.targetCount,
    required this.targetUnit,
    required this.trackingType,
    required this.selectedDate,
    required this.weekStart,
    required this.weekEnd,
    required this.trackingDate,
    required this.completedCount,
    required this.requiredCount,
    required this.isTracked,
    required this.trackedStatus,
    required this.isCompleted,
    required this.completionStatus,
    required this.notes,
    required this.selectedStatus,
    required this.startDate,
  });

  factory ClientHabitData.fromJson(Map<String, dynamic> json) {
    return ClientHabitData(
      selectedHabitId: json['selected_habit_id'] ?? 0,
      profileId: json['profile_id'] ?? '',
      habitId: json['habit_id'] ?? 0,
      levelId: json['level_id'] ?? 0,
      category: json['category'] ?? '',
      habitName: json['habit_name'] ?? '',
      habitDescription: json['habit_description'] ?? '',
      frequencyType: json['frequency_type'] ?? '',
      targetCount: json['target_count'] ?? 0,
      targetUnit: json['target_unit'] ?? '',
      trackingType: json['tracking_type'] ?? '',
      selectedDate: json['selected_date'] ?? '',
      weekStart: json['week_start'],
      weekEnd: json['week_end'],
      trackingDate: json['tracking_date'] ?? '',
      completedCount: json['completed_count'] ?? 0,
      requiredCount: json['required_count'] ?? 0,
      isTracked: json['is_tracked'] ?? false,
      trackedStatus: json['tracked_status'] ?? '',
      isCompleted: json['is_completed'] ?? 0,
      completionStatus: json['completion_status'] ?? '',
      notes: json['notes'],
      selectedStatus: json['selected_status'] ?? '',
      startDate: json['start_date'] ?? '',
    );
  }

  bool get completed => isCompleted == 1;
  bool get pending => completionStatus == 'pending';
  bool get weekly => frequencyType == 'weekly';
  bool get daily => frequencyType == 'daily';
}