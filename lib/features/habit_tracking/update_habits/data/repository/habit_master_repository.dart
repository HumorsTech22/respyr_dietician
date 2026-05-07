import '../model/habit_master_model.dart';
import '../services/habit_master_service.dart';

class HabitMasterRepository {
  final HabitMasterService service;

  HabitMasterRepository(this.service);

  Future<HabitMasterResponse> fetchHabitMaster({
    required int levelId,
  }) {
    return service.fetchHabitMaster(levelId: levelId);
  }
}