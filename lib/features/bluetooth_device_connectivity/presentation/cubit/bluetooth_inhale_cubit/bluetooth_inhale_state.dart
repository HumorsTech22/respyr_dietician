import 'package:equatable/equatable.dart';

class BluetoothInhaleState extends Equatable {
  final String? textError;
  final String? lastExtractedValue;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToExhaleScreen;
  final int counter;
  final bool isMuted;

  const BluetoothInhaleState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.isMuted = false,
    this.navigateToExhaleScreen = false,
    this.counter = 8,
    this.lastExtractedValue,
  });

  BluetoothInhaleState copyWith({
    String? textError,
    String? lastExtractedValue,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToExhaleScreen,
    bool? isMuted,
    int? counter,
  }) {
    return BluetoothInhaleState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToExhaleScreen:
          navigateToExhaleScreen ?? this.navigateToExhaleScreen,
      isMuted: isMuted ?? this.isMuted,
      counter: counter ?? this.counter,
      lastExtractedValue: lastExtractedValue ?? this.lastExtractedValue,
    );
  }

  @override
  List<Object?> get props => [
    textError,
    hasInternet,
    isBluetoothConnected,
    isDialogShown,
    navigateToExhaleScreen,
    isMuted,
    counter,
    lastExtractedValue,
  ];
}
