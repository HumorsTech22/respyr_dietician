import 'package:equatable/equatable.dart';

class BluetoothGeneratingResultState extends Equatable {
  final String? textError;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToResultScreen;

  final double? acetone;
  final double? ethanol;
  final double? hydrogen;

  final int completedSteps;

  const BluetoothGeneratingResultState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.navigateToResultScreen = false,
    this.acetone,
    this.ethanol,
    this.hydrogen,
    this.completedSteps = 0,
  });

  BluetoothGeneratingResultState copyWith({
    String? textError,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToResultScreen,
    double? acetone,
    double? ethanol,
    double? hydrogen,
    int? completedSteps,
  }) {
    return BluetoothGeneratingResultState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToResultScreen:
          navigateToResultScreen ?? this.navigateToResultScreen,
      acetone: acetone ?? this.acetone,
      ethanol: ethanol ?? this.ethanol,
      hydrogen: hydrogen ?? this.hydrogen,
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
    acetone,
    ethanol,
    hydrogen,
    completedSteps,
  ];
}
