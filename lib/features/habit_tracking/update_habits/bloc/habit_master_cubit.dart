import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/habit_tracking/update_habits/data/repository/habit_master_repository.dart';
import 'habit_master_state.dart';

class HabitMasterCubit extends Cubit<HabitMasterState> {
  final HabitMasterRepository repository;

  HabitMasterCubit(this.repository) : super(HabitMasterInitial());

  Future<void> fetchHabitMaster({
    int levelId = 1,
  }) async {
    emit(HabitMasterLoading());

    try {
      final response = await repository.fetchHabitMaster(levelId: levelId);

      if (response.status) {
        emit(HabitMasterLoaded(response));
      } else {
        emit(HabitMasterError(response.message));
      }
    } catch (e) {
      emit(HabitMasterError(e.toString()));
    }
  }
}