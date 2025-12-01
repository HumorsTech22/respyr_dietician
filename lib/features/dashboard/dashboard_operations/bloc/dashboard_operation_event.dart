// dashboard_operation_event.dart

abstract class DashboardOperationEvent {}

class IncrementWeight extends DashboardOperationEvent {}

class DecrementWeight extends DashboardOperationEvent {}

class IncrementWater extends DashboardOperationEvent {}

class DecrementWater extends DashboardOperationEvent {}

class InsertWaterLog extends DashboardOperationEvent {
  final String profileId;
  final int consumedMl;
  final int targetedMl;
  final String loggedBy;
  final String loggedById;
  final String? notes;

  InsertWaterLog({
    required this.profileId,
    required this.consumedMl,
    required this.targetedMl,
    required this.loggedBy,
    required this.loggedById,
    this.notes,
  });
}

/// 🔹 Reset only local added water + flags after a successful save
class ResetWaterLocal extends DashboardOperationEvent {}
