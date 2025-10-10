import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_state.dart';

class DietitianDashboardCubit extends Cubit<DietitianDashboardState> {
  final DietitianDashboardRepository repository;

  DietitianDashboardCubit(this.repository) : super(DietitianDashboardInitial());

  Future<void> loadDietitianDashboard(DateTime date) async {
    emit(DietitianDashboardLoading());

    try {
      final meal = await repository.fetchDailyMealPlan(date);
      emit(DietitianDashboardLoaded(meal: meal));
    } catch (e) {
      emit(DietitianDashboardError(message: e.toString()));
    }
  }
}
