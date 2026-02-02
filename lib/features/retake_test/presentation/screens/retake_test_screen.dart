// lib/features/retake_test/presentation/screens/retake_test_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../routes/app_routes.dart';
import '../../bloc/retake_test_cubit.dart';
import '../../bloc/retake_test_state.dart';
import '../theme/retake_test_tokens.dart';
import '../widgets/retake_test_continue_button.dart';
import '../widgets/retake_test_options.dart';
import '../widgets/retake_test_title.dart';

class RetakeTestScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const RetakeTestScreen({super.key, required this.clientProfileModel});

  @override
  State<RetakeTestScreen> createState() => _RetakeTestScreenState();
}

class _RetakeTestScreenState extends State<RetakeTestScreen> {
  late final TextEditingController _detailsController;
  late final RetakeTestCubit _cubit;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController();
    _cubit = RetakeTestCubit();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RetakeTestCubit>.value(
      value: _cubit,
      child: BlocListener<RetakeTestCubit, RetakeTestState>(
        listenWhen: (p, n) => p.submitted != n.submitted && n.submitted == true,
        listener: (context, state) {
          context.pushReplacement(
            AppRoutes.testConditionScreen,
            extra: widget.clientProfileModel,
          );
        },
        child: Scaffold(
          backgroundColor: RetakeTestTokens.pageBg,
          appBar: AppBar(
            backgroundColor: RetakeTestTokens.pageBg,
            surfaceTintColor: RetakeTestTokens.pageBg,
            actions: [
              Semantics(
                button: true,
                label: 'Close',
                child: IconButton(
                  onPressed: () => context.go(
                    AppRoutes.clientDashboard,
                    extra: widget.clientProfileModel,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RetakeTestTokens.gapTop,
                const RetakeTestTitle(),
                RetakeTestTokens.gapAfterTitle,
                RetakeTestOptions(
                  detailsController: _detailsController,
                ),
              ],
            ),
          ),
          bottomNavigationBar: const RetakeTestContinueButton(),
        ),
      ),
    );
  }
}
