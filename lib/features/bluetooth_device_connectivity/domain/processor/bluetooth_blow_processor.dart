class BluetoothBlowProcessor {
  double? blowBaseValue;
  double? blowThresholdValue;
  double? blowP;
  bool isBaseValueCaptured = false;
  bool isBlowThresholdSet = false;
  bool firstDataValueCaptured = false;
  bool perfectBlowValueCaptured = false;
  bool isBlown = false;
  bool isBlownInFresher = false;
  bool isBlowStartTimeCaptured = false;
  bool isAbort = false;
  bool diffTStampFlag = false;
  bool moveToResults = false;
  bool improperBlow = false;

  double? firstDataValue;
  double? thresholdPercentage;

  int? blowStartTime;
  int? blowEndTime;

  List<double> blowValuesList = [];
  List<double> baseBlowValueList = [];

  void reset() {
    blowBaseValue = null;
    blowThresholdValue = null;
    blowP = null;
    isBaseValueCaptured = false;
    isBlowThresholdSet = false;
    firstDataValueCaptured = false;
    perfectBlowValueCaptured = false;
    isBlown = false;
    isBlownInFresher = false;
    isBlowStartTimeCaptured = false;
    isAbort = false;
    diffTStampFlag = false;
    moveToResults = false;
    improperBlow = false;
    firstDataValue = null;
    thresholdPercentage = null;
    blowStartTime = null;
    blowEndTime = null;
    blowValuesList = [];
    baseBlowValueList = [];
  }

  void processBlowData(
    String data,
    double? Function(double) thresholdPercentageCalc,
    double Function(double, double) blowPercentageCalc,
  ) {
    final baseValueRegex = RegExp(r'/([0-9.]+)/');
    final blowValueRegex = RegExp(r'\{([0-9.]+)\}');

    final baseValueMatch = baseValueRegex.firstMatch(data);
    final blowValueMatch = blowValueRegex.firstMatch(data);

    if (baseValueMatch != null && !isBaseValueCaptured) {
      // Capture base value
      blowBaseValue = double.parse(baseValueMatch.group(1)!);
      baseBlowValueList.add(blowBaseValue!);
      blowThresholdValue = blowBaseValue! + 20;
      isBaseValueCaptured = true;

      if (!isBlowThresholdSet) {
        thresholdPercentage = thresholdPercentageCalc(blowBaseValue!);
        isBlowThresholdSet = true;
      }
    } else if (blowValueMatch != null && isBaseValueCaptured) {
      double blowValue = double.parse(blowValueMatch.group(1)!);

      if (!firstDataValueCaptured) {
        firstDataValue = blowValue;
        firstDataValueCaptured = true;
      }

      if (blowValue < firstDataValue!) {
        blowValue = firstDataValue!;
      }

      blowP = blowPercentageCalc(blowBaseValue!, blowValue);

      if (blowP! > 10) isBlown = true;

      if (blowP! >= thresholdPercentage!) {
        perfectBlowValueCaptured = true;

        // Start timer only when first threshold crossing happens
        if (!isBlowStartTimeCaptured) {
          blowStartTime = DateTime.now().millisecondsSinceEpoch;
          isBlowStartTimeCaptured = true;
          blowValuesList.clear();
        }

        blowValuesList.add(blowValue);
      }

      // Detect abort → user dropped below threshold
      if (perfectBlowValueCaptured &&
          isBlown &&
          blowP! < thresholdPercentage!) {
        blowEndTime = DateTime.now().millisecondsSinceEpoch;

        final durationAfterThreshold = blowEndTime! - (blowStartTime ?? 0);

        if (durationAfterThreshold < 1500) {
          improperBlow = true;
        } else {
          moveToResults = true;
        }

        isAbort = true;
      }
    }
  }

  bool get isBlowComplete => moveToResults;

  bool get isImproperBlow => improperBlow;

  int get blowDuration {
    if (!isBlowStartTimeCaptured) return 0;
    return DateTime.now().millisecondsSinceEpoch - (blowStartTime ?? 0);
  }
}

// class Thresholds {
//   static const double blowThreshold = 1.0;
//   static const double abortDifference = 1500;

//   static double calculateThresholdPercentage(double baseValue) {
//     double valueThreshold = baseValue + blowThreshold;
//     double valueDiff = valueThreshold - baseValue;
//     return (valueDiff / (valueDiff * 2)) * 100;
//   }

//   static double calculateBlowPercentage(double baseValue, double blowValue) {
//     double valueThreshold = baseValue + blowThreshold;
//     double valueDiff1 = valueThreshold - blowValue;
//     valueDiff1 = blowThreshold - valueDiff1;
//     double valueDiff = valueThreshold - baseValue;
//     return (valueDiff1 / (valueDiff * 2)) * 100;
//   }
// }
