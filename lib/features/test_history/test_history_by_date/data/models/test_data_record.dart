// lib/features/metabolism_test/data/models/test_data_record.dart
class TestDataRecord {
  final int testId;
  final String profileId;

  final double? absorptiveScore;
  final double? fermentativeScore;
  final double? fatScore;
  final double? glucoseScore;
  final double? hepaticStressScore;
  final double? detoxScore;

  final double? acetonePpm;
  final double? h2Ppm;
  final double? ethanolPpm;

  final DateTime dateTime;

  TestDataRecord({
    required this.testId,
    required this.profileId,
    required this.dateTime,
    this.absorptiveScore,
    this.fermentativeScore,
    this.fatScore,
    this.glucoseScore,
    this.hepaticStressScore,
    this.detoxScore,
    this.acetonePpm,
    this.h2Ppm,
    this.ethanolPpm,
  });

  factory TestDataRecord.fromJson(Map<String, dynamic> json) {
    return TestDataRecord(
      testId: int.parse(json['test_id'].toString()),
      profileId: json['profile_id'] as String,
      absorptiveScore: _toDouble(json['absorptive_metabolism_score']),
      fermentativeScore: _toDouble(json['fermentative_metabolism_score']),
      fatScore: _toDouble(json['fat_metabolism_score']),
      glucoseScore: _toDouble(json['glucose_metabolism_score']),
      hepaticStressScore: _toDouble(json['hepatic_stress_metabolism_score']),
      detoxScore: _toDouble(json['detoxification_metabolism_score']),
      acetonePpm: _toDouble(json['acetone_ppm']),
      h2Ppm: _toDouble(json['h2_ppm']),
      ethanolPpm: _toDouble(json['ethanol_ppm']),
      dateTime: DateTime.parse(json['date_time']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
