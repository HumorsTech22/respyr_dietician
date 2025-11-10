class GeneratingResultParams {
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;

  GeneratingResultParams({
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
  });
}
