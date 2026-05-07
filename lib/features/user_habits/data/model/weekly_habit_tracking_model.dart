// lib/models/weekly_habit_tracking_model.dart

/// Status values for daily tracking (weekly section)
class TrackingStatus {
  static const int notCompleted = 0;
  static const int completed = 1;
  static const int future = 2;
}

/// Status values for all-time tracking section
class AllTimeStatus {
  static const int tracked = 1;
  static const int notTracked = -1;
}

/// Root response model
class WeeklyHabitTrackingResponse {
  final String status;
  final int httpCode;
  final String? timestamp;
  final String? message;
  final String? errorCode;

  // Success payload
  final String? profileId;
  final int? levelId;
  final String? weekStart;
  final String? weekEnd;
  final String? today;
  final int totalHabits;
  final WeekSummary? weekSummary;
  final List<HabitItem> habits;

  WeeklyHabitTrackingResponse({
    required this.status,
    required this.httpCode,
    this.timestamp,
    this.message,
    this.errorCode,
    this.profileId,
    this.levelId,
    this.weekStart,
    this.weekEnd,
    this.today,
    this.totalHabits = 0,
    this.weekSummary,
    this.habits = const [],
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
  bool get hasHabits => habits.isNotEmpty;

  factory WeeklyHabitTrackingResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyHabitTrackingResponse(
      status: json['status']?.toString() ?? 'error',
      httpCode: _toInt(json['http_code']) ?? 0,
      timestamp: json['timestamp']?.toString(),
      message: json['message']?.toString(),
      errorCode: json['error_code']?.toString(),
      profileId: json['profile_id']?.toString(),
      levelId: _toInt(json['level_id']),
      weekStart: json['week_start']?.toString(),
      weekEnd: json['week_end']?.toString(),
      today: json['today']?.toString(),
      totalHabits: _toInt(json['total_habits']) ?? 0,
      weekSummary: json['week_summary'] != null
          ? WeekSummary.fromJson(Map<String, dynamic>.from(json['week_summary']))
          : null,
      habits: (json['habits'] as List?)
          ?.map((e) => HabitItem.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'http_code': httpCode,
    'timestamp': timestamp,
    'message': message,
    'error_code': errorCode,
    'profile_id': profileId,
    'level_id': levelId,
    'week_start': weekStart,
    'week_end': weekEnd,
    'today': today,
    'total_habits': totalHabits,
    'week_summary': weekSummary?.toJson(),
    'habits': habits.map((e) => e.toJson()).toList(),
  };
}

/// Overall week summary across all habits
class WeekSummary {
  final int completedTotal;
  final int pendingTotal;
  final int futureTotal;
  final int daysPassedTotal;
  final double completionRate; // % over passed days only
  final double weeklyRate;     // % over full 7 days

  WeekSummary({
    required this.completedTotal,
    required this.pendingTotal,
    required this.futureTotal,
    required this.daysPassedTotal,
    required this.completionRate,
    required this.weeklyRate,
  });

  int get total => completedTotal + pendingTotal + futureTotal;

  String get completionRateLabel =>
      '${completionRate.toStringAsFixed(completionRate.truncateToDouble() == completionRate ? 0 : 2)}%';
  String get weeklyRateLabel =>
      '${weeklyRate.toStringAsFixed(weeklyRate.truncateToDouble() == weeklyRate ? 0 : 2)}%';

  factory WeekSummary.fromJson(Map<String, dynamic> json) {
    return WeekSummary(
      completedTotal: _toInt(json['completed_total']) ?? 0,
      pendingTotal: _toInt(json['pending_total']) ?? 0,
      futureTotal: _toInt(json['future_total']) ?? 0,
      daysPassedTotal: _toInt(json['days_passed_total']) ?? 0,
      completionRate: _toDouble(json['completion_rate']) ?? 0.0,
      weeklyRate: _toDouble(json['weekly_rate']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'completed_total': completedTotal,
    'pending_total': pendingTotal,
    'future_total': futureTotal,
    'days_passed_total': daysPassedTotal,
    'completion_rate': completionRate,
    'weekly_rate': weeklyRate,
  };
}

/// Per-habit summary for the week
class HabitWeekSummary {
  final int completed;
  final int pending;
  final int future;
  final int daysPassed;
  final double completionRate; // % over passed days only
  final double weeklyRate;     // % over full 7 days

  HabitWeekSummary({
    required this.completed,
    required this.pending,
    required this.future,
    required this.daysPassed,
    required this.completionRate,
    required this.weeklyRate,
  });

  int get total => completed + pending + future;

  String get completionRateLabel =>
      '${completionRate.toStringAsFixed(completionRate.truncateToDouble() == completionRate ? 0 : 2)}%';
  String get weeklyRateLabel =>
      '${weeklyRate.toStringAsFixed(weeklyRate.truncateToDouble() == weeklyRate ? 0 : 2)}%';

  double get completionProgress => (completionRate / 100).clamp(0.0, 1.0);
  double get weeklyProgress => (weeklyRate / 100).clamp(0.0, 1.0);

  factory HabitWeekSummary.fromJson(Map<String, dynamic> json) {
    return HabitWeekSummary(
      completed: _toInt(json['completed']) ?? 0,
      pending: _toInt(json['pending']) ?? 0,
      future: _toInt(json['future']) ?? 0,
      daysPassed: _toInt(json['days_passed']) ?? 0,
      completionRate: _toDouble(json['completion_rate']) ?? 0.0,
      weeklyRate: _toDouble(json['weekly_rate']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'completed': completed,
    'pending': pending,
    'future': future,
    'days_passed': daysPassed,
    'completion_rate': completionRate,
    'weekly_rate': weeklyRate,
  };
}

/// All-time summary per habit (from start_date to today)
class AllTimeSummary {
  final int totalDays;
  final int trackedDays;
  final int untrackedDays;
  final double completionRate;

  AllTimeSummary({
    required this.totalDays,
    required this.trackedDays,
    required this.untrackedDays,
    required this.completionRate,
  });

  String get completionRateLabel =>
      '${completionRate.toStringAsFixed(completionRate.truncateToDouble() == completionRate ? 0 : 2)}%';

  double get completionProgress => (completionRate / 100).clamp(0.0, 1.0);

  /// Streak ratio for visualization
  bool get hasAnyTracked => trackedDays > 0;

  factory AllTimeSummary.fromJson(Map<String, dynamic> json) {
    return AllTimeSummary(
      totalDays: _toInt(json['total_days']) ?? 0,
      trackedDays: _toInt(json['tracked_days']) ?? 0,
      untrackedDays: _toInt(json['untracked_days']) ?? 0,
      completionRate: _toDouble(json['completion_rate']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_days': totalDays,
    'tracked_days': trackedDays,
    'untracked_days': untrackedDays,
    'completion_rate': completionRate,
  };
}

/// Single day in all-time tracking (status: 1 tracked, -1 not tracked)
class AllTimeTracking {
  final String date;
  final String day;
  final int status; // 1 = tracked, -1 = not tracked
  final int targetCount;
  final int completedCount;

  AllTimeTracking({
    required this.date,
    required this.day,
    required this.status,
    required this.targetCount,
    required this.completedCount,
  });

  bool get isTracked => status == AllTimeStatus.tracked;
  bool get isNotTracked => status == AllTimeStatus.notTracked;

  double get progress {
    if (targetCount <= 0) return 0.0;
    return (completedCount / targetCount).clamp(0.0, 1.0);
  }

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  factory AllTimeTracking.fromJson(Map<String, dynamic> json) {
    return AllTimeTracking(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      status: _toInt(json['status']) ?? -1,
      targetCount: _toInt(json['target_count']) ?? 0,
      completedCount: _toInt(json['completed_count']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'day': day,
    'status': status,
    'target_count': targetCount,
    'completed_count': completedCount,
  };
}

/// Single habit
class HabitItem {
  final int selectedHabitId;
  final int habitId;
  final int levelId;
  final String category;
  final String habitName;
  final String habitDescription;
  final String frequencyType;
  final int targetCount;
  final String targetUnit;
  final String trackingType;
  final int isActive;
  final String? startDate;
  final String? endDate;
  final String selectionStatus;
  final HabitWeekSummary? weekSummary;
  final List<DailyTracking> tracking;

  // NEW — all-time fields
  final AllTimeSummary? allTimeSummary;
  final List<AllTimeTracking> allTimeTracking;

  HabitItem({
    required this.selectedHabitId,
    required this.habitId,
    required this.levelId,
    required this.category,
    required this.habitName,
    required this.habitDescription,
    required this.frequencyType,
    required this.targetCount,
    required this.targetUnit,
    required this.trackingType,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.selectionStatus,
    this.weekSummary,
    this.tracking = const [],
    this.allTimeSummary,
    this.allTimeTracking = const [],
  });

  bool get isActiveBool => isActive == 1;
  bool get isDailyHabit => frequencyType == 'daily';
  bool get isWeeklyHabit => frequencyType == 'weekly';
  bool get isYesNoTracking => trackingType == 'yes_no';
  bool get isCountTracking => trackingType == 'count';
  bool get isValueTracking => trackingType == 'value';

  double get completionRate => weekSummary?.completionRate ?? 0.0;
  double get weeklyRate => weekSummary?.weeklyRate ?? 0.0;
  double get allTimeCompletionRate => allTimeSummary?.completionRate ?? 0.0;

  /// Get weekly tracking for a specific date
  DailyTracking? trackingForDate(String date) {
    try {
      return tracking.firstWhere((t) => t.date == date);
    } catch (_) {
      return null;
    }
  }

  /// Get all-time tracking for a specific date
  AllTimeTracking? allTimeForDate(String date) {
    try {
      return allTimeTracking.firstWhere((t) => t.date == date);
    } catch (_) {
      return null;
    }
  }

  /// Current streak (consecutive tracked days from today going back)
  int get currentStreak {
    if (allTimeTracking.isEmpty) return 0;
    int streak = 0;
    for (int i = allTimeTracking.length - 1; i >= 0; i--) {
      if (allTimeTracking[i].isTracked) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Longest streak ever
  int get longestStreak {
    if (allTimeTracking.isEmpty) return 0;
    int longest = 0;
    int current = 0;
    for (final t in allTimeTracking) {
      if (t.isTracked) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  factory HabitItem.fromJson(Map<String, dynamic> json) {
    return HabitItem(
      selectedHabitId: _toInt(json['selected_habit_id']) ?? 0,
      habitId: _toInt(json['habit_id']) ?? 0,
      levelId: _toInt(json['level_id']) ?? 0,
      category: json['category']?.toString() ?? '',
      habitName: json['habit_name']?.toString() ?? '',
      habitDescription: json['habit_description']?.toString() ?? '',
      frequencyType: json['frequency_type']?.toString() ?? '',
      targetCount: _toInt(json['target_count']) ?? 0,
      targetUnit: json['target_unit']?.toString() ?? '',
      trackingType: json['tracking_type']?.toString() ?? '',
      isActive: _toInt(json['is_active']) ?? 0,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      selectionStatus: json['selection_status']?.toString() ?? '',
      weekSummary: json['week_summary'] != null
          ? HabitWeekSummary.fromJson(
          Map<String, dynamic>.from(json['week_summary']))
          : null,
      tracking: (json['tracking'] as List?)
          ?.map((e) => DailyTracking.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      allTimeSummary: json['all_time_summary'] != null
          ? AllTimeSummary.fromJson(
          Map<String, dynamic>.from(json['all_time_summary']))
          : null,
      allTimeTracking: (json['all_time_tracking'] as List?)
          ?.map((e) =>
          AllTimeTracking.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'selected_habit_id': selectedHabitId,
    'habit_id': habitId,
    'level_id': levelId,
    'category': category,
    'habit_name': habitName,
    'habit_description': habitDescription,
    'frequency_type': frequencyType,
    'target_count': targetCount,
    'target_unit': targetUnit,
    'tracking_type': trackingType,
    'is_active': isActive,
    'start_date': startDate,
    'end_date': endDate,
    'selection_status': selectionStatus,
    'week_summary': weekSummary?.toJson(),
    'tracking': tracking.map((e) => e.toJson()).toList(),
    'all_time_summary': allTimeSummary?.toJson(),
    'all_time_tracking': allTimeTracking.map((e) => e.toJson()).toList(),
  };
}

/// Single day's tracking entry (weekly view)
class DailyTracking {
  final String date;
  final String day;
  final int status; // 0 = not done, 1 = done, 2 = future
  final int targetCount;
  final int completedCount;
  final String? notes;

  DailyTracking({
    required this.date,
    required this.day,
    required this.status,
    required this.targetCount,
    required this.completedCount,
    this.notes,
  });

  bool get isCompleted => status == TrackingStatus.completed;
  bool get isPending => status == TrackingStatus.notCompleted;
  bool get isFuture => status == TrackingStatus.future;

  double get progress {
    if (targetCount <= 0) return 0.0;
    return (completedCount / targetCount).clamp(0.0, 1.0);
  }

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  factory DailyTracking.fromJson(Map<String, dynamic> json) {
    return DailyTracking(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      status: _toInt(json['status']) ?? 0,
      targetCount: _toInt(json['target_count']) ?? 0,
      completedCount: _toInt(json['completed_count']) ?? 0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'day': day,
    'status': status,
    'target_count': targetCount,
    'completed_count': completedCount,
    'notes': notes,
  };
}

// ============================================================
// Safe number parsers
// ============================================================

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.toInt();
  }
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
  return null;
}