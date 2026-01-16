import 'package:equatable/equatable.dart';
import 'dart:convert';

class LatestTestData extends Equatable {
  final String testId;
  final String dietitianId;
  final String profileId;
  final String dietPlanId;

  final double? absorptiveMetabolismScore;
  final double? fermentativeMetabolismScore;
  final double? fatMetabolismScore;
  final double? glucoseMetabolismScore;
  final double? hepaticStressMetabolismScore;
  final double? detoxificationMetabolismScore;
  final double? fatLossMetabolismScore;

  final double? acetonePpm;
  final double? h2Ppm;
  final double? ethanolPpm;

  final String dateTime;

  // New fields for parsed test_json
  final TestJsonData? testJsonData;
  final String rawTestJson;
  final double? minRange;
  final double? maxRange;

  const LatestTestData({
    required this.testId,
    required this.dietitianId,
    required this.profileId,
    required this.dietPlanId,
    required this.absorptiveMetabolismScore,
    required this.fermentativeMetabolismScore,
    required this.fatMetabolismScore,
    required this.glucoseMetabolismScore,
    required this.hepaticStressMetabolismScore,
    required this.detoxificationMetabolismScore,
    required this.fatLossMetabolismScore,
    required this.acetonePpm,
    required this.h2Ppm,
    required this.ethanolPpm,
    required this.dateTime,
    required this.testJsonData,
    required this.rawTestJson, required this.minRange, required this.maxRange,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory LatestTestData.fromJson(Map<String, dynamic> json) {
    final rawTestJson = (json['test_json'] ?? '').toString();
    TestJsonData? testJsonData;

    // Try to parse the nested JSON
    if (rawTestJson.isNotEmpty) {
      try {
        final parsedJson = jsonDecode(rawTestJson) as Map<String, dynamic>;
        testJsonData = TestJsonData.fromJson(parsedJson);
      } catch (e) {
        // If parsing fails, testJsonData will remain null
        print('Error parsing test_json: $e');
      }
    }

    return LatestTestData(
      testId: (json['test_id'] ?? '').toString(),
      dietitianId: (json['dietitian_id'] ?? '').toString(),
      profileId: (json['profile_id'] ?? '').toString(),
      dietPlanId: (json['diet_plan_id'] ?? '').toString(),
      absorptiveMetabolismScore: _toDouble(json['absorptive_metabolism_score']),
      fermentativeMetabolismScore: _toDouble(json['fermentative_metabolism_score']),
      fatMetabolismScore: _toDouble(json['fat_metabolism_score']),
      glucoseMetabolismScore: _toDouble(json['glucose_metabolism_score']),
      hepaticStressMetabolismScore: _toDouble(json['hepatic_stress_metabolism_score']),
      detoxificationMetabolismScore: _toDouble(json['detoxification_metabolism_score']),
      fatLossMetabolismScore: _toDouble(json['fat_loss_metabolism_score']),
      acetonePpm: _toDouble(json['acetone_ppm']),
      h2Ppm: _toDouble(json['h2_ppm']),
      ethanolPpm: _toDouble(json['ethanol_ppm']),
      dateTime: (json['date_time'] ?? '').toString(),
      testJsonData: testJsonData,
      rawTestJson: rawTestJson, minRange:  _toDouble(json['min_range']), maxRange:  _toDouble(json['max_range']),
    );
  }

  @override
  List<Object?> get props => [
    testId,
    dietitianId,
    profileId,
    dietPlanId,
    absorptiveMetabolismScore,
    fermentativeMetabolismScore,
    fatMetabolismScore,
    glucoseMetabolismScore,
    hepaticStressMetabolismScore,
    detoxificationMetabolismScore,
    fatLossMetabolismScore,
    acetonePpm,
    h2Ppm,
    ethanolPpm,
    dateTime,
    testJsonData,
    rawTestJson,
    minRange,
    maxRange,
  ];
}

// New models for nested test_json structure
class TestJsonData extends Equatable {
  final MetabolismScoreAnalysis? metabolismScoreAnalysis;
  final BreathMarkerAnalysis? breathMarkerAnalysis;
  final FatLossMetabolismScore? fatLossMetabolismScore;
  final String? categoryClusters;
  final String? foodLevelEvaluation;
  final String? mode;
  final String? nonAdherenceWarning;
  final String? overallInterpretation;
  final String? recommendedIntervention;
  final String? systemStrainSummary;
  final String? weeklyFoodPerformance;

  const TestJsonData({
    this.metabolismScoreAnalysis,
    this.breathMarkerAnalysis,
    this.fatLossMetabolismScore,
    this.categoryClusters,
    this.foodLevelEvaluation,
    this.mode,
    this.nonAdherenceWarning,
    this.overallInterpretation,
    this.recommendedIntervention,
    this.systemStrainSummary,
    this.weeklyFoodPerformance,
  });

  factory TestJsonData.fromJson(Map<String, dynamic> json) {
    return TestJsonData(
      metabolismScoreAnalysis: json['Metabolism_Score_Analysis'] != null
          ? MetabolismScoreAnalysis.fromJson(
          json['Metabolism_Score_Analysis'] as Map<String, dynamic>)
          : null,
      breathMarkerAnalysis: json['breath_marker_analysis'] != null
          ? BreathMarkerAnalysis.fromJson(
          json['breath_marker_analysis'] as Map<String, dynamic>)
          : null,
      fatLossMetabolismScore: json['fat_loss_metabolism_score'] != null
          ? FatLossMetabolismScore.fromJson(
          json['fat_loss_metabolism_score'] as Map<String, dynamic>)
          : null,
      categoryClusters: json['category_clusters'] as String?,
      foodLevelEvaluation: json['food_level_evaluation'] as String?,
      mode: json['mode'] as String?,
      nonAdherenceWarning: json['non_adherence_warning'] as String?,
      overallInterpretation: json['overall_interpretation'] as String?,
      recommendedIntervention: json['recommended_intervention'] as String?,
      systemStrainSummary: json['system_strain_summary'] as String?,
      weeklyFoodPerformance: json['weekly_food_performance'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    metabolismScoreAnalysis,
    breathMarkerAnalysis,
    fatLossMetabolismScore,
    categoryClusters,
    foodLevelEvaluation,
    mode,
    nonAdherenceWarning,
    overallInterpretation,
    recommendedIntervention,
    systemStrainSummary,
    weeklyFoodPerformance,
  ];
}

class MetabolismScoreAnalysis extends Equatable {
  final MetabolismScore absorption;
  final MetabolismScore detoxification;
  final MetabolismScore fatMetabolism;
  final MetabolismScore fermentation;
  final MetabolismScore glucoseMetabolism;
  final MetabolismScore hepaticStress;
  final MetabolismScoreSummary? metabolismScoreSummary;

  const MetabolismScoreAnalysis({
    required this.absorption,
    required this.detoxification,
    required this.fatMetabolism,
    required this.fermentation,
    required this.glucoseMetabolism,
    required this.hepaticStress,
    this.metabolismScoreSummary,
  });

  factory MetabolismScoreAnalysis.fromJson(Map<String, dynamic> json) {
    return MetabolismScoreAnalysis(
      absorption: MetabolismScore.fromJson(json['absorption'] as Map<String, dynamic>),
      detoxification: MetabolismScore.fromJson(json['detoxification'] as Map<String, dynamic>),
      fatMetabolism: MetabolismScore.fromJson(json['fat_metabolism'] as Map<String, dynamic>),
      fermentation: MetabolismScore.fromJson(json['fermentation'] as Map<String, dynamic>),
      glucoseMetabolism: MetabolismScore.fromJson(json['glucose_metabolism'] as Map<String, dynamic>),
      hepaticStress: MetabolismScore.fromJson(json['hepatic_stress'] as Map<String, dynamic>),
      metabolismScoreSummary: json['metabolism_score_summary'] != null
          ? MetabolismScoreSummary.fromJson(
          json['metabolism_score_summary'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    absorption,
    detoxification,
    fatMetabolism,
    fermentation,
    glucoseMetabolism,
    hepaticStress,
    metabolismScoreSummary,
  ];
}

class MetabolismScore extends Equatable {
  final String clientState;
  final String interpretation;
  final String intervention;
  final String ppmNote;
  final double score;
  final String whatIsThisScore;
  final String zone;

  const MetabolismScore({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.ppmNote,
    required this.score,
    required this.whatIsThisScore,
    required this.zone,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      try {
        return double.tryParse(v);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory MetabolismScore.fromJson(Map<String, dynamic> json) {
    return MetabolismScore(
      clientState: (json['client_state'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      ppmNote: (json['ppm_note'] ?? '').toString(),
      score: _toDouble(json['score']) ?? 0.0,
      whatIsThisScore: (json['what_is_this_score'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    clientState,
    interpretation,
    intervention,
    ppmNote,
    score,
    whatIsThisScore,
    zone,
  ];
}

class MetabolismScoreSummary extends Equatable {
  final String absorptiveScore;
  final String detoxificationScore;
  final String fatMetabolismScore;
  final String fermentativeScore;
  final String glucoseMetabolismScore;
  final String hepaticStressScore;

  const MetabolismScoreSummary({
    required this.absorptiveScore,
    required this.detoxificationScore,
    required this.fatMetabolismScore,
    required this.fermentativeScore,
    required this.glucoseMetabolismScore,
    required this.hepaticStressScore,
  });

  factory MetabolismScoreSummary.fromJson(Map<String, dynamic> json) {
    return MetabolismScoreSummary(
      absorptiveScore: (json['Absorptive Score'] ?? '').toString(),
      detoxificationScore: (json['Detoxification Score'] ?? '').toString(),
      fatMetabolismScore: (json['Fat Metabolism Score'] ?? '').toString(),
      fermentativeScore: (json['Fermentative Score'] ?? '').toString(),
      glucoseMetabolismScore: (json['Glucose Metabolism Score'] ?? '').toString(),
      hepaticStressScore: (json['Hepatic Stress Score'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    absorptiveScore,
    detoxificationScore,
    fatMetabolismScore,
    fermentativeScore,
    glucoseMetabolismScore,
    hepaticStressScore,
  ];
}

class BreathMarkerAnalysis extends Equatable {
  final BreathMarker acetone;
  final BreathMarker ethanol;
  final BreathMarker hydrogen;

  const BreathMarkerAnalysis({
    required this.acetone,
    required this.ethanol,
    required this.hydrogen,
  });

  factory BreathMarkerAnalysis.fromJson(Map<String, dynamic> json) {
    return BreathMarkerAnalysis(
      acetone: BreathMarker.fromJson(json['acetone'] as Map<String, dynamic>),
      ethanol: BreathMarker.fromJson(json['ethanol'] as Map<String, dynamic>),
      hydrogen: BreathMarker.fromJson(json['hydrogen'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [acetone, ethanol, hydrogen];
}

class BreathMarker extends Equatable {
  final MarkerAdvice advice;
  final bool diabetic;
  final String dietitianFocus;
  final String fatLossPossible;
  final String interpretation;
  final String intervention;
  final String marker;
  final double ppm;
  final MarkerRatios ratios;
  final String userGoal;
  final String zone;

  const BreathMarker({
    required this.advice,
    required this.diabetic,
    required this.dietitianFocus,
    required this.fatLossPossible,
    required this.interpretation,
    required this.intervention,
    required this.marker,
    required this.ppm,
    required this.ratios,
    required this.userGoal,
    required this.zone,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      try {
        return double.tryParse(v);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory BreathMarker.fromJson(Map<String, dynamic> json) {
    return BreathMarker(
      advice: MarkerAdvice.fromJson(json['advice'] as Map<String, dynamic>),
      diabetic: (json['diabetic'] ?? false) as bool,
      dietitianFocus: (json['dietitian_focus'] ?? '').toString(),
      fatLossPossible: (json['fat_loss_possible'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      marker: (json['marker'] ?? '').toString(),
      ppm: _toDouble(json['ppm']) ?? 0.0,
      ratios: MarkerRatios.fromJson(json['ratios'] as Map<String, dynamic>),
      userGoal: (json['user_goal'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    advice,
    diabetic,
    dietitianFocus,
    fatLossPossible,
    interpretation,
    intervention,
    marker,
    ppm,
    ratios,
    userGoal,
    zone,
  ];
}

class MarkerAdvice extends Equatable {
  final String whatLowers;
  final String whatRaises;

  const MarkerAdvice({
    required this.whatLowers,
    required this.whatRaises,
  });

  factory MarkerAdvice.fromJson(Map<String, dynamic> json) {
    return MarkerAdvice(
      whatLowers: (json['what_lowers'] ?? '').toString(),
      whatRaises: (json['what_raises'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [whatLowers, whatRaises];
}

class MarkerRatios extends Equatable {
  final double? fatMetabolismPercent;
  final double? glucoseMetabolismPercent;
  final double? hepaticStrainPercent;
  final double? liverDetoxPercent;
  final double? absorptivePercent;
  final double? fermentationPercent;

  const MarkerRatios({
    this.fatMetabolismPercent,
    this.glucoseMetabolismPercent,
    this.hepaticStrainPercent,
    this.liverDetoxPercent,
    this.absorptivePercent,
    this.fermentationPercent,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      try {
        return double.tryParse(v);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory MarkerRatios.fromJson(Map<String, dynamic> json) {
    return MarkerRatios(
      fatMetabolismPercent: _toDouble(json['Fat Metabolism %']),
      glucoseMetabolismPercent: _toDouble(json['Glucose Metabolism %']),
      hepaticStrainPercent: _toDouble(json['Hepatic Strain %']),
      liverDetoxPercent: _toDouble(json['Liver Detox %']),
      absorptivePercent: _toDouble(json['Absorptive %']),
      fermentationPercent: _toDouble(json['Fermentation %']),
    );
  }

  @override
  List<Object?> get props => [
    fatMetabolismPercent,
    glucoseMetabolismPercent,
    hepaticStrainPercent,
    liverDetoxPercent,
    absorptivePercent,
    fermentationPercent,
  ];
}

class FatLossMetabolismScore extends Equatable {
  final String clientInterpretation;
  final String scientificInterpretation;
  final double score;
  final String zone;

  const FatLossMetabolismScore({
    required this.clientInterpretation,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      try {
        return double.tryParse(v);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory FatLossMetabolismScore.fromJson(Map<String, dynamic> json) {
    return FatLossMetabolismScore(
      clientInterpretation: (json['client_interpretation'] ?? '').toString(),
      scientificInterpretation: (json['scientific_interpretation'] ?? '').toString(),
      score: _toDouble(json['score']) ?? 0.0,
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    clientInterpretation,
    scientificInterpretation,
    score,
    zone,
  ];
}