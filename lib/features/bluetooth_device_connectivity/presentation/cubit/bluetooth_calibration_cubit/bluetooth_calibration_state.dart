import 'package:equatable/equatable.dart';

class BluetoothCalibrationState extends Equatable {
  final String? textError;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToInhaleScreen;
  final int completedSteps;
  final bool isMuted;
  final bool waitForInhaleCmd;
  final bool showPleaseWaitMessage;
  final bool allSignalSent;

  // ✅ NEW: screen timer fields
  final bool isTimeStarted;
  final int remainingSeconds;
  final bool isTimeOver;

  const BluetoothCalibrationState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.isMuted = false,
    this.navigateToInhaleScreen = false,
    this.completedSteps = 0,
    this.waitForInhaleCmd = false,
    this.showPleaseWaitMessage = false,
    this.allSignalSent = false,

    // ✅ NEW defaults
    this.isTimeStarted = false,
    this.remainingSeconds = 100,
    this.isTimeOver = false,
  });

  BluetoothCalibrationState copyWith({
    String? textError,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToInhaleScreen,
    bool? isMuted,
    int? completedSteps,
    bool? waitForInhaleCmd,
    bool? showPleaseWaitMessage,
    bool? allSignalSent,

    // ✅ NEW
    bool? isTimeStarted,
    int? remainingSeconds,
    bool? isTimeOver,
  }) {
    return BluetoothCalibrationState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToInhaleScreen: navigateToInhaleScreen ?? this.navigateToInhaleScreen,
      isMuted: isMuted ?? this.isMuted,
      completedSteps: completedSteps ?? this.completedSteps,
      waitForInhaleCmd: waitForInhaleCmd ?? this.waitForInhaleCmd,
      showPleaseWaitMessage: showPleaseWaitMessage ?? this.showPleaseWaitMessage,
      allSignalSent: allSignalSent ?? this.allSignalSent,

      // ✅ NEW
      isTimeStarted: isTimeStarted ?? this.isTimeStarted,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimeOver: isTimeOver ?? this.isTimeOver,
    );
  }

  @override
  List<Object?> get props => [
    textError,
    hasInternet,
    isBluetoothConnected,
    isDialogShown,
    navigateToInhaleScreen,
    isMuted,
    completedSteps,
    waitForInhaleCmd,
    showPleaseWaitMessage,
    allSignalSent,

    // ✅ NEW
    isTimeStarted,
    remainingSeconds,
    isTimeOver,
  ];
}
