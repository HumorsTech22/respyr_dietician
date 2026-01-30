import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';



// Model Imports
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/retake_test/presentation/screens/retake_test_screen.dart';
import '../../../../../client-dashboard/data/model/dietitian_model.dart';

// Bloc Imports
import '../../../../../client-dashboard/today_result/today_test_data_bloc.dart';
import '../../../../../client-dashboard/today_result/today_test_data_state.dart';
import '../../../../../client-dashboard/today_result/today_test_data_event.dart';
import '../../../../../client-dashboard/today_result/today_test_data_repository.dart';
import '../../../../../client-dashboard/today_result/today_test_data_api_service.dart';

import '../../../../../rular_arc_progress.dart';
import '../../../../../test.dart';
import '../../../../bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import '../../../../bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import '../../bloc/latest_test_bloc.dart';
import '../../bloc/latest_test_event.dart';
import '../../bloc/latest_test_state.dart';

// Utility & Widget Imports
import '../../../../../common/dialogs/abort_sheet_dialog.dart';
import '../../../../../common/dialogs/floating_message.dart';
import '../../../../../common/widgets/abort_device_manager.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import '../../../../dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';
import '../../../../gifting/dashboard/services/complete_test_history.dart';
import '../../../../profile_info/data/model/dietician_detail_model.dart';
import '../../../presentation/widgets/loading_screen.dart';
import '../../core/color_manager.dart';
import '../../data/models/latest_test_data.dart';
import '../../data/repository/latest_test_repository.dart';
import '../../data/services/latest_test_service.dart';

import '../../qua_profile/presentation/screens/qua_profile.dart';
import '../widgets/dietitian_info.dart';
import '../widgets/hero_calender_widget.dart';
import '../widgets/score_chart.dart';

class QuaDashboard extends StatefulWidget {
  final ClientProfileModel clientProfile;
  final DietitianDetailModel? dietitianDetailModel;

  final double currentMinRange;
  final double currentMaxRange;

  const QuaDashboard({
    super.key,
    required this.clientProfile,
    this.dietitianDetailModel,
    required this.currentMinRange,
    required this.currentMaxRange,
  });

  @override
  State<QuaDashboard> createState() => _QuaDashboardState();
}

class _QuaDashboardState extends State<QuaDashboard> with WidgetsBindingObserver {
  late final LatestTestBloc _latestTestBloc;
  late final TodayTestDataBloc _todayTestDataBloc;

  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _dateList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeBlocs();
    _refreshData();
  }

  void _initializeBlocs() {
    _latestTestBloc = LatestTestBloc(repo: LatestTestRepository(LatestTestService()));
    _todayTestDataBloc = TodayTestDataBloc(TodayTestDataRepository(TodayTestDataApiService()));
  }

  void _refreshData() {
    final dateStr = DateHelper.formatDate(_selectedDate);

    _latestTestBloc.add(
      FetchLatestTest(
        dietitianId: widget.clientProfile.dietitianId.toString(),
        profileId: widget.clientProfile.profileId.toString(),
        date: dateStr,
      ),
    );

    _todayTestDataBloc.add(
      LoadTestDataForDay(
        dietitianId: widget.clientProfile.dietitianId.toString(),
        profileId: widget.clientProfile.profileId.toString(),
        date: _selectedDate,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _latestTestBloc.close();
    _todayTestDataBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _handleStartTest() async {

    context.pushReplacement(
      AppRoutes.retakeTestScreen,
      extra: widget.clientProfile,
    );




    //
    // context.push(
    //   AppRoutes.bluetoothInhaleScreen,
    //   extra: ExhaleScreenParams(
    //     clientProfileModel: widget.clientProfile,
    //     baseValue: "/913.3/",
    //     dietPlanStrategyModel: _generateMockStrategy(),
    //     minRange: widget.currentMinRange,
    //     maxRange: widget.currentMaxRange,
    //   ),
    // );

    // context.push(
    //   AppRoutes.bluetoothExhaleScreen,
    //   extra: ExhaleScreenParams(
    //     clientProfileModel: widget.clientProfile,
    //     baseValue: "/913/",
    //     dietPlanStrategyModel: _generateMockStrategy(),
    //     minRange: widget.currentMinRange,
    //     maxRange: widget.currentMinRange,
    //   ),
    // );


    //
    // final isAborted = await AbortDeviceManager.getAbortStatus();
    // if (!mounted) return;
    //
    // if (isAborted) {
    //   CheckAbortSheet.show(
    //     context: context,
    //     onTakeTextClick: _navigateToBluetooth,
    //   );
    // } else {
    //   _navigateToBluetooth();
    // }


    // final dummyParams = GeneratingResultParams(
    //   maxPressure: 120.0,
    //   bestPressure: 95.0,
    //   blowDuration: 6, // seconds
    //   blowValuesList: [20, 35, 50, 70, 90, 95],
    //
    //   clientProfileModel: widget.clientProfile,
    //
    //   dietPlanStrategyModel: _generateMockStrategy(),
    //
    //   minRange: 60,
    //   maxRange: 110,
    // );
    //
    //
    // await context.push(
    //   AppRoutes.bluetoothGeneratingResultScreen,
    //   extra:  dummyParams,
    // );


    // await context.push(
    //   AppRoutes.bluetoothCalibrationScreen,
    //   extra: {
    //     "client": widget.clientProfile,
    //     "strategy": _generateMockStrategy(),
    //     "min_range": widget.currentMinRange,
    //     "max_range": widget.currentMaxRange,
    //   },
    // );



    // await context.push(
    //   AppRoutes.bluetoothInhaleScreen,
    //   extra: {
    //     "client": widget.clientProfile,
    //     "strategy": _generateMockStrategy(),
    //     "min_range": widget.currentMinRange,
    //     "max_range": widget.currentMaxRange,
    //   },
    // );
  }

  Future<void> _navigateToBluetooth() async {
    await context.push(
      AppRoutes.bluetoothDeviceConnectivity,
      extra: {
        "client": widget.clientProfile,
        "strategy": _generateMockStrategy(),
        "min_range": widget.currentMinRange,
        "max_range": widget.currentMaxRange,
      },
    );

    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _latestTestBloc),
        BlocProvider.value(value: _todayTestDataBloc),
      ],
      child: BlocBuilder<LatestTestBloc, LatestTestState>(
        builder: (context, state) {
          if (state is LatestTestLoading) return const LoadingScreen();

          final LatestTestData? testData =
          state is LatestTestLoaded ? state.data : null;

          final bool hasData = testData != null;

          final String? zone =
              testData?.testJsonData?.fatLossMetabolismScore?.zone;

          final Color themeColor = (hasData && zone != null)
              ? ColorManager.getZoneColor(zone: zone)
              : const Color(0xFFA5A9AF);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: themeColor,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  _buildScrollableContent(context, hasData, testData, themeColor),
                  _buildSwipeActionOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildScrollableContent(
      BuildContext context,
      bool hasData,
      LatestTestData? data,
      Color themeColor,
      ) {
    final double minRange = data?.minRange ?? widget.currentMinRange;
    final double maxRange = data?.maxRange ?? widget.currentMaxRange;

    final double latestScore =
        data?.testJsonData?.fatLossMetabolismScore?.score.toDouble() ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGradientHeader(themeColor, hasData, data),
          const SizedBox(height: 30),

          if (hasData && data != null) _buildViewResultAction(data),

          const SizedBox(height: 40),

          _buildScoreChartSection(latestScore, minRange, maxRange),

          const SizedBox(height: 24),
          DietitianInfo(dietitianDetailModel: widget.dietitianDetailModel),
          const SizedBox(height: 120),


          // ElevatedButton(
          //   onPressed: (){
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => Test(),
          //       ),
          //     );
          //   },
          //   child: Text("Button",
          //
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildGradientHeader(Color color, bool hasData, LatestTestData? data) {
    final scoreObj = data?.testJsonData?.fatLossMetabolismScore;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.50, 0.00),
          end: const Alignment(0.50, 1.00),
          colors: [color, Colors.white],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopNavBar(),
            HeroCalenderWidget(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
                _refreshData();
              },
              dateList: _dateList,
            ),
            const SizedBox(height: 40),

            if (hasData && scoreObj != null) ...[
              _buildScoreDisplay(scoreObj),
              const SizedBox(height: 60),
              _buildZoneInfoCard(color, scoreObj),
            ] else ...[
              const SizedBox(height: 40),
              _buildNoDataPrompt(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.clientProfile.profileName,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
              Text(
                DateHelper.getGreeting(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _ProfileCircle(clientProfile: widget.clientProfile),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(dynamic fatLossScore) {
    final num score = fatLossScore.score ?? 0;

    return Column(
      children: [
        Text(
          "Metabolism Score",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              score.toDouble().toStringAsFixed(0),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 100,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "%",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneInfoCard(Color themeColor, dynamic score) {
    final String zone = score.zone ?? "NA";
    final String interpretation = score.clientInterpretation ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text(
            "Your Score is $zone!",
            style: GoogleFonts.poppins(
              color: themeColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            interpretation,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF4A4A4A),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChartSection(double latestScore, double minRange, double maxRange) {
    return ScoreChart(
      clientProfileModel: widget.clientProfile,
      latestScore: latestScore,
      latestScoreMinRange: minRange,
      latestScoreMaxRange: maxRange,
    );
  }

  Widget _buildSwipeActionOverlay() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: BlocBuilder<TodayTestDataBloc, TestDataState>(
        builder: (context, testState) {

          final dietitianId = widget.clientProfile.dietitianId?.trim().toLowerCase();
          if(testState.result!=null && dietitianId != 'respyrd01'){
            return SizedBox.shrink();
          }
          return Center(
            child: SwipeButtonWidget(
              onSwiped: _handleStartTest,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataPrompt() {
    final bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          SvgPicture.asset("assets/images/icons/no_test.svg", height: 80),
          const SizedBox(height: 24),
          Text(
            isToday ? "You Haven’t Tested\nYet Today" : "No Test Data Found",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? "Swipe below to start \nyour metabolism test!"
                : "Select another date to see\nyour history.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildViewResultAction(LatestTestData data) {

    return TextButton(
        onPressed: (){
          _navigateToDetailedResult(data.testId);
        },
        child: Text("View Result",
          style: GoogleFonts.poppins(
            color: const Color(0xFF308BF9),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.10,
            letterSpacing: 0.30,
          ),
        )
    );
  }

  Future<void> _navigateToDetailedResult(String testId) async {
    try {
      final result = await TestHistoryCompleteService.fetchTestHistoryComplete(
        dietitianId: widget.clientProfile.dietitianId,
        profileId: widget.clientProfile.profileId,
        testId: int.parse(testId),
      );

      if (!mounted) return;

      context.go(
        AppRoutes.dietitianResultScreen,
        extra: ResultScreenParams(
          result: result,
          clientProfileModel: widget.clientProfile,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      FloatingMessage.show(
        context,
        message: "Could not load result: $e",
        type: FloatingMessageType.error,
      );
    }
  }

  DietPlanStrategyModel _generateMockStrategy() {
    return DietPlanStrategyModel(
      id: -1,
      dietitianId: widget.clientProfile.dietitianId.toString(),
      clientId: widget.clientProfile.profileId.toString(),
      planTitle: "Standard Metabolism Protocol",
      dietType: "Balanced",
      planStartDate: DateTime.now(),
      planEndDate: DateTime.now().add(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      caloriesTarget: 2000,
      proteinTarget: 150,
      fiberTarget: 30,
      carbsTarget: 200,
      fatTarget: 70,
      waterTarget: 3.5,
      testNoAssigned: 1,
      isDiabetic: false,
      status: "active",
      goals: const [],
      approaches: const [],
      dietitianInfo: DietitianModel(
        id: 0,
        dietitianId: "N/A",
        name: widget.dietitianDetailModel?.name ?? "Dietitian",
        email: "",
        phoneNo: "",
        location: "",
        logo: "",
        dttm: "",
        password: "",
      ),
    );
  }
}

class _ProfileCircle extends StatelessWidget {
  final ClientProfileModel clientProfile;
  const _ProfileCircle({required this.clientProfile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuaProfile(clientProfileModel: clientProfile),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          "assets/images/icons/ic_profile.svg",
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
