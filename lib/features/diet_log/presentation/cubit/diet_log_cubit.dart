import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/diet_log/data/diet_log_repository.dart';
import 'diet_log_state.dart';

class DietLogCubit extends Cubit<DietLogState> {
  final DietLogRepository repository;

  DietLogCubit(this.repository) : super(DietLogInitial());

  Future<void> loadDietLog(DateTime date) async {
    emit(DietLogLoading());
    try {
      final summary = await repository.fetchSummary(date);
      final meals = await repository.fetchMeals(date);
      emit(DietLogLoaded(summary: summary, meals: meals));
    } catch (e) {
      emit(DietLogError(e.toString()));
    }
  }

  List<DateTime> getCurrentWeekDates() {
    final today = DateTime.now();
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }
}
