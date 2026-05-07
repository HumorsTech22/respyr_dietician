import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client_login_manager/client_login_manager-1.dart';
import 'package:respyr_dietitian/features/account_subscription/data/model/check_client_plan_data.dart';
import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
// import 'package:respyr_dietitian/features/account_subscription/presentation/screens/free_trial_expired_screen.dart';
// import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/widgets/loading_screen.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/params/dashboard_params.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/screens/qua_dashboard.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/features/user_habits/data/services/fetch_user_habits.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../../core/appupdate/ios_update.dart';
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

class QuaDashboardScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const QuaDashboardScreen({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<QuaDashboardScreen> createState() => _QuaDashboardScreenState();
}

class _QuaDashboardScreenState extends State<QuaDashboardScreen> {
  bool _checkedUpdateOnce = false;
  bool _updating = false;
  bool _checkingPlan = false;
  bool _canOpenDashboard = true;
  bool _loadingHabits = false;

  late final QuaDashboardBloc _quaDashboardBloc;
  late final MetabolismTargetBloc _metabolismTargetBloc;

  // final CheckClientPlanService _checkClientPlanService = CheckClientPlanService();
  // CheckClientPlanResponse? _planResponse;

  UserHabitsModel? _userHabits;

  @override
  void initState() {
    super.initState();

    _quaDashboardBloc = QuaDashboardBloc();

    final targetService = MetabolismTargetService();
    final repo = MetabolismTargetRepository(targetService);
    _metabolismTargetBloc = MetabolismTargetBloc(repo: repo);

    FCMService.saveTokenToServer(widget.clientProfileModel.profileId);

    _startFlow();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkUpdate();
    });
  }

  Future<void> _startFlow() async {
    await _loadInitialData();
  }

  /*
  Future<void> _checkPlanAndProceed() async {
    if (!mounted) return;

    setState(() {
      _checkingPlan = true;
      _canOpenDashboard = false;
      _showPlanExpiredView = false;
    });

    final result = await _checkClientPlanService.checkClientPlan(
      profileId: widget.clientProfileModel.profileId,
    );

    if (!mounted) return;

    _planResponse = result;

    if (result.status == true) {
      final planStatus = (result.data?.planStatus ?? "").toLowerCase().trim();
      final planType = (result.data?.planType ?? "").toLowerCase().trim();
      final needsPurchase = result.data?.needsPurchase == true;

      final bool allowDashboard =
          planStatus == "active" &&
              (planType == "paid" || planType == "free_trial") &&
              !needsPurchase;

      if (allowDashboard) {
        setState(() {
          _checkingPlan = false;
          _canOpenDashboard = true;
          _showPlanExpiredView = false;
        });

        await _loadInitialData();
        return;
      }
    }

    setState(() {
      _checkingPlan = false;
      _canOpenDashboard = false;
      _showPlanExpiredView = true;
    });
  }
  */

  Future<void> _loadInitialData() async {
    _quaDashboardBloc.add(
      QuaLoadClientAndDietitian(
        email: widget.clientProfileModel.email,
      ),
    );

    _fetchTarget();
    await _fetchUserHabits();
  }

  void _fetchTarget() {
    _metabolismTargetBloc.add(
      FetchMetabolismTarget(
        age: int.tryParse(widget.clientProfileModel.age) ?? 0,
        gender: widget.clientProfileModel.gender,
        heightCm: double.tryParse(widget.clientProfileModel.height) ?? 0.0,
        currentWeight: double.tryParse(widget.clientProfileModel.weight) ?? 0.0,
        diabetic: false,
      ),
    );
  }

  Future<void> _fetchUserHabits() async {
    if (!mounted) return;

    setState(() {
      _loadingHabits = true;
    });

    try {
      final habits = await FetchUserHabitsService.fetchUserHabits(
        profileId: widget.clientProfileModel.profileId,
      );

      if (!mounted) return;

      setState(() {
        _userHabits = habits;
        _loadingHabits = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _userHabits = null;
        _loadingHabits = false;
      });
    }
  }

  Future<void> _retryDashboard() async {
    _quaDashboardBloc.add(
      QuaRefreshClientAndDietitian(
        email: widget.clientProfileModel.email,
      ),
    );

    _fetchTarget();
    await _fetchUserHabits();
  }

  bool _isNetworkOrServerIssue(String message) {
    final msg = message.toLowerCase();

    return msg.contains("no internet") ||
        msg.contains("network") ||
        msg.contains("timeout") ||
        msg.contains("timed out") ||
        msg.contains("server") ||
        msg.contains("socket") ||
        msg.contains("connection") ||
        msg.contains("unable to reach server") ||
        msg.contains("failed host lookup") ||
        msg.contains("clientexception");
  }

  Future<void> _checkUpdate() async {
    if (_checkedUpdateOnce) return;
    _checkedUpdateOnce = true;

    if (Platform.isAndroid) {
      await _checkAndroidInAppUpdate();
    } else if (Platform.isIOS) {
      await checkIosUpdate(context);
    }
  }

  Future<void> _checkAndroidInAppUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      final available =
          info.updateAvailability == UpdateAvailability.updateAvailable;

      if (!available) return;

      if (!mounted) return;

      setState(() {
        _updating = true;
      });

      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _updating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quaDashboardBloc.close();
    _metabolismTargetBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_updating || _checkingPlan || _loadingHabits) {
      return const LoadingScreen();
    }

    /*
    if (_showPlanExpiredView) {
      return FreeTrialExpiredScreen(
        clientProfileModel: widget.clientProfileModel,
        skipClicked: () async {
          if (!mounted) return;

          setState(() {
            _showPlanExpiredView = false;
            _checkingPlan = false;
            _canOpenDashboard = true;
          });

          await _loadInitialData();
        },
      );
    }
    */

    if (!_canOpenDashboard) {
      return const LoadingScreen();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<QuaDashboardBloc>.value(value: _quaDashboardBloc),
        BlocProvider<MetabolismTargetBloc>.value(value: _metabolismTargetBloc),
      ],
      child: BlocBuilder<QuaDashboardBloc, QuaDashboardState>(
        builder: (context, state) {
          if (state is QuaDashboardLoading) {
            return const LoadingScreen();
          }

          if (state is QuaDashboardError) {
            final isNetworkOrServerIssue =
            _isNetworkOrServerIssue(state.message);

            if (state.message.toLowerCase().contains("profile not found")) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Spacer(),
                      Text(
                        "Oops!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          "No account is linked to this email.\nPlease check the email address or sign up first.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.30,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            final cl = ClientLoginManager();
                            cl.clearClientProfile();

                            if (!mounted) return;

                            context.go(AppRoutes.signInOptions);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFC7C6CE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            "Go to sign in",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.10,
                              letterSpacing: 0.30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              );
            }

            if (isNetworkOrServerIssue) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Spacer(),
                      Text(
                        "Oops!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.30,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _retryDashboard();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFC7C6CE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            "Retry",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.10,
                              letterSpacing: 0.30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              );
            }

            return ErrorScreen(
              state: state,
              retryButtonClicked: () async {
                await _retryDashboard();
              },
            );
          }

          if (state is QuaDashboardReady) {
            double minRange = 0.0;
            double maxRange = 0.0;

            final targetState = context.watch<MetabolismTargetBloc>().state;

            if (targetState is MetabolismTargetLoaded) {
              final rangeStr =
                  targetState.data.targetScores["target_fat_loss_metabolism_score %"] ??
                      "";

              final parsed = extractRange(rangeStr);

              if (parsed.length >= 2) {
                minRange = parsed[0];
                maxRange = parsed[1];
              }
            }


            final CheckClientPlanResponse dummyPlanResponse = CheckClientPlanResponse(
              status: true,
              message: "Dummy active plan",
              data: CheckClientPlanData(
                profileId: widget.clientProfileModel.profileId,
                clientId: int.tryParse(widget.clientProfileModel.id.toString()),
                dieticianId: "",
                planType: "free_trial",
                planStatus: "active",
                isFreeTrial: true,
                subscriptionId: 0,
                couponCode: "",
                planCode: "DUMMY_FREE_TRIAL",
                planName: "Dummy Free Trial",
                durationMonths: 0,
                subscriptionStartDate: "2026-04-24",
                subscriptionEndDate: "2026-05-01",
                daysLeft: 7,
                trialDays: 7,
                trialStartDate: "2026-04-24",
                trialEndDate: "2026-05-01",
                needsPurchase: false,
              ),
            );

            return QuaDashboard(
              dashboardParams: DashboardParams(
                clientProfile: state.client,
                dietitianDetailModel: state.dietitian,

                // Subscription disabled for now.
                // If this gives error, make planData nullable in DashboardParams.
                planData: dummyPlanResponse,

                currentMinRange: minRange,
                currentMaxRange: maxRange,
                userHabitsModel: _userHabits,
              ),
            );
          }

          return const LoadingScreen();
        },
      ),
    );
  }

  List<double> extractRange(String value) {
    final regex = RegExp(r'([\d.]+)');
    final matches = regex.allMatches(value);

    if (matches.length < 2) return [];

    return [
      double.tryParse(matches.elementAt(0).group(0) ?? '') ?? 0.0,
      double.tryParse(matches.elementAt(1).group(0) ?? '') ?? 0.0,
    ];
  }
}