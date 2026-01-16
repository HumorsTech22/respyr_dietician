import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/widgets/loading_screen.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/screens/qua_dashboard.dart';

import '../../../../../fcm-manager/fcm_token_service.dart';
import '../../bloc/qua_dashboard_bloc.dart';
import '../../bloc/qua_dashboard_event.dart';
import '../../bloc/qua_dashboard_state.dart';

import '../../target/bloc/metabolism_target_bloc.dart';
import '../../target/bloc/metabolism_target_event.dart';
import '../../target/bloc/metabolism_target_state.dart';
import '../../target/data/repository/metabolism_target_repository.dart';
import '../../target/data/services/metabolism_target_service.dart';
import 'error_screen.dart';

class QuaDashboardScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;

  const QuaDashboardScreen({
    super.key,
    required this.clientProfileModel,
  });

  void _fetchTarget(BuildContext context) {
    context.read<MetabolismTargetBloc>().add(
      FetchMetabolismTarget(
        age: int.tryParse(clientProfileModel.age) ?? 0,
        gender: clientProfileModel.gender,
        heightCm: double.tryParse(clientProfileModel.height) ?? 0.0,
        currentWeight: double.tryParse(clientProfileModel.weight) ?? 0.0,
        diabetic: false,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    FCMService.saveTokenToServer(clientProfileModel.profileId);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => QuaDashboardBloc()
            ..add(
              QuaLoadClientAndDietitian(email: clientProfileModel.email),
            ),
        ),
        BlocProvider(
          create: (_) {
            final targetService = MetabolismTargetService();
            final repo = MetabolismTargetRepository(targetService);
            final bloc = MetabolismTargetBloc(repo: repo);

            bloc.add(
              FetchMetabolismTarget(
                age: int.tryParse(clientProfileModel.age) ?? 0,
                gender: clientProfileModel.gender,
                heightCm: double.tryParse(clientProfileModel.height) ?? 0.0,
                currentWeight: double.tryParse(clientProfileModel.weight) ?? 0.0,
                diabetic: false,
              ),
            );

            return bloc;
          },
        ),
      ],
      child: BlocBuilder<QuaDashboardBloc, QuaDashboardState>(
        builder: (context, state) {
          if (state is QuaDashboardLoading) {
            return const LoadingScreen();
          }

          if (state is QuaDashboardError) {
            return ErrorScreen(
              state: state,
              retryButtonClicked: () {
                context.read<QuaDashboardBloc>().add(
                  QuaRefreshClientAndDietitian(
                    email: clientProfileModel.email,
                  ),
                );

                // Refetch target ranges too
                _fetchTarget(context);
              },
            );
          }

          if (state is QuaDashboardReady) {
            // ✅ safely compute min/max (no record, no nullable passing)
            double minRange = 0.0;
            double maxRange = 0.0;

            final targetState = context.watch<MetabolismTargetBloc>().state;
            if (targetState is MetabolismTargetLoaded) {
              final rangeStr = targetState
                  .data.targetScores["target_fat_loss_metabolism_score %"] ??
                  "";

              final parsed = extractRange(rangeStr);
              if (parsed.length >= 2) {
                minRange = parsed[0];
                maxRange = parsed[1];
              }
            }

            return QuaDashboard(
              clientProfile: state.client,
              dietitianDetailModel: state.dietitian,
              currentMinRange: minRange,
              currentMaxRange: maxRange,
            );
          }

          return const LoadingScreen();
        },
      ),
    );
  }

  /// Helper function to extract numeric range from a string like "70.0 - 85.0"
  List<double> extractRange(String value) {
    final regex = RegExp(r'([\d.]+)');
    final matches = regex.allMatches(value);

    if (matches.length < 2) return [];

    return [
      double.tryParse(matches.elementAt(0).group(0)!) ?? 0.0,
      double.tryParse(matches.elementAt(1).group(0)!) ?? 0.0,
    ];
  }
}
