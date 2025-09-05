import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class InhaleState extends Equatable {
  final int counter;
  final bool isConnected;
  final bool isDisposed;
  final bool navigationToExhaleScreen;
  final bool hasInternet;
  final bool isMuted;
  final String? lastExtractedValue;
  final String? errorMessage;
  final bool dialogShown;

  const InhaleState({
    this.counter = 8,
    this.isConnected = false,
    this.isDisposed = false,
    this.navigationToExhaleScreen = false,
    this.hasInternet = true,
    this.isMuted = false,
    this.lastExtractedValue,
    this.errorMessage,
    this.dialogShown = false,
  });

  InhaleState copyWith({
    int? counter,
    bool? isConnected,
    bool? isDisposed,
    bool? navigationToExhaleScreen,
    bool? hasInternet,
    bool? isMuted,
    String? lastExtractedValue,
    String? errorMessage,
    bool? dialogShown,
  }) {
    return InhaleState(
      counter: counter ?? this.counter,
      isConnected: isConnected ?? this.isConnected,
      isDisposed: isDisposed ?? this.isDisposed,
      navigationToExhaleScreen:
          navigationToExhaleScreen ?? this.navigationToExhaleScreen,
      hasInternet: hasInternet ?? this.hasInternet,
      isMuted: isMuted ?? this.isMuted,
      lastExtractedValue: lastExtractedValue ?? this.lastExtractedValue,
      errorMessage: errorMessage ?? this.errorMessage,
      dialogShown: dialogShown ?? this.dialogShown,
    );
  }

  @override
  List<Object?> get props => [
    counter,
    isConnected,
    isDisposed,
    navigationToExhaleScreen,
    hasInternet,
    isMuted,
    lastExtractedValue,
    errorMessage,
    dialogShown,
  ];
}
