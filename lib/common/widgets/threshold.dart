class Thresholds {
  static const double blowThreshold = 0.5;
  static const double inhaleThreshold = 15;
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


  static double calculateInhalePercentage(
      double baseValue,
      double inhaleValue,
      ) {
    double diff = inhaleValue - baseValue; // negative

    return (diff / 5) * 100;
  }



}
