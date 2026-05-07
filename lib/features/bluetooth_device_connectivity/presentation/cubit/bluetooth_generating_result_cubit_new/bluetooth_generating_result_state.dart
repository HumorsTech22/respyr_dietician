import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';

const Object _unset = Object();

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
  final RespyrUnifiedResponse? dietitianResult;

  final int remainingSeconds;
  final bool isTimedOut;
  final bool dataReceivedFromDevice;

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
    this.dietitianResult,
    this.remainingSeconds = 300,
    this.isTimedOut = false,
    this.dataReceivedFromDevice = false,
  });

  BluetoothGeneratingResultState copyWith({
    Object? textError = _unset,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToResultScreen,
    Object? acetone = _unset,
    Object? ethanol = _unset,
    Object? hydrogen = _unset,
    int? completedSteps,
    Object? dietitianResult = _unset,
    int? remainingSeconds,
    bool? isTimedOut,
    bool? dataReceivedFromDevice,
  }) {
    return BluetoothGeneratingResultState(
      textError: identical(textError, _unset) ? this.textError : textError as String?,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToResultScreen: navigateToResultScreen ?? this.navigateToResultScreen,
      acetone: identical(acetone, _unset) ? this.acetone : acetone as double?,
      ethanol: identical(ethanol, _unset) ? this.ethanol : ethanol as double?,
      hydrogen: identical(hydrogen, _unset) ? this.hydrogen : hydrogen as double?,
      completedSteps: completedSteps ?? this.completedSteps,
      dietitianResult: identical(dietitianResult, _unset)
          ? this.dietitianResult
          : dietitianResult as RespyrUnifiedResponse?,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimedOut: isTimedOut ?? this.isTimedOut,
      dataReceivedFromDevice: dataReceivedFromDevice ?? this.dataReceivedFromDevice,
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
    dietitianResult,
    remainingSeconds,
    isTimedOut,
    dataReceivedFromDevice,
  ];
}