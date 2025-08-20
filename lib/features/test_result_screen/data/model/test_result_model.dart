class TestResultModel {
  final int dttm;
  final double gutAbsorptiveScore;
  final double gutFermentativeScore;
  final double fatMetabolismScore;
  final double fatGlucoseMetabolismScore;
  final double liverHepaticScore;
  final double liverDetoxScore;

  TestResultModel({
    required this.dttm,
    required this.fatGlucoseMetabolismScore,
    required this.gutAbsorptiveScore,
    required this.gutFermentativeScore,
    required this.fatMetabolismScore,
    required this.liverHepaticScore,
    required this.liverDetoxScore,
  });
}
