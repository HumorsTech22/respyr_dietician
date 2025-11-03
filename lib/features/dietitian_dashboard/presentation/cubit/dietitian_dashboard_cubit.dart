import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/common/dialogs/abort_sheet_dialog.dart';
import 'package:respyr_dietitian/common/widgets/abort_device_manager.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_state.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/customized_dashboard_color_text.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

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

  Future<void> checkDeviceAbortStatus(BuildContext context) async {
    try {
      final isDeviceAborted = await AbortDeviceManager.getAbortStatus();

      if (context.mounted) {
        if (isDeviceAborted) {
          CheckAbortSheet.show(
            context: context,
            onTakeTextClick: () {
              context.push(AppRoutes.bluetoothDeviceConnectivity);
            },
          );
        } else {
          context.push(AppRoutes.bluetoothDeviceConnectivity);
        }
      }
    } catch (e) {
      debugPrint("❌ Error checking device abort status: $e");
    }
  }

  Future<void> loadDietitianDashboard({
    required String loginId,
    required String profileId,
    required String day,
  }) async {
    emit(DietitianDashboardLoading());

    try {
      final meal = await repository.fetchDailyMealPlan(
        loginId: loginId,
        profileId: profileId,
        day: day,
      );
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
