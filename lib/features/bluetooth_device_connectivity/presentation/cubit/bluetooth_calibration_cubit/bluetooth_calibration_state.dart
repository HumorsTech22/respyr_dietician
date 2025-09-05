import 'package:equatable/equatable.dart';

class BluetoothCalibrationState extends Equatable {
  final String? textError;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToInhaleScreen;
  final int completedSteps;
  final bool isMuted;

  const BluetoothCalibrationState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.isMuted = false,
    this.navigateToInhaleScreen = false,
    this.completedSteps = 0,
  });

  BluetoothCalibrationState copyWith({
    String? textError,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToInhaleScreen,
    bool? isMuted,
    int? completedSteps,
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
  ];
}
