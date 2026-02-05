import 'package:flutter/widgets.dart';

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
    const double fullRange = 11.7;
    // Calculate the progress
    double progress = ((blowValue - baseValue) / fullRange) * 100;
    // Optional: Prevent negative numbers or values over 100%

    debugPrint("progress :$progress");
    debugPrint("baseValue :$progress");
    debugPrint("blowValue :$blowValue");

    return progress;
  }


  // static double calculateBlowPercentage2(double baseValue, double blowValue) {
  //   // Define the range that represents 100%
  //   const double fullRange = 12;
  //   // Calculate the progress
  //   double progress = ((blowValue - baseValue) / fullRange) * 100;
  //   // Optional: Prevent negative numbers or values over 100%
  //
  //   debugPrint("progress :$progress");
  //   debugPrint("baseValue :$progress");
  //   debugPrint("blowValue :$blowValue");
  //
  //   return progress;
  // }
  //
  // static double calculateInhalePercentage(
  //     double baseValue,
  //     double inhaleValue,
  //     ) {
  //   double diff = inhaleValue - baseValue; // negative
  //
  //   return (diff / 5) * 100;
  // }

  static double calculateBlowPercentage2(
      double baseValue,
      double blowValue,
      ) {
    // 12 raw units = 100% (device calibration)
    const double fullRange = 12.0;

    double progress = ((blowValue - baseValue) / fullRange) * 100;

    debugPrint("progress : $progress");
    debugPrint("baseValue : $baseValue");
    debugPrint("blowValue : $blowValue");

    return progress;
  }

  static double calculateInhalePercentage(
      double baseValue,
      double inhaleValue,
      ) {
    // For normal human inhale:
    // 5 raw units drop = 100% inhale (~3 seconds)
    double diff = inhaleValue - baseValue; // negative during inhale

    double progress = (diff / 12) * 100;

    debugPrint("inhaleProgress : $progress");
    debugPrint("baseValue : $baseValue");
    debugPrint("inhaleValue : $inhaleValue");

    return progress;
  }




}
