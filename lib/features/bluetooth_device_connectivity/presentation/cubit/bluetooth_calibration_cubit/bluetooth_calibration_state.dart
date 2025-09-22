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

  const BluetoothCalibrationState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.isMuted = false,
    this.navigateToInhaleScreen = false,
    this.completedSteps = 0,
    this.waitForInhaleCmd = false,
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
  }) {
    return BluetoothCalibrationState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToInhaleScreen:
          navigateToInhaleScreen ?? this.navigateToInhaleScreen,
      isMuted: isMuted ?? this.isMuted,
      completedSteps: completedSteps ?? this.completedSteps,
      waitForInhaleCmd: waitForInhaleCmd ?? this.waitForInhaleCmd,
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
  ];
}
