import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_api_service.dart';
import 'package:respyr_dietitian/common/widgets/loading_widget.dart';

import '../../../features/gifting/dashboard/presentation/pages/dashboard.dart';
import '../../../features/profile_info/data/repository/dietician_repository.dart';
import '../../../features/profile_info/data/model/dietician_detail_model.dart';
import '../../data/model/client_profile_model.dart';

import '../../data/bloc/client_bloc.dart';
import '../../data/bloc/client_event.dart';
import '../../data/bloc/client_state.dart';
import '../../data/repository/client_repository.dart';

import 'client_with_dietitian_screen.dart';

class ClientDashboard extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const ClientDashboard({super.key, required this.clientProfileModel});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard>
    with WidgetsBindingObserver {
  final _dietitianRepo = DietitianRepository();
  final _clientRepo = ClientRepository();

  late final ClientBloc _clientBloc;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clientBloc = ClientBloc(_clientRepo);
    _fetchData();
  }

  @override
  void dispose() {
    _clientBloc.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when the app resumes from background
    if (state == AppLifecycleState.resumed) {
      _fetchData();
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another screen
    _fetchData();
  }

  void _fetchData() {
    _clientBloc.add(FetchClientProfile(
      profileId: widget.clientProfileModel.profileId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _clientBloc,
      child: BlocListener<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientLoaded) {
            _isFirstLoad = false;
          }
        },
        child: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if ((state is ClientLoading && _isFirstLoad) ||
                state is ClientInitial) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: LoadingWidget(loadingMessage: "Loading client"),
              );
            }

            if (state is ClientError) {
              return Scaffold(
                body: Center(
                  child: Text(state.message),
                ),
              );
            }

            if (state is ClientLoaded) {
              final client = state.client;

              if (client.dietitianId == "NA") {
                return GiftingDashboard(
                  clientProfileModel: widget.clientProfileModel,
                );
              }

              return FutureBuilder<DietitianDetailModel?>(
                future: _dietitianRepo.fetchDietitian(client.dietitianId),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Scaffold(
                      backgroundColor: Colors.white,
                      body: LoadingWidget(loadingMessage: ''),
                    );
                  }

                  if (snap.hasError || snap.data == null) {
                    return GiftingDashboard(
                      clientProfileModel: client,
                    );
                  }

                  final dietitian = snap.data!;
                  return ClientWithDietitianScreen(
                    clientProfileModel:client,
                    dietitianModel: dietitian,
                    todayTestDataApiService: TodayTestDataApiService(),
                  );
                },
              );
            }

            // If we're in a loading state but it's not the first load,
            // show the current content while refreshing in background
            if (state is ClientLoading) {
              // You might want to show a refresh indicator here
              // while keeping the current content visible
              return _buildContentWithRefreshIndicator(context);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Helper method to show refresh indicator when refreshing data
  Widget _buildContentWithRefreshIndicator(BuildContext context) {
    // You'll need to implement this based on your current state
    // For now, just return a simple loading screen
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}