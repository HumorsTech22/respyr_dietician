import 'package:equatable/equatable.dart';

class CalibrationState extends Equatable {
  final bool isConnected;
  final int completedSteps;
  final bool isMuted;
  final bool navigateToInhaleScreen;
  final bool isDialogShown;
  final String? errorMessage;

  const CalibrationState({
    this.isConnected = false,
    this.completedSteps = 0,
    this.isMuted = false,
    this.isDialogShown = false,
    this.navigateToInhaleScreen = false,
    this.errorMessage,
  });

  CalibrationState copyWith({
    bool? isConnected,
    int? completedSteps,
    bool? isMuted,
    bool? navigateToInhaleScreen,
    bool? isDialogShown,
    String? errorMessage,
  }) {
    return CalibrationState(
      isConnected: isConnected ?? this.isConnected,
      isMuted: isMuted ?? this.isMuted,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToInhaleScreen:
          navigateToInhaleScreen ?? this.navigateToInhaleScreen,
      completedSteps: completedSteps ?? this.completedSteps,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isConnected,
    isMuted,
    isDialogShown,
    navigateToInhaleScreen,
    completedSteps,
    errorMessage,
  ];
}
