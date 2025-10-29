import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_state.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/customized_dashboard_color_text.dart';

class DietitianDashboardCubit extends Cubit<DietitianDashboardState> {
  final DietitianDashboardRepository repository;
  Timer? _timeCheckTimer;
  String? _lastTimeRange;
  DietitianDashboardCubit(this.repository)
    : super(DietitianDashboardInitial()) {
    _startTimeCheck();
  }

  void _startTimeCheck() {
    _timeCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final hour = DateTime.now().hour;
      final currentTimeRange = CustomizedDashboardColorText.getTimeRange(hour);

      if (currentTimeRange != _lastTimeRange &&
          state is DietitianDashboardLoaded) {
        final currentMeal = (state as DietitianDashboardLoaded).meal;
        emit(DietitianDashboardLoaded(meal: currentMeal));
        _lastTimeRange = currentTimeRange;
      }
    });
  }

  Future<void> loadDietitianDashboard(DateTime date) async {
    emit(DietitianDashboardLoading());

    try {
      final meal = await repository.fetchDailyMealPlan(date);
      _lastTimeRange = CustomizedDashboardColorText.getTimeRange(
        DateTime.now().hour,
      );
      emit(DietitianDashboardLoaded(meal: meal));
    } catch (e) {
      emit(DietitianDashboardError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timeCheckTimer?.cancel();
    return super.close();
  }
}
