import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/services/macro_summary_service.dart';
import 'macro_summary_state.dart';

class MacroSummaryCubit extends Cubit<MacroSummaryState> {
  final MacroSummaryService service;

  MacroSummaryCubit({
    required this.service,
  }) : super(const MacroSummaryState());

  Future<void> fetchMacroSummary({
    required String profileId,
    required String date,
  }) async {
    emit(const MacroSummaryState(isLoading: true));

    try {
      final result = await service.fetchMacroSummary(
        profileId: profileId,
        date: date,
      );

      emit(MacroSummaryState(
        isLoading: false,
        data: result,
      ));
    } catch (e) {
      emit(MacroSummaryState(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}