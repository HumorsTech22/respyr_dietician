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
  final bool? isTakenTest;

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
    this.isTakenTest,
  });

  factory TestDataRecord.fromJson(Map<String, dynamic> json, bool? isTakenTest) {
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
      isTakenTest: isTakenTest,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }


  factory TestDataRecord.dummy({required String profileId}) {
    return TestDataRecord(
      testId: 0,
      profileId: profileId,
      dateTime: DateTime.now(),
      absorptiveScore: null,
      fermentativeScore: null,
      fatScore: null,
      glucoseScore: null,
      hepaticStressScore: null,
      detoxScore: null,
      acetonePpm: null,
      h2Ppm: null,
      ethanolPpm: null,
      isTakenTest: false
    );
  }
}
