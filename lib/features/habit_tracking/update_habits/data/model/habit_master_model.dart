class HabitMasterResponse {
  final bool status;
  final String message;
  final int levelId;
  final Map<String, List<HabitMasterData>> data;

  HabitMasterResponse({
    required this.status,
    required this.message,
    required this.levelId,
    required this.data,
  });

  factory HabitMasterResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as Map<String, dynamic>? ?? {};

    final parsedData = rawData.map((category, habits) {
      return MapEntry(
        category,
        (habits as List<dynamic>? ?? [])
            .map((e) => HabitMasterData.fromJson(e))
            .toList(),
      );
    });

    return HabitMasterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      levelId: json['level_id'] ?? 0,
      data: parsedData,
    );
  }
}

class HabitMasterData {
  final int id;
  final int levelId;
  final String habitName;
  final String habitDescription;
  final String frequencyType;
  final int targetCount;
  final String targetUnit;
  final String trackingType;
  final int sortOrder;

  HabitMasterData({
    required this.id,
    required this.levelId,
    required this.habitName,
    required this.habitDescription,
    required this.frequencyType,
    required this.targetCount,
    required this.targetUnit,
    required this.trackingType,
    required this.sortOrder,
  });

  factory HabitMasterData.fromJson(Map<String, dynamic> json) {
    return HabitMasterData(
      id: json['id'] ?? 0,
      levelId: json['level_id'] ?? 0,
      habitName: json['habit_name'] ?? '',
      habitDescription: json['habit_description'] ?? '',
      frequencyType: json['frequency_type'] ?? '',
      targetCount: json['target_count'] ?? 0,
      targetUnit: json['target_unit'] ?? '',
      trackingType: json['tracking_type'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}