class Thresholds {
  static const double blowThreshold = 5.0;
  static const double abortDifference = 1500;

  static double calculateThresholdPercentage(double baseValue) {
    double valueThreshold = baseValue + blowThreshold;
    double valueDiff = valueThreshold - baseValue;
    return (valueDiff / (valueDiff * 2)) * 100;
  }

  static double calculateBlowPercentage(double baseValue, double blowValue) {
    double valueThreshold = baseValue + blowThreshold;
    double valueDiff1 = valueThreshold - blowValue;
    valueDiff1 = blowThreshold - valueDiff1;
    double valueDiff = valueThreshold - baseValue;
    return (valueDiff1 / (valueDiff * 2)) * 100;
  }
}
