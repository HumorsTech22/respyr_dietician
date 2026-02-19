import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/size/get_height.dart';
import '../../../../../routes/app_routes.dart';
import '../../bloc/practice_flow_bloc.dart';
import '../../domain/enums/practice_test.dart';
import '../widgets/practice_menu.dart';

class PracticeTestScreen extends StatelessWidget {
  const PracticeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {



    final steps = const [
      PracticeTestSteps.connect,
      PracticeTestSteps.inhaleTest,
      PracticeTestSteps.exhaleTest,
      PracticeTestSteps.fullTest,
    ];

    Widget divider() => Column(
      children: [
        SizedBox(height: rh(context: context, px: 20)),
        Container(color: const Color(0xFFD9D9D9), height: rh(context: context, px: 1)),
        SizedBox(height: rh(context: context, px: 20)),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              size: rh(context: context, px: 22),
              color: const Color(0xFF252525),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 20) , vertical: rh(context: context, px: 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Practice using your\nRespyr device",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: rh(context: context, px: 28)),
              Expanded(
                child: BlocBuilder<PracticeFlowBloc, PracticeFlowState>(
                  builder: (context, state) {

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: steps.length,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => divider(),
                      itemBuilder: (context, index) {
                        final step = steps[index];

                        final enabled = state.isEnabled(step);
                        final completed = state.isCompleted(step);
                        final status = state.stepStatus(step);

                        return PracticeMenu(
                          enabled: enabled,
                          isStepCompleted: completed,
                          practiceTestStep: step,
                          onItemClicked: () {
                            if (!enabled) return;

                            switch (step) {
                              case PracticeTestSteps.connect:
                                context.push(
                                  '${AppRoutes.practiceFlowShell}/${AppRoutes.startDeviceScreen}',
                                );
                                break;

                              case PracticeTestSteps.inhaleTest:
                                context.push(
                                  '${AppRoutes.practiceFlowShell}/${AppRoutes.practiceTestInhaleScreen}',
                                );
                                break;

                              case PracticeTestSteps.exhaleTest:
                              case PracticeTestSteps.fullTest:
                              // later routes
                                break;
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: rh(context: context, px: 61),
                child: ElevatedButton(
                  onPressed: (){

                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308BF9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text("Begin Your Journey",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.10,
                        letterSpacing: 0.30,
                      ),
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
