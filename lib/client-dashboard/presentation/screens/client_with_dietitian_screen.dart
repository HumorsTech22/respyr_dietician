import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/extras/meal_type_helper.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/consultant_info_card.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/diet_plan_card.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/diet_plan_hero.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/no_diet_plan_hero.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import '../../../features/bluetooth_device_connectivity/domain/repository/bluetooth_repository.dart';
import '../../../features/bluetooth_device_connectivity/domain/repository/bluetooth_repository_impl.dart';
import '../../../features/bluetooth_device_connectivity/presentation/pages/bluetooth_device_connectivity.dart';
import '../../../features/dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';
import '../../../features/gifting/dashboard/presentation/widgets/test_result_history.dart';
import '../../../features/test_history/test_history_by_date/data/models/test_data_record.dart';
import '../../data/bloc/diet_plan_bloc.dart';
import '../../data/bloc/diet_plan_event.dart';
import '../../data/bloc/diet_plan_state.dart';
import '../../data/model/client_profile_model.dart';
import '../../data/repositories/diet_plan_repository.dart';
import '../../data/services/diet_plan_service.dart';
import '../../extras/get_today_key.dart';
import '../../today_result/today_test_data_api_service.dart';
import '../../today_result/today_test_data_bloc.dart';
import '../../today_result/today_test_data_event.dart';
import '../../today_result/today_test_data_repository.dart';
import '../../today_result/today_test_data_state.dart';
import '../widgets/dashboard_appbar.dart';
import 'package:http/http.dart' as http;



class ClientWithDietitianScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianModel;
  final TodayTestDataApiService todayTestDataApiService;

  const ClientWithDietitianScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietitianModel,
    required this.todayTestDataApiService,
  });

  @override
  State<ClientWithDietitianScreen> createState() =>
      _ClientWithDietitianScreenState();
}

class _ClientWithDietitianScreenState extends State<ClientWithDietitianScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _fetchTodayDiet(
      String dietitianId, String profileId, String dietPlanId) async {
    final body = jsonEncode({
      'login_id': dietitianId,
      'profile_id': profileId,
      'diet_plan_id': dietPlanId,
    });

    final res = await http.post(
      Uri.parse("https://humorstech.com/dietitian/api/app/get_diet_plan.php"),
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response shape');
    }

    final dataList = decoded['data'] as List? ?? [];
    if (dataList.isEmpty) {
      throw Exception('No data in response');
    }

    final first = dataList.first as Map<String, dynamic>;
    final dietJson = (first['diet_json'] ?? {}) as Map<String, dynamic>;

    final todayKey = TodayKey().todayKey();
    final today = (dietJson[todayKey] ?? {}) as Map<String, dynamic>;

    // If API returns only one day
    if (today.isEmpty && dietJson.isNotEmpty) {
      final keys =
      dietJson.keys.map((e) => e.toString().toLowerCase()).toList();
      if (keys.length == 1) {
        final k = keys.first;
        return {
          'dayKey': k,
          'totals': dietJson[k]?['totals'] ?? const {},
          'meals': dietJson[k]?['meals'] ?? const [],
        };
      }
    }
    return {
      'dayKey': todayKey,
      'totals': today['totals'] ?? const {},
      'meals': today['meals'] ?? const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DietPlanBloc>(
          create: (_) => DietPlanBloc(DietPlanRepository(DietPlanService()))
            ..add(FetchPlans(
              dietitianId: widget.clientProfileModel.dietitianId,
              clientId: widget.clientProfileModel.profileId,
            )),
        ),
        BlocProvider<TodayTestDataBloc>(
          create: (_) => TodayTestDataBloc(
            TodayTestDataRepository(widget.todayTestDataApiService),
          )..add(LoadTestDataForDay(
            profileId: widget.clientProfileModel.profileId,
            date: DateTime.now(), dietitianId: widget.dietitianModel.dietitianId,
          )),
        ),
      ],
      child: BlocBuilder<DietPlanBloc, DietPlanState>(
        builder: (context, state) {
          final statusBarColor = state.status == LoadStatus.success &&
              state.data != null &&
              state.data!.active.isNotEmpty
              ? ThemeHelper().getStatusBarColor()
              : const Color(0xFFD3E5FF);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: statusBarColor,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: AppBar(
                  backgroundColor: ThemeHelper().getStatusBarColor(),
                  elevation: 0,
                ),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(child:  _buildContent(context, state, widget.clientProfileModel)),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child:  Center(
                        child: SwipeButtonWidget(
                          onSwiped: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RepositoryProvider<BluetoothRepository>(
                                  create: (_) => BluetoothRepositoryImpl(UuidBluetoothManager()),
                                  child:  BluetoothDeviceConnectivity(clientProfileModel: widget.clientProfileModel),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      ,)
                  ],
                ),
              ),


            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DietPlanState state, ClientProfileModel clientProfileModel) {
    if (state.status == LoadStatus.loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: LoadingWidget(loadingMessage: ''),
      );
    }

    if (state.status == LoadStatus.failure) {
      return Center(child: Text(state.error!));
    }

    if (state.status == LoadStatus.success) {
      final categorized = state.data;
      if (categorized == null || categorized.active.isEmpty) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                NoDietPlanHero(
                  clientProfileModel: widget.clientProfileModel,
                  dietitianDetailModel: widget.dietitianModel,
                ),
                const SizedBox(height: 30),
                BlocBuilder<TodayTestDataBloc, TestDataState>(
                  builder: (context, state) {
                    if (state.status == TestDataStatus.success) {
                      final r = state.records.first;
                      return TestResultHistory(testDataRecord: r);
                    }
                    return TestResultHistory(
                      testDataRecord: TestDataRecord.dummy(
                        profileId: widget.clientProfileModel.profileId,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 44),
                DietPlanCard(
                  activeData: [],
                  completedData: [],
                  canceledData: [],
                  dietitianDetailModel: widget.dietitianModel,
                  clientProfileModel: clientProfileModel,
                ),
                const SizedBox(height: 40),
                ConsultantInfoCard(
                  dietitianModel: widget.dietitianModel,
                  clientProfileModel: widget.clientProfileModel,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }

      final activePlan = categorized.active.first;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _fetchTodayDiet(
                  widget.dietitianModel.dietitianId,
                  widget.clientProfileModel.profileId,
                  activePlan.id.toString(),
                ),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return NoDietPlanHero(clientProfileModel: widget.clientProfileModel, dietitianDetailModel: widget.dietitianModel);
                  }
                  if (!snap.hasData) {
                    return const SizedBox.shrink();
                  }

                  final todayData = snap.data!;

                  return Column(
                    children: [
                      DietPlanHero(
                        clientProfileModel: widget.clientProfileModel,
                        dietitianDetailModel: widget.dietitianModel,
                        dietPlanStrategyModel: activePlan,
                        todayData: todayData,
                      ),
                      const SizedBox(height: 30),
                      BlocBuilder<TodayTestDataBloc, TestDataState>(
                        builder: (context, state) {
                          if (state.status == TestDataStatus.success) {
                            final r = state.records.first;
                            return TestResultHistory(testDataRecord: r);
                          }
                          return TestResultHistory(
                            testDataRecord: TestDataRecord.dummy(
                              profileId: widget.clientProfileModel.profileId,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 50),
                      DietPlanCard(
                        activeData: categorized.active,
                        completedData: categorized.completed,
                        canceledData: categorized.cancelled,
                        dietitianDetailModel: widget.dietitianModel, clientProfileModel: clientProfileModel,
                      ),
                    ],
                  );
                },
              ),



              const SizedBox(height: 50),
              ConsultantInfoCard(
                dietitianModel: widget.dietitianModel,
                clientProfileModel: widget.clientProfileModel,
              ),
              const SizedBox(height: 50),
              // NextMealInfoScreen(),
              const SizedBox(height: 80),




            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
