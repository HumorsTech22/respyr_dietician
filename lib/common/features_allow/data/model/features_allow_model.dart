class FeaturesAllowData {
  final int id;
  final String dieticianId;
  final bool testAllow;
  final bool practiceTestAllow;
  final bool detailedScores;
  final bool multipleReading;

  FeaturesAllowData({
    required this.id,
    required this.dieticianId,
    required this.testAllow,
    required this.practiceTestAllow,
    required this.detailedScores, required this.multipleReading,
  });

  factory FeaturesAllowData.fromJson(Map<String, dynamic> json) {
    return FeaturesAllowData(
      id: json['id'] ?? 0,
      dieticianId: json['dietician_id'] ?? "",
      testAllow: json['test_allow'] == true,
      practiceTestAllow: json['practice_test_allow'] == true,
      detailedScores: json['detailed_scores'] == true,
      multipleReading: json['multiple_reading'] == true,
    );
  }
}

class FeaturesAllowResponse {
  final bool success;
  final String? failReason;
  final FeaturesAllowData data;

  FeaturesAllowResponse({
    required this.success,
    this.failReason,
    required this.data,
  });
}