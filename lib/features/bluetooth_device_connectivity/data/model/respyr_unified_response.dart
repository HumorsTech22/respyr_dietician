class RespyrUnifiedResponse {
  final String dateTime;
  final MetabolismScoreAnalysis metabolismScoreAnalysis;
  final UnifiedPrimaryTrend primaryTrend;
  final DayFocus dayFocus;
  final EnergyInfo energy;
  final String trainerMacroRationale;
  final String trainerNote;
  final String trainingDirection;
  final String userKeyHint;
  final String wellnessNote;

  RespyrUnifiedResponse({
    required this.dateTime,
    required this.metabolismScoreAnalysis,
    required this.primaryTrend,
    required this.dayFocus,
    required this.energy,
    required this.trainerMacroRationale,
    required this.trainerNote,
    required this.trainingDirection,
    required this.userKeyHint,
    required this.wellnessNote,
  });

  factory RespyrUnifiedResponse.fromJson(Map<String, dynamic> json) {
    final fatTrendJson = _asMap(json['Fat_Use_Pattern_trend']);
    final muscleTrendJson = _asMap(json['Muscle_Gain_Trend']);
    final energyJson = _asMap(json['energy']);

    return RespyrUnifiedResponse(
      dateTime: (json['date_time'] ?? '').toString(),
      metabolismScoreAnalysis: MetabolismScoreAnalysis.fromJson(
        _asMap(json['Metabolism_Score_Analysis']),
      ),
      primaryTrend: UnifiedPrimaryTrend.fromJson(
        fatTrendJson: fatTrendJson,
        muscleTrendJson: muscleTrendJson,
        mode: (energyJson['mode'] ?? '').toString(),
      ),
      dayFocus: DayFocus.fromJson(_asMap(json['day_focus'])),
      energy: EnergyInfo.fromJson(energyJson),
      trainerMacroRationale: (json['trainer_macro_rationale'] ?? '').toString(),
      trainerNote: (json['trainer_note'] ?? '').toString(),
      trainingDirection: (json['training_direction'] ?? '').toString(),
      userKeyHint: (json['user_key_hint'] ?? '').toString(),
      wellnessNote: (json['wellness_note'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_time': dateTime,
      'Metabolism_Score_Analysis': metabolismScoreAnalysis.toJson(),
      ...primaryTrend.toJson(),
      'day_focus': dayFocus.toJson(),
      'energy': energy.toJson(),
      'trainer_macro_rationale': trainerMacroRationale,
      'trainer_note': trainerNote,
      'training_direction': trainingDirection,
      'user_key_hint': userKeyHint,
      'wellness_note': wellnessNote,
    };
  }
}

class UnifiedPrimaryTrend {
  final String trendKey;
  final String screenTitle;
  final InterpretationBlock clientInterpretation;
  final InterpretationBlock scientificInterpretation;
  final double score;
  final String zone;
  final bool diabeticAdjustmentApplied;

  UnifiedPrimaryTrend({
    required this.trendKey,
    required this.screenTitle,
    required this.clientInterpretation,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
    required this.diabeticAdjustmentApplied,
  });

  factory UnifiedPrimaryTrend.fromJson({
    Map<String, dynamic>? fatTrendJson,
    Map<String, dynamic>? muscleTrendJson,
    String? mode,
  }) {
    final fat = fatTrendJson ?? <String, dynamic>{};
    final muscle = muscleTrendJson ?? <String, dynamic>{};

    final fatScore = _asDouble(fat['score']);
    final muscleScore = _asDouble(muscle['score']);
    final normalizedMode = (mode ?? '').toLowerCase().trim();

    bool useFat;

    if (normalizedMode == 'fat_loss' || normalizedMode == 'weight_loss') {
      useFat = fatScore > 0;
    } else if (normalizedMode == 'muscle_gain') {
      useFat = false;
    } else {
      if (fatScore > 0 && muscleScore <= 0) {
        useFat = true;
      } else if (muscleScore > 0) {
        useFat = false;
      } else {
        useFat = fat.isNotEmpty && muscle.isEmpty;
      }
    }

    final source = useFat ? fat : muscle;

    return UnifiedPrimaryTrend(
      trendKey: useFat ? 'Fat_Use_Pattern_trend' : 'Muscle_Gain_Trend',
      screenTitle: useFat ? 'Fat-Use Pattern Trend' : 'Muscle-Gain Trend',
      clientInterpretation: InterpretationBlock.fromJson(
        _asMap(source['client_interpretation']),
      ),
      scientificInterpretation: InterpretationBlock.fromJson(
        _asMap(source['scientific_interpretation']),
      ),
      score: _asDouble(source['score']),
      zone: (source['zone'] ?? '').toString(),
      diabeticAdjustmentApplied: source['diabetic_adjustment_applied'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      trendKey: {
        'client_interpretation': clientInterpretation.toJson(),
        'scientific_interpretation': scientificInterpretation.toJson(),
        'score': score,
        'zone': zone,
        'diabetic_adjustment_applied': diabeticAdjustmentApplied,
      }
    };
  }
}

class InterpretationBlock {
  final String title;
  final String text;

  InterpretationBlock({
    required this.title,
    required this.text,
  });

  factory InterpretationBlock.fromJson(Map<String, dynamic> json) {
    return InterpretationBlock(
      title: (json['title'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
    };
  }
}

class MetabolismScoreAnalysis {
  final TrendDetail digestiveActivityTrend;
  final TrendDetail energySourceTrend;
  final TrendDetail fuelUtilizationTrend;
  final TrendDetail metabolicLoadTrend;
  final TrendDetail nutrientUtilizationTrend;
  final TrendDetail recoveryActivityTrend;
  final Map<String, String> metabolismScoreSummary;

  MetabolismScoreAnalysis({
    required this.digestiveActivityTrend,
    required this.energySourceTrend,
    required this.fuelUtilizationTrend,
    required this.metabolicLoadTrend,
    required this.nutrientUtilizationTrend,
    required this.recoveryActivityTrend,
    required this.metabolismScoreSummary,
  });

  factory MetabolismScoreAnalysis.fromJson(Map<String, dynamic> json) {
    return MetabolismScoreAnalysis(
      digestiveActivityTrend: TrendDetail.fromJson(
        _asMap(json['Digestive_Activity_Trend']),
      ),
      energySourceTrend: TrendDetail.fromJson(
        _asMap(json['Energy_Source_Trend']),
      ),
      fuelUtilizationTrend: TrendDetail.fromJson(
        _asMap(json['Fuel_Utilization_Trend']),
      ),
      metabolicLoadTrend: TrendDetail.fromJson(
        _asMap(json['Metabolic_Load_Trend']),
      ),
      nutrientUtilizationTrend: TrendDetail.fromJson(
        _asMap(json['Nutrient_Utilization_Trend']),
      ),
      recoveryActivityTrend: TrendDetail.fromJson(
        _asMap(json['Recovery_Activity_Trend']),
      ),
      metabolismScoreSummary: _asStringMap(json['metabolism_score_summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Digestive_Activity_Trend': digestiveActivityTrend.toJson(),
      'Energy_Source_Trend': energySourceTrend.toJson(),
      'Fuel_Utilization_Trend': fuelUtilizationTrend.toJson(),
      'Metabolic_Load_Trend': metabolicLoadTrend.toJson(),
      'Nutrient_Utilization_Trend': nutrientUtilizationTrend.toJson(),
      'Recovery_Activity_Trend': recoveryActivityTrend.toJson(),
      'metabolism_score_summary': metabolismScoreSummary,
    };
  }
}

class TrendDetail {
  final String clientState;
  final String interpretation;
  final String intervention;
  final String whatIsThisScore;
  final double score;
  final String zone;

  TrendDetail({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.whatIsThisScore,
    required this.score,
    required this.zone,
  });

  factory TrendDetail.fromJson(Map<String, dynamic> json) {
    return TrendDetail(
      clientState: (json['client_state'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      whatIsThisScore: (json['what_is_this_score'] ?? '').toString(),
      score: _asDouble(json['score']),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_state': clientState,
      'interpretation': interpretation,
      'intervention': intervention,
      'what_is_this_score': whatIsThisScore,
      'score': score,
      'zone': zone,
    };
  }
}

class DayFocus {
  final String title;
  final String note;
  final List<String> whatToDo;
  final List<String> avoidToday;
  final String whyToday;

  DayFocus({
    required this.title,
    required this.note,
    required this.whatToDo,
    required this.avoidToday,
    required this.whyToday,
  });

  factory DayFocus.fromJson(Map<String, dynamic> json) {
    return DayFocus(
      title: (json['title'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      whatToDo: _asStringList(json['what_to_do']),
      avoidToday: _asStringList(json['avoid_today']),
      whyToday: (json['why_today'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'note': note,
      'what_to_do': whatToDo,
      'avoid_today': avoidToday,
      'why_today': whyToday,
    };
  }
}

class EnergyInfo {
  final String activity;
  final int bmrKcal;
  final String mode;
  final int targetKcal;
  final int tdeeKcal;

  EnergyInfo({
    required this.activity,
    required this.bmrKcal,
    required this.mode,
    required this.targetKcal,
    required this.tdeeKcal,
  });

  factory EnergyInfo.fromJson(Map<String, dynamic> json) {
    return EnergyInfo(
      activity: (json['activity'] ?? '').toString(),
      bmrKcal: _asInt(json['bmr_kcal']),
      mode: (json['mode'] ?? '').toString(),
      targetKcal: _asInt(json['target_kcal']),
      tdeeKcal: _asInt(json['tdee_kcal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity': activity,
      'bmr_kcal': bmrKcal,
      'mode': mode,
      'target_kcal': targetKcal,
      'tdee_kcal': tdeeKcal,
    };
  }
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map) {
    return Map<String, dynamic>.from(v);
  }
  return <String, dynamic>{};
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

Map<String, String> _asStringMap(dynamic v) {
  if (v is Map) {
    return Map<String, dynamic>.from(v).map(
          (key, value) => MapEntry(key.toString(), (value ?? '').toString()),
    );
  }
  return <String, String>{};
}

List<String> _asStringList(dynamic v) {
  if (v is List) {
    return List<dynamic>.from(v).map((e) => (e ?? '').toString()).toList();
  }
  return <String>[];
}