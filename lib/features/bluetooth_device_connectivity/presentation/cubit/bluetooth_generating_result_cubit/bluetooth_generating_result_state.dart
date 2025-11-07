import 'package:equatable/equatable.dart';

class BluetoothGeneratingResultState extends Equatable {
  final String? textError;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToResultScreen;

  final int completedSteps;

  const BluetoothGeneratingResultState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.navigateToResultScreen = false,

    this.completedSteps = 0,
  });

  BluetoothGeneratingResultState copyWith({
    String? textError,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToResultScreen,

    int? completedSteps,
  }) {
    return BluetoothGeneratingResultState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToResultScreen:
          navigateToResultScreen ?? this.navigateToResultScreen,

      completedSteps: completedSteps ?? this.completedSteps,
    );
  }

  @override
  List<Object?> get props => [
    textError,
    hasInternet,
    isBluetoothConnected,
    isDialogShown,
    navigateToResultScreen,

    completedSteps,
  ];
}
