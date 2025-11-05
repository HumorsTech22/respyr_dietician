class ResultModel {
  final double bmi;
  final double bmr;
  final int dttm; // Epoch timestamp
  final int gutAbsorptiveScore;
  final int gutFermentativeScore;
  final int fatMetabolismScore;
  final int glucoseMetabolismScore;
  final int hepaticScore;
  final int detoxScore;

  ResultModel({
    required this.bmi,
    required this.bmr,
    required this.dttm,
    required this.gutAbsorptiveScore,
    required this.gutFermentativeScore,
    required this.fatMetabolismScore,
    required this.glucoseMetabolismScore,
    required this.hepaticScore,
    required this.detoxScore,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'][0];

    return ResultModel(
      bmi: double.tryParse(data['bmi'].toString()) ?? 0.0,
      bmr: double.tryParse(data['bmr'].toString()) ?? 0.0,
      dttm: int.tryParse(data['dttm'].toString()) ?? 0,
      gutAbsorptiveScore: int.tryParse(data['gut_absorptive'].toString()) ?? 97,
      gutFermentativeScore:
          int.tryParse(data['gut_fermentative'].toString()) ?? 95,
      fatMetabolismScore:
          int.tryParse(data['fat_metabolism']?.toString() ?? '') ?? 91,
      glucoseMetabolismScore:
          int.tryParse(data['glucose']?.toString() ?? '') ?? 92,
      hepaticScore: int.tryParse(data['hepatic']?.toString() ?? '') ?? 85,
      detoxScore: int.tryParse(data['detox']?.toString() ?? '') ?? 89,
    );
  }

  /// 🔹 Dummy data for UI testing
  factory ResultModel.dummy() {
    return ResultModel(
      bmi: 25.0,
      bmr: 1827.0,
      dttm: 1747910241, // Epoch time (UNIX timestamp)
      gutAbsorptiveScore: 75,
      gutFermentativeScore: 90,
      fatMetabolismScore: 51,
      glucoseMetabolismScore: 43,
      hepaticScore: 74,
      detoxScore: 89,
    );
  }
}
