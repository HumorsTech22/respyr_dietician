import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/repository/test_log_manager.dart';
import 'package:respyr_dietitian/client-dashboard/screens/test_history_card.dart';
import '../../app-permission-manager/notification_permission_request.dart';
import '../../common/widgets/inner_shadow.dart';
import '../../common/widgets/slide_to_confirm.dart';
import '../../fcm-manager/fcm_token_service.dart';
import '../../notification-manager/screens/notification_screen.dart';
import '../../routes/route_observer.dart';
import '../../settings-manager/app_settings.dart';
import '../bloc/diet_plan_bloc.dart';
import '../bloc/diet_plan_event.dart';
import '../bloc/diet_plan_state.dart';
import '../data/repositories/diet_plan_repository.dart';
import '../data/services/diet_plan_service.dart';
import '../extras/meal_type_helper.dart';
import '../model/diet_plan_strategy_model.dart';
import '../model/dietitian_model.dart';
import '../widgets/bottom-sheets/test_reminder_sheet.dart';
import 'consultant_info_card.dart';
import 'diet_plan_card.dart';
import 'diet_plan_hero.dart';


class ClientDashboard extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const ClientDashboard({super.key, required this.clientProfileModel});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> with WidgetsBindingObserver, RouteAware {
  late DietPlanStrategyModel dummyDietPlan;
  late DietitianModel dietitianModel;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);



    askPermission();
    saveFCMToken();
    checkTestLog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void saveFCMToken() async {
    FCMService.saveTokenToServer(widget.clientProfileModel.profileId, await getDeviceId());
  }

  void askPermission() async {
    await askNotificationPermission();
  }



  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  void showTestReminder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // lets the sheet grow as needed (with scroll)
      builder: (_) => const TestReminderSheet(),
    );
  }


  void checkTestLog() async {
    final now = DateTime.now();
    if (now.isBefore(AppSettings().testReminderEndTime)) {
      final dateYmd = "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')}";

      final status = await TestLogService().getTestLogStatus(
        clientId: widget.clientProfileModel.profileId,
        dateYmd: dateYmd,
        dietPlanId: "RespyrD01",
      );
      if (!status.hasLog) {
        showTestReminder();
      }
    }
  }


  @override
  Widget build(BuildContext context) {



    dietitianModel = DietitianModel(
      id: 1,
      dietitianId: 'diet001',
      name: 'Dt. John',
      phoneNo: '9988776655',
      email: 'manoranjan@example.com',
      location: 'Bhubaneswar',
      logo:
      'https://humorstech.com/humors_app/app_final/dieticianapp/api/get_dietician_logo.php?dietician_id=RespyrD01',
      dttm: '2025-08-03 12:34:56',
      password: 'secret123',
    );


    late Color  statusBarColor = ThemeHelper().getStatusBarColor();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );



    return BlocProvider(
      create: (_) => DietPlanBloc(DietPlanRepository(DietPlanService()))
        ..add(FetchPlans(dietitianId: widget.clientProfileModel.dieticianId, clientId:  widget.clientProfileModel.profileId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<DietPlanBloc, DietPlanState>(
          builder: (context, state) {
            if (state.status == LoadStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == LoadStatus.failure) {
              return Center(
                child: Text(
                  "Error: ${state.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state.status == LoadStatus.success) {
              final categorized = state.data;
              if (categorized == null ||
                  (categorized.active.isEmpty &&
                      categorized.completed.isEmpty &&
                      categorized.cancelled.isEmpty &&
                      categorized.other.isEmpty)) {
                return const Center(child: Text("No diet plans found"));
              }

              return SafeArea(
                child: Stack(
                  children: [


                    SingleChildScrollView(
                      child: DashboardContent(
                        dietitianModel: dietitianModel,
                        clientProfileModel:widget.clientProfileModel,
                        categorizedPlans: state.data!,
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: ShapeDecoration(

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 8.40,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: ConfirmationSlider(
                              onConfirmation: () {

                              },
                              backgroundColor: const Color(0xFFF0F0F0),
                              height: 61,
                              width: 209,
                              text: "Slide to start test",


                            ),
                          ),


                        ],
                      ),
                    )
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),

    );


  }
}

class DashboardContent extends StatelessWidget {

  final DietitianModel dietitianModel;
  final ClientProfileModel clientProfileModel;
  final CategorizedPlans categorizedPlans;
  const DashboardContent({super.key, required this.dietitianModel, required this.clientProfileModel, required this.categorizedPlans});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        DietPlanHero(dietitianModel: dietitianModel, clientProfileModel: clientProfileModel),
        const SizedBox(height: 20),
        TestHistoryCard(),
        const SizedBox(height: 20),
        DietPlanCard(activeData: categorizedPlans.active, completedData:  categorizedPlans.completed, canceledData:  categorizedPlans.cancelled,),
        const SizedBox(height: 40),
        ConsultantInfoCard(dietitianModel: dietitianModel),
        const SizedBox(height: 100),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>  NotificationScreen(targetId: clientProfileModel.profileId),
              ),
            );
          },
          child: const Text("Notification"),
        )
        ,const SizedBox(height: 100),
      ],
    );
  }
}