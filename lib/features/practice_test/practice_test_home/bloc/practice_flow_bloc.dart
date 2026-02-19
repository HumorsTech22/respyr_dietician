import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/enums/practice_test.dart';

enum PracticeStepStatus { locked, available, completed }

class PracticeFlowState extends Equatable {
  final Map<PracticeTestSteps, PracticeStepStatus> status;

  const PracticeFlowState({required this.status});

  bool get allCompleted =>
      status.values.every((s) => s == PracticeStepStatus.completed);

  PracticeStepStatus stepStatus(PracticeTestSteps step) =>
      status[step] ?? PracticeStepStatus.locked;

  bool isCompleted(PracticeTestSteps step) =>
      stepStatus(step) == PracticeStepStatus.completed;

  bool isEnabled(PracticeTestSteps step) {
    final s = stepStatus(step);
    return s == PracticeStepStatus.available || s == PracticeStepStatus.completed;
  }

  PracticeFlowState copyWith({
    Map<PracticeTestSteps, PracticeStepStatus>? status,
  }) {
    return PracticeFlowState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}

abstract class PracticeFlowEvent extends Equatable {
  const PracticeFlowEvent();
  @override
  List<Object?> get props => [];
}

class PracticeFlowInit extends PracticeFlowEvent {
  const PracticeFlowInit();
}

class PracticeFlowMarkCompleted extends PracticeFlowEvent {
  final PracticeTestSteps step;
  const PracticeFlowMarkCompleted(this.step);

  @override
  List<Object?> get props => [step];
}

class PracticeFlowReset extends PracticeFlowEvent {
  const PracticeFlowReset();
}

class PracticeFlowBloc extends Bloc<PracticeFlowEvent, PracticeFlowState> {
  PracticeFlowBloc() : super(_initialState()) {
    print("🔥 PracticeFlowBloc CREATED => ${identityHashCode(this)}");
    print("🧠 initial => ${state.status}");

    on<PracticeFlowInit>((event, emit) {
      print("🚀 PracticeFlowInit => bloc=${identityHashCode(this)}");
      final recomputed = _recomputeLocks(state);
      print("🧠 after init => ${recomputed.status}");
      emit(recomputed);
    });

    on<PracticeFlowMarkCompleted>((event, emit) {
      print("✅ MarkCompleted(${event.step}) => bloc=${identityHashCode(this)}");

      final next = Map<PracticeTestSteps, PracticeStepStatus>.from(state.status);
      next[event.step] = PracticeStepStatus.completed;

      final recomputed = _recomputeLocks(PracticeFlowState(status: next));
      print("🧠 after mark => ${recomputed.status}");

      emit(recomputed);
    });

    on<PracticeFlowReset>((event, emit) {
      print("♻️ Reset => bloc=${identityHashCode(this)}");
      emit(_initialState());
    });
  }

  static PracticeFlowState _initialState() {
    return const PracticeFlowState(
      status: {
        PracticeTestSteps.connect: PracticeStepStatus.available,
        PracticeTestSteps.inhaleTest: PracticeStepStatus.locked,
        PracticeTestSteps.exhaleTest: PracticeStepStatus.locked,
        PracticeTestSteps.fullTest: PracticeStepStatus.locked,
      },
    );
  }

  PracticeFlowState _recomputeLocks(PracticeFlowState input) {
    final s = Map<PracticeTestSteps, PracticeStepStatus>.from(input.status);

    final connectDone = s[PracticeTestSteps.connect] == PracticeStepStatus.completed;
    final inhaleDone = s[PracticeTestSteps.inhaleTest] == PracticeStepStatus.completed;
    final exhaleDone = s[PracticeTestSteps.exhaleTest] == PracticeStepStatus.completed;

    // Ensure connect is at least available if not done
    if (!connectDone) {
      s[PracticeTestSteps.connect] = PracticeStepStatus.available;

      if (s[PracticeTestSteps.inhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.inhaleTest] = PracticeStepStatus.locked;
      }
      if (s[PracticeTestSteps.exhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.exhaleTest] = PracticeStepStatus.locked;
      }
      if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.fullTest] = PracticeStepStatus.locked;
      }
      return PracticeFlowState(status: s);
    }

    // Connect done → unlock inhale
    if (!inhaleDone) {
      if (s[PracticeTestSteps.inhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.inhaleTest] = PracticeStepStatus.available;
      }
      if (s[PracticeTestSteps.exhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.exhaleTest] = PracticeStepStatus.locked;
      }
      if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.fullTest] = PracticeStepStatus.locked;
      }
      return PracticeFlowState(status: s);
    }

    // Inhale done → unlock exhale
    if (!exhaleDone) {
      if (s[PracticeTestSteps.exhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.exhaleTest] = PracticeStepStatus.available;
      }
      if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.fullTest] = PracticeStepStatus.locked;
      }
      return PracticeFlowState(status: s);
    }

    // Exhale done → unlock full test
    if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
      s[PracticeTestSteps.fullTest] = PracticeStepStatus.available;
    }

    return PracticeFlowState(status: s);
  }
}
