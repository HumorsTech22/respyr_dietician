class GeneratingResultModel {
  final bool success;
  final String message;
  final int testId;
  final String urlCalled;
  final RespyrResponse respyrResponse;
  final DateTime dateTime;


  GeneratingResultModel({
    required this.success,
    required this.message,
    required this.testId,
    required this.urlCalled,
    required this.respyrResponse,
    required this.dateTime,
  });

  factory GeneratingResultModel.fromJson(Map<String, dynamic> json) {
    // Safely parse date_time string => DateTime
    final String? dtStr = json['date_time'];
    DateTime parsedDateTime;

    if (dtStr != null && dtStr.isNotEmpty) {
      // PHP returns "YYYY-MM-DD HH:MM:SS"
      // DateTime.parse can handle "2025-11-18 06:27:15"
      parsedDateTime = DateTime.parse(dtStr.replaceFirst(' ', 'T'));
    } else {
      // Fallback if missing
      parsedDateTime = DateTime.now();
    }

    return GeneratingResultModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      testId: json['test_id'] ?? 0,
      urlCalled: json['url_called'] ?? '',
      dateTime: parsedDateTime,
      respyrResponse: RespyrResponse.fromJson(json['respyr_response'] ?? {}),
    );
  }
}

class RespyrResponse {
  final MetabolismScoreAnalysis metabolismScoreAnalysis;
  final BreathMarkerAnalysis breathMarkerAnalysis;
  final FatLossMetabolismScore fatLossMetabolismScore;

  RespyrResponse({
    required this.metabolismScoreAnalysis,
    required this.breathMarkerAnalysis,
    required this.fatLossMetabolismScore,
  });

  factory RespyrResponse.fromJson(Map<String, dynamic> json) {
    return RespyrResponse(
      metabolismScoreAnalysis: MetabolismScoreAnalysis.fromJson(
        json['Metabolism_Score_Analysis'] ?? {},
      ),
      breathMarkerAnalysis: BreathMarkerAnalysis.fromJson(
        json['breath_marker_analysis'] ?? {},
      ),
      fatLossMetabolismScore: FatLossMetabolismScore.fromJson(
        json['fat_loss_metabolism_score'] ?? {},
      ),
    );
  }
}

class MetabolismScoreAnalysis {
  final ScoreItem absorption;
  final ScoreItem detoxification;
  final ScoreItem fatMetabolism;
  final ScoreItem fermentation;
  final ScoreItem glucoseMetabolism;
  final ScoreItem hepaticStress;

  MetabolismScoreAnalysis({
    required this.absorption,
    required this.detoxification,
    required this.fatMetabolism,
    required this.fermentation,
    required this.glucoseMetabolism,
    required this.hepaticStress,
  });

  factory MetabolismScoreAnalysis.fromJson(Map<String, dynamic> json) {
    return MetabolismScoreAnalysis(
      absorption: ScoreItem.fromJson(json['absorption'] ?? {}),
      detoxification: ScoreItem.fromJson(json['detoxification'] ?? {}),
      fatMetabolism: ScoreItem.fromJson(json['fat_metabolism'] ?? {}),
      fermentation: ScoreItem.fromJson(json['fermentation'] ?? {}),
      glucoseMetabolism: ScoreItem.fromJson(json['glucose_metabolism'] ?? {}),
      hepaticStress: ScoreItem.fromJson(json['hepatic_stress'] ?? {}),
    );
  }
}

class ScoreItem {
  final String clientState;
  final String interpretation;
  final String intervention;
  final String ppmNote;
  final int score;
  final String whatIsThisScore;
  final String zone;

  ScoreItem({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.ppmNote,
    required this.score,
    required this.whatIsThisScore,
    required this.zone,
  });

  factory ScoreItem.fromJson(Map<String, dynamic> json) {
    return ScoreItem(
      clientState: json['client_state'] ?? '',
      interpretation: json['interpretation'] ?? '',
      intervention: json['intervention'] ?? '',
      ppmNote: json['ppm_note'] ?? '',
      score: (json['score'] ?? 0).toInt(),
      whatIsThisScore: json['what_is_this_score'] ?? '',
      zone: json['zone'] ?? '',
    );
  }
}

class BreathMarkerAnalysis {
  final MarkerItem acetone;
  final MarkerItem ethanol;
  final MarkerItem hydrogen;

  BreathMarkerAnalysis({
    required this.acetone,
    required this.ethanol,
    required this.hydrogen,
  });

  factory BreathMarkerAnalysis.fromJson(Map<String, dynamic> json) {
    return BreathMarkerAnalysis(
      acetone: MarkerItem.fromJson(json['acetone'] ?? {}),
      ethanol: MarkerItem.fromJson(json['ethanol'] ?? {}),
      hydrogen: MarkerItem.fromJson(json['hydrogen'] ?? {}),
    );
  }
}

class MarkerItem {
  final String marker;
  final double ppm;
  final String interpretation;
  final String intervention;
  final String zone;
  final bool diabetic;
  final String userGoal;
  final Map<String, dynamic>? ratios;
  final MarkerAdvice? advice;

  MarkerItem({
    required this.marker,
    required this.ppm,
    required this.interpretation,
    required this.intervention,
    required this.zone,
    required this.diabetic,
    required this.userGoal,
    required this.ratios,
    required this.advice,
  });

  factory MarkerItem.fromJson(Map<String, dynamic> json) {
    return MarkerItem(
      marker: json['marker'] ?? '',
      ppm: (json['ppm'] ?? 0).toDouble(),
      interpretation: json['interpretation'] ?? '',
      intervention: json['intervention'] ?? '',
      zone: json['zone'] ?? '',
      diabetic: json['diabetic'] ?? false,
      userGoal: json['user_goal'] ?? '',
      ratios: json['ratios'] != null
          ? Map<String, dynamic>.from(json['ratios'])
          : null,
      advice: json['advice'] != null
          ? MarkerAdvice.fromJson(json['advice'])
          : null,
    );
  }
}

class MarkerAdvice {
  final String whatLowers;
  final String whatRaises;

  MarkerAdvice({required this.whatLowers, required this.whatRaises});

  factory MarkerAdvice.fromJson(Map<String, dynamic> json) {
    return MarkerAdvice(
      whatLowers: json['what_lowers'] ?? '',
      whatRaises: json['what_raises'] ?? '',
    );
  }
}

class FatLossMetabolismScore {
  final String clientInterpretation;
  final String scientificInterpretation;
  final double score;
  final String zone;

  FatLossMetabolismScore({
    required this.clientInterpretation,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
  });

  factory FatLossMetabolismScore.fromJson(Map<String, dynamic> json) {
    return FatLossMetabolismScore(
      clientInterpretation: json['client_interpretation'] ?? '',
      scientificInterpretation: json['scientific_interpretation'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      zone: json['zone'] ?? '',
    );
  }
}
