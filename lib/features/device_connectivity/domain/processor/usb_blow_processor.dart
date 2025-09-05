// // ---- Domain Result Classes ----
// abstract class ExhaleResult {}

// class ExhaleProgress extends ExhaleResult {
//   final double percentage;
//   ExhaleProgress(this.percentage);
// }

// class ExhaleCompleted extends ExhaleResult {
//   final double bestPressure;
//   final double maxPressure;
//   final int duration;
//   final List<double> blowValues;
//   ExhaleCompleted({
//     required this.bestPressure,
//     required this.maxPressure,
//     required this.duration,
//     required this.blowValues,
//   });
// }

// class ExhaleAbort extends ExhaleResult {}

// class ExhaleError extends ExhaleResult {
//   final String message;
//   ExhaleError(this.message);
// }

// // ---- Processor ----
// class UsbBlowProcessor {
//   double? blowBaseValue;
//   double? blowThresholdValue;
//   double? blowP;
//   bool isBaseValueCaptured = false;
//   bool isBlowThresholdSet = false;
//   bool firstDataValueCaptured = false;
//   bool perfectBlowValueCaptured = false;
//   bool isBlown = false;
//   bool isBlownInFresher = false;
//   bool isBlowStartTimeCaptured = false;
//   bool isAbort = false;
//   bool diffTStampFlag = false;
//   bool moveToResults = false;

//   double? firstDataValue;
//   double? thresholdPercentage;

//   int? blowStartTime;
//   int? diffTStamp;
//   int? diffTStampCurrent;

//   List<double> blowValuesList = [];
//   List<double> baseBlowValueList = [];

//   // Core function -> returns ExhaleResult
//   ExhaleResult processBlowEvent(String data) {
//     try {
//       final baseValueRegex = RegExp(r'/([0-9.]+)/');
//       final blowValueRegex = RegExp(r'\{([0-9.]+)\}');

//       final baseValueMatch = baseValueRegex.firstMatch(data);
//       final blowValueMatch = blowValueRegex.firstMatch(data);

//       // 1️⃣ Capture Base Value
//       if (baseValueMatch != null && !isBaseValueCaptured) {
//         blowBaseValue = double.parse(baseValueMatch.group(1)!);
//         baseBlowValueList.add(blowBaseValue!);
//         blowThresholdValue = blowBaseValue! + 20;
//         isBaseValueCaptured = true;

//         if (!isBlowThresholdSet) {
//           thresholdPercentage = Thresholds.calculateThresholdPercentage(
//             blowBaseValue!,
//           );
//           isBlowThresholdSet = true;
//         }
//       }

//       // 2️⃣ Process Blow Value
//       else if (blowValueMatch != null && isBaseValueCaptured) {
//         double blowValue = double.parse(blowValueMatch.group(1)!);

//         // Capture first value
//         if (!firstDataValueCaptured) {
//           firstDataValue = blowValue;
//           firstDataValueCaptured = true;
//         }

//         // Prevent inhale backflow
//         if (blowValue < firstDataValue!) {
//           blowValue = firstDataValue!;
//         }

//         // Calculate blow %
//         blowP = Thresholds.calculateBlowPercentage(blowBaseValue!, blowValue);

//         if (blowP! > 10) {
//           isBlown = true;
//         }

//         // ✅ Progress but not strong enough
//         if (blowP! > 10 && blowP! < thresholdPercentage!) {
//           if (blowP! >= 10) {
//             isBlownInFresher = true;
//           }
//           return ExhaleProgress(blowP!);
//         }

//         // ✅ Reached target threshold
//         else if (blowP! >= thresholdPercentage!) {
//           perfectBlowValueCaptured = true;

//           if (!isBlowStartTimeCaptured) {
//             blowStartTime = DateTime.now().millisecondsSinceEpoch;
//             isBlowStartTimeCaptured = true;
//             blowValuesList.clear();
//           }

//           blowValuesList.add(blowValue);
//           return ExhaleProgress(blowP!);
//         }

//         // ✅ User stopped blowing
//         else if (blowP! < thresholdPercentage!) {
//           if (perfectBlowValueCaptured && isBlown && !moveToResults) {
//             return _generateResult();
//           }

//           // ❌ Abort condition
//           if (!perfectBlowValueCaptured && isBlownInFresher && blowP! <= 0.9) {
//             if (!diffTStampFlag) {
//               diffTStampFlag = true;
//               diffTStamp = DateTime.now().millisecondsSinceEpoch;
//             }

//             diffTStampCurrent = DateTime.now().millisecondsSinceEpoch;
//             int timeDifference = diffTStampCurrent! - diffTStamp!;

//             if (timeDifference >= Thresholds.abortDifference) {
//               if (!isAbort) {
//                 isAbort = true;
//                 return ExhaleAbort();
//               }
//             }
//           } else {
//             diffTStampFlag = false;
//             diffTStamp = DateTime.now().millisecondsSinceEpoch;
//           }
//         }
//       }

//       return ExhaleProgress(blowP ?? 0);
//     } catch (e) {
//       if (kDebugMode) print("❌ UsbBlowProcessor Error: $e");
//       return ExhaleError("Processing failed");
//     }

//   }

//   // Generate final success result
//   ExhaleResult _generateResult() {
//     if (moveToResults) return ExhaleError("Already completed");

//     final blowEndTime = DateTime.now().millisecondsSinceEpoch;
//     final finalBlowTime = blowEndTime - (blowStartTime ?? blowEndTime);

//     if (finalBlowTime > 1500) {
//       double sum = blowValuesList.fold(0, (prev, n) => prev + n);
//       double bestPR = sum / blowValuesList.length;
//       double maxPR = blowValuesList.reduce((a, b) => a > b ? a : b);

//       final combinedList = [...baseBlowValueList, ...blowValuesList];

//       moveToResults = true;
//       isAbort = false;

//       return ExhaleCompleted(
//         bestPressure: bestPR,
//         maxPressure: maxPR,
//         duration: finalBlowTime,
//         blowValues: combinedList,
//       );
//     } else {
//       isAbort = true;
//       return ExhaleAbort();
//     }
//   }

//   void reset() {
//     blowBaseValue = null;
//     blowThresholdValue = null;
//     blowP = null;
//     isBaseValueCaptured = false;
//     isBlowThresholdSet = false;
//     firstDataValueCaptured = false;
//     perfectBlowValueCaptured = false;
//     isBlown = false;
//     isBlownInFresher = false;
//     isBlowStartTimeCaptured = false;
//     isAbort = false;
//     diffTStampFlag = false;
//     moveToResults = false;

//     firstDataValue = null;
//     thresholdPercentage = null;
//     blowStartTime = null;
//     diffTStamp = null;
//     diffTStampCurrent = null;

//     blowValuesList.clear();
//     baseBlowValueList.clear();
//   }
// }

class UsbBlowProcessor {
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
  bool improperBlow = false; // 👈 new flag

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
          improperBlow = true; // ❌ too short
        } else {
          moveToResults = true; // ✅ valid completion
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
