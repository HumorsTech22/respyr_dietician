class Thresholds {
  static const double blowThreshold = 10;
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



  static double calculateBlowPercentage1(double baseValue, double blowValue) {
    // Define the range that represents 100%
    const double fullRange = 7.5;

    // Calculate the progress
    double progress = ((blowValue - baseValue) / fullRange) * 100;

    // Optional: Prevent negative numbers or values over 100%
    return progress.clamp(0.0, 100.0);
  }

  static double calculateInhalePercentage(
      double baseValue,
      double inhaleValue,
      ) {
    double diff = inhaleValue - baseValue; // negative

    return (diff / 10) * 100;
  }



}
