import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/habit_tracking/repoistory/client_habit_repository.dart';
import 'client_habit_state.dart';

class ClientHabitCubit extends Cubit<ClientHabitState> {
  final ClientHabitRepository repository;

  ClientHabitCubit(this.repository) : super(ClientHabitInitial());

  Future<void> fetchClientHabits({
    required String profileId,
    required String trackingDate,
  }) async {
    emit(ClientHabitLoading());

    try {
      final response = await repository.fetchClientHabits(
        profileId: profileId,
        trackingDate: trackingDate,
      );

      if (response.status) {
        emit(ClientHabitLoaded(response));
      } else {
        emit(ClientHabitError(response.message));
      }
    } catch (e) {
      emit(ClientHabitError(e.toString()));
    }
  }
}