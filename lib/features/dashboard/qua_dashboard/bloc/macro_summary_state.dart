
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/models/macro_summary_model.dart';

class MacroSummaryState {
  final bool isLoading;
  final MacroSummaryResponse? data;
  final String? error;

  const MacroSummaryState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  MacroSummaryState copyWith({
    bool? isLoading,
    MacroSummaryResponse? data,
    String? error,
  }) {
    return MacroSummaryState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}