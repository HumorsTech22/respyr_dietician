
import 'package:respyr_dietitian/features/habit_tracking/update_habits/data/model/habit_master_model.dart';

abstract class HabitMasterState {}

class HabitMasterInitial extends HabitMasterState {}

class HabitMasterLoading extends HabitMasterState {}

class HabitMasterLoaded extends HabitMasterState {
  final HabitMasterResponse response;

  HabitMasterLoaded(this.response);
}

class HabitMasterError extends HabitMasterState {
  final String message;

  HabitMasterError(this.message);
}