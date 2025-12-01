// dashboard_operation_bloc.dart

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'dashboard_operation_event.dart';
import 'dashboard_operation_state.dart';

class DashboardOperationBloc
    extends Bloc<DashboardOperationEvent, DashboardOperationState> {
  DashboardOperationBloc({
    required double initialWeight,
    required double initialWater,
    required double targetWaterMl,
  }) : super(
    DashboardOperationLoaded(
      currentWeight: initialWeight,
      waterIntake: initialWater, // this is "added today" amount
      targetWaterMl: targetWaterMl,
    ),
  ) {
    on<IncrementWeight>(_onIncrementWeight);
    on<DecrementWeight>(_onDecrementWeight);
    on<IncrementWater>(_onIncrementWater);
    on<DecrementWater>(_onDecrementWater);
    on<InsertWaterLog>(_onInsertWaterLog);
    on<ResetWaterLocal>(_onResetWaterLocal);
  }

  void _onIncrementWeight(
      IncrementWeight event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      emit(
        currentState.copyWith(
          currentWeight: currentState.currentWeight + 1,
        ),
      );
    }
  }

  void _onDecrementWeight(
      DecrementWeight event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final newValue = currentState.currentWeight - 1;
      emit(
        currentState.copyWith(
          currentWeight: newValue < 0 ? 0 : newValue,
        ),
      );
    }
  }

  void _onIncrementWater(
      IncrementWater event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final newValue = currentState.waterIntake + 250; // add 250 ml
      emit(
        currentState.copyWith(
          waterIntake: newValue < 0 ? 0 : newValue,
          lastSaveSuccess: false,
          clearError: true,
        ),
      );
    }
  }

  void _onDecrementWater(
      DecrementWater event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final newValue = currentState.waterIntake - 250; // minus 250 ml
      emit(
        currentState.copyWith(
          waterIntake: newValue < 0 ? 0 : newValue,
          lastSaveSuccess: false,
          clearError: true,
        ),
      );
    }
  }

  Future<void> _onInsertWaterLog(
      InsertWaterLog event,
      Emitter<DashboardOperationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! DashboardOperationLoaded) return;

    // set loading
    emit(
      currentState.copyWith(
        isSaving: true,
        lastSaveSuccess: false,
        clearError: true,
      ),
    );

    try {
      final uri = Uri.parse(
        'https://humorstech.com/dietitian/api/app/insert_water_log.php',
      );

      final body = {
        "profile_id": event.profileId,
        "consumed_ml": event.consumedMl,
        "targeted_ml": event.targetedMl,
        "logged_by": event.loggedBy,
        "logged_by_id": event.loggedById,
        "notes": event.notes,
      };

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool success =
            data["status"] == true || data["status"] == 1 || data["status"] == "1";

        if (success) {
          emit(
            currentState.copyWith(
              isSaving: false,
              lastSaveSuccess: true,
              clearError: true,
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              isSaving: false,
              lastSaveSuccess: false,
              errorMessage:
              data["message"]?.toString() ?? "Failed to insert water log",
            ),
          );
        }
      } else {
        emit(
          currentState.copyWith(
            isSaving: false,
            lastSaveSuccess: false,
            errorMessage: "Server error: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isSaving: false,
          lastSaveSuccess: false,
          errorMessage: "Something went wrong. Please try again.",
        ),
      );
    }
  }

  /// 🔹 Reset local added water + flags after success
  void _onResetWaterLocal(
      ResetWaterLocal event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      emit(
        currentState.copyWith(
          waterIntake: 0,
          isSaving: false,
          lastSaveSuccess: false,
          clearError: true,
        ),
      );
    }
  }
}
