
import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';

abstract class ClientHabitState {}

class ClientHabitInitial extends ClientHabitState {}

class ClientHabitLoading extends ClientHabitState {}

class ClientHabitLoaded extends ClientHabitState {
  final ClientHabitStatusResponse response;

  ClientHabitLoaded(this.response);
}

class ClientHabitError extends ClientHabitState {
  final String message;

  ClientHabitError(this.message);
}