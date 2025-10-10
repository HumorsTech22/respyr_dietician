import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/diet_log/data/diet_log_repository.dart';

abstract class DietLogState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DietLogInitial extends DietLogState {}

class DietLogLoading extends DietLogState {}

class DietLogLoaded extends DietLogState {
  final DietSummary summary;
  final List<Meal> meals;

  DietLogLoaded({required this.summary, required this.meals});

  @override
  List<Object?> get props => [summary, meals];
}

class DietLogError extends DietLogState {
  final String message;
  DietLogError(this.message);

  @override
  List<Object> get props => [message];
}
