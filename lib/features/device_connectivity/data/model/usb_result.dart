class BlowResult {
  final double progress;
  final bool isBlown;
  final bool moveToResults;
  final double? maxPressure;
  final double? bestPressure;
  final int? blowDuration;

  BlowResult({
    required this.progress,
    required this.isBlown,
    required this.moveToResults,
    this.maxPressure,
    this.bestPressure,
    this.blowDuration,
  });
}
