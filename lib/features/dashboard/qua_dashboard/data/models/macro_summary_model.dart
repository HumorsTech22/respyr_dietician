class MacroSummaryResponse {
  final bool success;
  final String message;
  final String profileId;
  final String selectedDate;
  final MacroData? currentData;
  final MacroData? previousData;
  final MacroChangeFromPrevious? macroChangeFromPrevious;

  MacroSummaryResponse({
    required this.success,
    required this.message,
    required this.profileId,
    required this.selectedDate,
    required this.currentData,
    required this.previousData,
    required this.macroChangeFromPrevious,
  });

  factory MacroSummaryResponse.fromJson(Map<String, dynamic> json) {
    return MacroSummaryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profileId: json['profile_id'] ?? '',
      selectedDate: json['selected_date'] ?? '',
      currentData: json['current_data'] != null
          ? MacroData.fromJson(json['current_data'])
          : null,
      previousData: json['previous_data'] != null
          ? MacroData.fromJson(json['previous_data'])
          : null,
      macroChangeFromPrevious: json['macro_change_from_previous'] != null
          ? MacroChangeFromPrevious.fromJson(json['macro_change_from_previous'])
          : null,
    );
  }
}

class MacroData {
  final int testId;
  final String profileId;
  final String dateTime;
  final FinalMacroSummary finalMacroSummary;
  final MacroPercentage macroPercentage;

  MacroData({
    required this.testId,
    required this.profileId,
    required this.dateTime,
    required this.finalMacroSummary,
    required this.macroPercentage,
  });

  factory MacroData.fromJson(Map<String, dynamic> json) {
    return MacroData(
      testId: int.tryParse(json['test_id'].toString()) ?? 0,
      profileId: json['profile_id'] ?? '',
      dateTime: json['date_time'] ?? '',
      finalMacroSummary: FinalMacroSummary.fromJson(
        json['final_macro_summary'] ?? {},
      ),
      macroPercentage: MacroPercentage.fromJson(
        json['macro_percentage'] ?? {},
      ),
    );
  }
}

class FinalMacroSummary {
  final double calories;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double proteinG;

  FinalMacroSummary({
    required this.calories,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.proteinG,
  });

  factory FinalMacroSummary.fromJson(Map<String, dynamic> json) {
    return FinalMacroSummary(
      calories: double.tryParse(json['calories'].toString()) ?? 0,
      carbsG: double.tryParse(json['carbs_g'].toString()) ?? 0,
      fatG: double.tryParse(json['fat_g'].toString()) ?? 0,
      fiberG: double.tryParse(json['fiber_g'].toString()) ?? 0,
      proteinG: double.tryParse(json['protein_g'].toString()) ?? 0,
    );
  }
}

class MacroPercentage {
  final double carbsPercent;
  final double fatPercent;
  final double proteinPercent;
  final double fiberPercent;

  MacroPercentage({
    required this.carbsPercent,
    required this.fatPercent,
    required this.proteinPercent,
    required this.fiberPercent,
  });

  factory MacroPercentage.fromJson(Map<String, dynamic> json) {
    return MacroPercentage(
      carbsPercent: double.tryParse(json['carbs_percent'].toString()) ?? 0,
      fatPercent: double.tryParse(json['fat_percent'].toString()) ?? 0,
      proteinPercent: double.tryParse(json['protein_percent'].toString()) ?? 0,
      fiberPercent: double.tryParse(json['fiber_percent'].toString()) ?? 0,
    );
  }
}

class MacroChangeFromPrevious {
  final MacroChange calories;
  final MacroChange carbsG;
  final MacroChange fatG;
  final MacroChange fiberG;
  final MacroChange proteinG;

  MacroChangeFromPrevious({
    required this.calories,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.proteinG,
  });

  factory MacroChangeFromPrevious.fromJson(Map<String, dynamic> json) {
    return MacroChangeFromPrevious(
      calories: MacroChange.fromJson(json['calories'] ?? {}),
      carbsG: MacroChange.fromJson(json['carbs_g'] ?? {}),
      fatG: MacroChange.fromJson(json['fat_g'] ?? {}),
      fiberG: MacroChange.fromJson(json['fiber_g'] ?? {}),
      proteinG: MacroChange.fromJson(json['protein_g'] ?? {}),
    );
  }
}

class MacroChange {
  final double changePercent;
  final String changeType;

  MacroChange({
    required this.changePercent,
    required this.changeType,
  });

  factory MacroChange.fromJson(Map<String, dynamic> json) {
    return MacroChange(
      changePercent: double.tryParse(json['change_percent'].toString()) ?? 0,
      changeType: json['change_type'] ?? 'no_change',
    );
  }
}