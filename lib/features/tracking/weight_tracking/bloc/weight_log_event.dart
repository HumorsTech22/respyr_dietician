// lib/features/tracking/weight_tracking/presentation/bloc/weight_log_event.dart

import 'package:equatable/equatable.dart';

abstract class WeightLogEvent extends Equatable {
  const WeightLogEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeightLogs extends WeightLogEvent {
  final String profileId;

  const LoadWeightLogs(this.profileId);

  @override
  List<Object?> get props => [profileId];
}
