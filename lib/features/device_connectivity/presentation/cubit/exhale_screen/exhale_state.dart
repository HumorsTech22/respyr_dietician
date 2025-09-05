import 'package:equatable/equatable.dart';

class ExhaleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExhaleInitial extends ExhaleState {}

class ExhaleInProgress extends ExhaleState {
  final double progress;
  final int secondsRemaining;
  final bool isConnected;
  final double? thresholdPercentage;
  final String infoText;

  ExhaleInProgress({
    required this.progress,
    required this.secondsRemaining,
    required this.isConnected,
    this.thresholdPercentage,
    required this.infoText,
  });

  @override
  List<Object?> get props => [
    progress,
    secondsRemaining,
    isConnected,
    thresholdPercentage,
    infoText,
  ];
}

class ExhaleError extends ExhaleState {
  final String error;
  ExhaleError(this.error);
  @override
  List<Object?> get props => [error];
}

class ExhaleImproper extends ExhaleState {
  final String message;
  ExhaleImproper(this.message);
}

class ExhaleDone extends ExhaleState {}
