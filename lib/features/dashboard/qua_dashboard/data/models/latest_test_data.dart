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
    required this.rawTestJson,
    required this.minRange,
    required this.maxRange,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory LatestTestData.fromJson(Map<String, dynamic> json) {
    final rawTestJson = (json['test_json'] ?? '').toString().trim();
    TestJsonData? testJsonData;

    if (rawTestJson.isNotEmpty) {
      try {
        final parsedJson = jsonDecode(rawTestJson) as Map<String, dynamic>;
        testJsonData = TestJsonData.fromJson(parsedJson);
      } catch (e) {
        // keep null
        // ignore: avoid_print
        print('Error parsing test_json: $e');
      }
    }

    return LatestTestData(
      testId: (json['test_id'] ?? '').toString(),
      dietitianId: (json['dietitian_id'] ?? '').toString(),
      profileId: (json['profile_id'] ?? '').toString(),
      dietPlanId: (json['diet_plan_id'] ?? '').toString(),
      absorptiveMetabolismScore: _toDouble(json['absorptive_metabolism_score']),
      fermentativeMetabolismScore:
      _toDouble(json['fermentative_metabolism_score']),
      fatMetabolismScore: _toDouble(json['fat_metabolism_score']),
      glucoseMetabolismScore: _toDouble(json['glucose_metabolism_score']),
      hepaticStressMetabolismScore:
      _toDouble(json['hepatic_stress_metabolism_score']),
      detoxificationMetabolismScore:
      _toDouble(json['detoxification_metabolism_score']),
      fatLossMetabolismScore: _toDouble(json['fat_loss_metabolism_score']),
      acetonePpm: _toDouble(json['acetone_ppm']),
      h2Ppm: _toDouble(json['h2_ppm']),
      ethanolPpm: _toDouble(json['ethanol_ppm']),
      dateTime: (json['date_time'] ?? '').toString(),
      testJsonData: testJsonData,
      rawTestJson: rawTestJson,
      minRange: _toDouble(json['min_range']),
      maxRange: _toDouble(json['max_range']),
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

      // ✅ UPDATED KEY HERE
      fatLossMetabolismScore: json['Fat_Use_Pattern_trend'] != null
          ? FatLossMetabolismScore.fromJson(
          json['Fat_Use_Pattern_trend'] as Map<String, dynamic>)
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
  // ✅ Keep old field names (so UI doesn’t break)
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
    Map<String, dynamic> _map(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      return const <String, dynamic>{};
    }

    // ✅ OLD FORMAT (absorption/fermentation/etc.)
    if (json['absorption'] != null) {
      return MetabolismScoreAnalysis(
        absorption: MetabolismScore.fromJson(_map(json['absorption'])),
        detoxification: MetabolismScore.fromJson(_map(json['detoxification'])),
        fatMetabolism: MetabolismScore.fromJson(_map(json['fat_metabolism'])),
        fermentation: MetabolismScore.fromJson(_map(json['fermentation'])),
        glucoseMetabolism:
        MetabolismScore.fromJson(_map(json['glucose_metabolism'])),
        hepaticStress: MetabolismScore.fromJson(_map(json['hepatic_stress'])),
        metabolismScoreSummary: json['metabolism_score_summary'] != null
            ? MetabolismScoreSummary.fromJson(
          json['metabolism_score_summary'] as Map<String, dynamic>,
        )
            : null,
      );
    }

    // ✅ NEW FORMAT (*_Trend keys)
    return MetabolismScoreAnalysis(
      // absorption -> Nutrient_Utilization_Trend
      absorption: MetabolismScore.fromJson(_map(json['Nutrient_Utilization_Trend'])),

      // fermentation -> Digestive_Activity_Trend
      fermentation: MetabolismScore.fromJson(_map(json['Digestive_Activity_Trend'])),

      // fat_metabolism -> Fuel_Utilization_Trend
      fatMetabolism: MetabolismScore.fromJson(_map(json['Fuel_Utilization_Trend'])),

      // glucose_metabolism -> Energy_Source_Trend
      glucoseMetabolism: MetabolismScore.fromJson(_map(json['Energy_Source_Trend'])),

      // hepatic_stress -> Metabolic_Load_Trend
      hepaticStress: MetabolismScore.fromJson(_map(json['Metabolic_Load_Trend'])),

      // detoxification -> Recovery_Activity_Trend
      detoxification: MetabolismScore.fromJson(_map(json['Recovery_Activity_Trend'])),

      metabolismScoreSummary: json['metabolism_score_summary'] != null
          ? MetabolismScoreSummary.fromJson(
        json['metabolism_score_summary'] as Map<String, dynamic>,
      )
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
    if (v is String) return double.tryParse(v);
    return double.tryParse(v.toString());
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
  // ✅ Keep old field names to avoid refactor elsewhere
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
    // NEW summary keys from backend (plus fallback for old ones if present)
    return MetabolismScoreSummary(
      absorptiveScore:
      (json['Nutrient Utilization Trend'] ?? json['Absorptive Score'] ?? '')
          .toString(),
      fermentativeScore:
      (json['Digestive Activity Trend'] ?? json['Fermentative Score'] ?? '')
          .toString(),
      fatMetabolismScore:
      (json['Fuel Utilization Trend'] ?? json['Fat Metabolism Score'] ?? '')
          .toString(),
      glucoseMetabolismScore:
      (json['Energy Source Trend'] ?? json['Glucose Metabolism Score'] ?? '')
          .toString(),
      hepaticStressScore:
      (json['Metabolic Load Trend'] ?? json['Hepatic Stress Score'] ?? '')
          .toString(),
      detoxificationScore:
      (json['Recovery Activity Trend'] ?? json['Detoxification Score'] ?? '')
          .toString(),
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
    Map<String, dynamic> _map(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      return const <String, dynamic>{};
    }

    return BreathMarkerAnalysis(
      acetone: BreathMarker.fromJson(_map(json['acetone'])),
      ethanol: BreathMarker.fromJson(_map(json['ethanol'])),
      hydrogen: BreathMarker.fromJson(_map(json['hydrogen'])),
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
    return double.tryParse(v.toString());
  }

  factory BreathMarker.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> _map(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      return const <String, dynamic>{};
    }

    return BreathMarker(
      advice: MarkerAdvice.fromJson(_map(json['advice'])),
      diabetic: (json['diabetic'] ?? false) as bool,
      dietitianFocus: (json['dietitian_focus'] ?? '').toString(),
      fatLossPossible: (json['fat_loss_possible'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      marker: (json['marker'] ?? '').toString(),
      ppm: _toDouble(json['ppm']) ?? 0.0,
      ratios: MarkerRatios.fromJson(_map(json['ratios'])),
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
    return double.tryParse(v.toString());
  }

  factory MarkerRatios.fromJson(Map<String, dynamic> json) {
    // supports both old and new ratio labels
    return MarkerRatios(
      fatMetabolismPercent:
      _toDouble(json['Fat Metabolism %'] ?? json['Fuel Utilization %']),
      glucoseMetabolismPercent: _toDouble(
          json['Glucose Metabolism %'] ?? json['Energy Source %']),
      hepaticStrainPercent:
      _toDouble(json['Hepatic Strain %'] ?? json['Metabolic Load %']),
      liverDetoxPercent:
      _toDouble(json['Liver Detox %'] ?? json['Recovery Activity %']),
      absorptivePercent:
      _toDouble(json['Absorptive %'] ?? json['Nutrient Utilization %']),
      fermentationPercent:
      _toDouble(json['Fermentation %'] ?? json['Digestive Activity %']),
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
    return double.tryParse(v.toString());
  }

  factory FatLossMetabolismScore.fromJson(Map<String, dynamic> json) {
    String _extract(dynamic v) {
      if (v == null) return '';
      // backend sometimes sends {title,text}
      if (v is Map<String, dynamic>) return (v['text'] ?? v['title'] ?? '').toString();
      return v.toString();
    }

    return FatLossMetabolismScore(
      clientInterpretation: _extract(json['client_interpretation']),
      scientificInterpretation: _extract(json['scientific_interpretation']),
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
