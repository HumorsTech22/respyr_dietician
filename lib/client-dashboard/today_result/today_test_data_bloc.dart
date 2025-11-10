import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/todays_result/today_test_data_event.dart';
import 'package:respyr_dietitian/client-dashboard/todays_result/today_test_data_repository.dart';
import 'package:respyr_dietitian/client-dashboard/todays_result/today_test_data_state.dart';


class TodayTestDataBloc extends Bloc<TodayTestDataEvent, TestDataState> {
  final TodayTestDataRepository repo;

  String? _lastProfileId;
  DateTime? _lastDate;

  TodayTestDataBloc(this.repo) : super(const TestDataState()) {
    on<LoadTestDataForDay>(_onLoad);
    on<RefreshTestData>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadTestDataForDay event,
      Emitter<TestDataState> emit,
      ) async {
    emit(state.copyWith(status: TestDataStatus.loading, errorMessage: null));
    try {
      _lastProfileId = event.profileId;
      _lastDate = event.date;

      final list = await repo.fetchDay(
        profileId: event.profileId,
        date: event.date,
      );

      if (list.isEmpty) {
        emit(state.copyWith(status: TestDataStatus.empty, records: []));
      } else {
        emit(state.copyWith(status: TestDataStatus.success, records: list));
      }
    } catch (e) {
      emit(state.copyWith(status: TestDataStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefresh(
      RefreshTestData event,
      Emitter<TestDataState> emit,
      ) async {
    final profileId = _lastProfileId;
    if (profileId == null) return;
    add(LoadTestDataForDay(profileId: profileId, date: _lastDate));
  }
}
