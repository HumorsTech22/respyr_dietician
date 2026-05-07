import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:respyr_dietitian/features/habit_tracking/bloc/client_habit_cubit.dart';
import 'package:respyr_dietitian/features/habit_tracking/bloc/client_habit_state.dart';
import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';
import 'package:respyr_dietitian/features/habit_tracking/repoistory/client_habit_repository.dart';
import 'package:respyr_dietitian/features/habit_tracking/services/client_habit_service.dart';
import 'package:respyr_dietitian/features/habit_tracking/services/track_client_habit_service.dart';

import 'habit_completion_celebration.dart';
import 'habit_undo_bar.dart';
import 'today_habit_bubble_card.dart';

/// Threshold at which the celebration card is shown instead of the bubble card.
const int _kCompletionCelebrationThreshold = 5;

/// Window during which the user can undo a completion before it's
/// committed to the server.
const Duration _kUndoWindow = Duration(seconds: 2);

/// Top-level "Today's habits" widget.
///
/// Owns the [ClientHabitCubit], manages the optimistic-update + undo
/// flow, and switches between the active bubble card and the completion
/// celebration based on how many habits the user has completed.
class ClientTodayHabitsWidget extends StatefulWidget {
  final String profileId;
  final String trackingDate;

  const ClientTodayHabitsWidget({
    super.key,
    required this.profileId,
    required this.trackingDate,
  });

  @override
  State<ClientTodayHabitsWidget> createState() =>
      _ClientTodayHabitsWidgetState();
}

class _ClientTodayHabitsWidgetState extends State<ClientTodayHabitsWidget> {
  late final ClientHabitCubit _cubit;

  ClientHabitStatusResponse? _lastResponse;
  List<ClientHabitData> _currentHabits = const [];

  bool _firstLoading = true;
  bool _isUpdating = false;

  // ── Undo state ──────────────────────────────────────────────────────
  Timer? _undoTimer;
  ClientHabitData? _pendingUndoHabit;
  bool _showUndo = false;

  @override
  void initState() {
    super.initState();
    _cubit = ClientHabitCubit(ClientHabitRepository(ClientHabitService()));
    _fetchHabits(showLoader: true);
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    _cubit.close();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────

  Future<void> _fetchHabits({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() => _firstLoading = true);
    }

    await _cubit.fetchClientHabits(
      profileId: widget.profileId,
      trackingDate: widget.trackingDate,
    );
  }

  // ── Optimistic complete + undo flow ─────────────────────────────────

  /// Called when the user pops a bubble. Optimistically removes the
  /// habit from the local list and starts the undo timer.
  void _onHabitPopped(ClientHabitData habit, int _) {
    _undoTimer?.cancel();

    setState(() {
      _currentHabits = _currentHabits
          .where((item) => item.habitId != habit.habitId)
          .toList();

      _pendingUndoHabit = habit;
      _showUndo = true;
    });

    _undoTimer = Timer(_kUndoWindow, _commitPendingHabit);
  }

  /// Called when the undo timer expires. Sends the completion to the
  /// server and re-fetches. If the request fails, the habit is restored
  /// to the local list.
  Future<void> _commitPendingHabit() async {
    final ClientHabitData? habit = _pendingUndoHabit;
    if (habit == null) return;

    if (mounted) {
      setState(() {
        _showUndo = false;
        _pendingUndoHabit = null;
        _isUpdating = true;
      });
    }

    try {
      await TrackClientHabitService.trackHabit(
        profileId: widget.profileId,
        habitId: habit.habitId,
        trackingDate: widget.trackingDate,
        completedCount: habit.requiredCount,
        notes: 'Completed from habit bubble',
      );

      if (!mounted) return;
      await _fetchHabits();
    } catch (_) {
      if (!mounted) return;
      _restoreHabit(habit);
    }
  }

  /// User tapped UNDO before the timer expired. Restore the habit and
  /// cancel the pending commit.
  void _onUndoTapped() {
    final ClientHabitData? habit = _pendingUndoHabit;
    if (habit == null) return;

    _undoTimer?.cancel();
    _restoreHabit(habit);

    setState(() {
      _showUndo = false;
      _pendingUndoHabit = null;
    });
  }

  /// Adds [habit] back to the front of the list, deduping by id.
  void _restoreHabit(ClientHabitData habit) {
    setState(() {
      _isUpdating = false;
      _currentHabits = [
        habit,
        ..._currentHabits.where((item) => item.habitId != habit.habitId),
      ];
    });
  }

  // ── BLoC reactions ──────────────────────────────────────────────────

  void _onCubitState(BuildContext context, ClientHabitState state) {
    if (state is ClientHabitLoaded) {
      final List<ClientHabitData> pending =
      state.response.data.where((h) => !h.isTracked).toList();

      setState(() {
        _lastResponse = state.response;
        _currentHabits = pending;
        _firstLoading = false;
        _isUpdating = false;
      });
    }

    if (state is ClientHabitError) {
      setState(() {
        _firstLoading = false;
        _isUpdating = false;
      });
    }
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<ClientHabitCubit, ClientHabitState>(
        listener: _onCubitState,
        child: BlocBuilder<ClientHabitCubit, ClientHabitState>(
          buildWhen: (_, current) =>
          current is ClientHabitLoading ||
              current is ClientHabitLoaded ||
              current is ClientHabitError,
          builder: _buildContent,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientHabitState state) {
    if (_firstLoading && state is ClientHabitLoading) {
      return const _LoadingPlaceholder();
    }

    if (state is ClientHabitError && _currentHabits.isEmpty) {
      return Center(child: Text(state.message));
    }

    final ClientHabitStatusResponse response =
    (_lastResponse ?? ClientHabitStatusResponse.empty())
        .copyWith(data: _currentHabits);

    if (_currentHabits.isEmpty &&
        !_showUndo &&
        response.completedHabits <= 0) {
      return const SizedBox.shrink();
    }

    final bool showCelebration =
        response.completedHabits >= _kCompletionCelebrationThreshold;

    return _GradientBackground(
      child: showCelebration
          ? HabitCompletionCelebration(
        completedCount: response.completedHabits,
        totalCount: response.totalHabits,
        streakDays: 0, // TODO: wire up real streak from response
      )
          : _ActiveHabitsLayout(
        response: response,
        isUpdating: _isUpdating,
        showUndo: _showUndo,
        undoHabit: _pendingUndoHabit,
        onHabitPopped: _onHabitPopped,
        onUndo: _onUndoTapped,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 250,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Widget child;

  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [
            Color(0xFFE9D8FF),
            Colors.white,
            Color(0xFFE9D9FF),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(15, 37, 15, 33),
      child: child,
    );
  }
}

class _ActiveHabitsLayout extends StatelessWidget {
  final ClientHabitStatusResponse response;
  final bool isUpdating;
  final bool showUndo;
  final ClientHabitData? undoHabit;
  final void Function(ClientHabitData habit, int index) onHabitPopped;
  final VoidCallback onUndo;

  const _ActiveHabitsLayout({
    required this.response,
    required this.isUpdating,
    required this.showUndo,
    required this.undoHabit,
    required this.onHabitPopped,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: isUpdating ? 0.65 : 1.0,
          child: IgnorePointer(
            ignoring: isUpdating,
            child: RepaintBoundary(
              child: TodayHabitBubbleCard(
                response: response,
                onHabitCompleted: onHabitPopped,
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: showUndo && undoHabit != null
              ? HabitUndoBar(
            key: const ValueKey('undo_bar'),
            habitName: undoHabit!.habitName,
            onUndo: onUndo,
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}