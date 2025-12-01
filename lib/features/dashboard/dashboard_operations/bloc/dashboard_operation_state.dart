// dashboard_operation_state.dart

abstract class DashboardOperationState {}

class DashboardOperationInitial extends DashboardOperationState {}

class DashboardOperationLoaded extends DashboardOperationState {
  final double currentWeight;
  /// This is the *locally added* water amount (in ml) for today
  final double waterIntake;
  final double targetWaterMl;

  /// true while calling insert_water_log.php
  final bool isSaving;

  /// becomes true once after a successful save
  final bool lastSaveSuccess;

  /// error message from API (if any)
  final String? errorMessage;

  DashboardOperationLoaded({
    required this.currentWeight,
    required this.waterIntake,
    required this.targetWaterMl,
    this.isSaving = false,
    this.lastSaveSuccess = false,
    this.errorMessage,
  });

  DashboardOperationLoaded copyWith({
    double? currentWeight,
    double? waterIntake,
    double? targetWaterMl,
    bool? isSaving,
    bool? lastSaveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardOperationLoaded(
      currentWeight: currentWeight ?? this.currentWeight,
      waterIntake: waterIntake ?? this.waterIntake,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
      isSaving: isSaving ?? this.isSaving,
      lastSaveSuccess: lastSaveSuccess ?? this.lastSaveSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
