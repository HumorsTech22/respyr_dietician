import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../practice_test_home/bloc/practice_flow_bloc.dart';

class PracticeFlowShell extends StatelessWidget {
  final Widget child;
  const PracticeFlowShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeFlowBloc()..add(const PracticeFlowInit()),
      child: child,
    );
  }
}
