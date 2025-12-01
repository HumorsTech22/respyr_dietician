import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/screens/request_for_dietitian.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_event.dart';
import '../../bloc/dashboard_state.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/loading_screen.dart';
import '../../../../client-dashboard/data/bloc/client_bloc.dart';
import '../../../../client-dashboard/data/repository/client_repository.dart';

class Dashboard extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const Dashboard({super.key, required this.clientProfileModel});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(
        DashboardInitialized(widget.clientProfileModel),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientBloc>(
      create: (_) => ClientBloc(ClientRepository()),
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError && state.errorText != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorText!)),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingScreen();
          }

          if (state is DashboardReady) {
            final client = state.clientProfileModel!;
            final dietitian = state.dietitianDetailModel;

            if (dietitian == null) {
              return Center(
                child: RequestForDietitian(
                  clientProfileModel: client,
                  todayResult:state.todayResult ,
                ),
              );
            }

            return DashboardContent(
              clientProfile: client,
              dietitian: dietitian,
              plans: state.categorizedPlans!,
              todayResult: state.todayResult,
              todayDietData: state.todayDietData,
              todayDietError: state.todayDietError,
              plansError: state.plansError,
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Text(state.errorText ?? "Unknown error"),
            );
          }

          return const Center(child: Text("Initializing Dashboard..."));
        },
      ),
    );
  }
}
