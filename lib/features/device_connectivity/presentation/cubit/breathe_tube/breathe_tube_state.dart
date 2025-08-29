import 'package:equatable/equatable.dart';

class BreatheTubeState extends Equatable {
  final bool isConnected;
  final bool hasInternet;
  final double progress;
  final bool isDialogShown;
  final bool isTestCancelled;
  final bool isCompleted;
  final String? error;

  const BreatheTubeState({
    this.isConnected = false,
    this.hasInternet = true,
    this.progress = 0,
    this.isDialogShown = false,
    this.isTestCancelled = false,
    this.isCompleted = false,
    this.error,
  });

  BreatheTubeState copyWith({
    bool? isConnected,
    bool? hasInternet,
    double? progress,
    bool? isDialogShown,
    bool? isTestCancelled,
    bool? isCompleted,
    String? error,
  }) {
    return BreatheTubeState(
      isConnected: isConnected ?? this.isConnected,
      hasInternet: hasInternet ?? this.hasInternet,
      progress: progress ?? this.progress,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      isTestCancelled: isTestCancelled ?? this.isTestCancelled,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isConnected,
    hasInternet,
    progress,
    isDialogShown,
    isTestCancelled,
    isCompleted,
    error,
  ];
}
