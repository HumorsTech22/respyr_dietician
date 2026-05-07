import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_api_service.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_repository.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/latest_test_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/repository/latest_test_repository.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/services/latest_test_service.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/params/dashboard_params.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/controllers/qua_dashboard_controller.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/qua_dashboard_body.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class QuaDashboard extends StatefulWidget {
  final DashboardParams dashboardParams;

  const QuaDashboard({
    super.key,
    required this.dashboardParams,
  });

  @override
  State<QuaDashboard> createState() => _QuaDashboardState();
}

class _QuaDashboardState extends State<QuaDashboard> with WidgetsBindingObserver {
  late final LatestTestBloc _latestTestBloc;
  late final TodayTestDataBloc _todayTestDataBloc;
  late final QuaDashboardController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _latestTestBloc = LatestTestBloc(
      repo: LatestTestRepository(LatestTestService()),
    );

    _todayTestDataBloc = TodayTestDataBloc(
      TodayTestDataRepository(TodayTestDataApiService()),
    );

    controller = QuaDashboardController(
      context: context,
      dashboardParams: widget.dashboardParams,
      latestTestBloc: _latestTestBloc,
      todayTestDataBloc: _todayTestDataBloc,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );

    controller.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    controller.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.disposeController();
    _latestTestBloc.close();
    _todayTestDataBloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _latestTestBloc),
        BlocProvider.value(value: _todayTestDataBloc),
      ],
      child: Scaffold(
        body: QuaDashboardBody(controller: controller),


        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              context.push(AppRoutes.clientDietPlan, extra: widget.dashboardParams.clientProfile);
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            backgroundColor: const Color(0xFFF0F0F0),
            child: SvgPicture.asset("assets/images/icons/ic_spoon_flate.svg")
          ),
        ),
      ),
    );
  }
}