import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_state.dart';
import 'package:respyr_dietitian/common/features_allow/data/model/features_allow_model.dart';
import 'package:respyr_dietitian/common/features_allow/data/services/features_allow_service.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';

class QuaDashboardSwipeActionOverlay extends StatelessWidget {
  final ClientProfileModel clientProfile;
  final void Function(TestDataState testState) onSwiped;

  const QuaDashboardSwipeActionOverlay({
    super.key,
    required this.clientProfile,
    required this.onSwiped,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: BlocBuilder<TodayTestDataBloc, TestDataState>(
        buildWhen: (prev, curr) => prev.result != curr.result,
        builder: (context, testState) {
          return FutureBuilder<FeaturesAllowResponse>(
            future: FeaturesAllowService().fetchFeaturesAllow(
              dieticianId: clientProfile.dietitianId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }

              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final featuresResult = snapshot.data!;
              final featuresData = featuresResult.data;

              if (testState.result != null && !featuresData.multipleReading) {
                return const SizedBox.shrink();
              }

              return Center(
                child: SwipeButtonWidget(
                  onSwiped: () => onSwiped(testState),
                ),
              );
            },
          );
        },
      ),
    );
  }
}