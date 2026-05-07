import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/dialogs/floating_message.dart';
import 'package:respyr_dietitian/features/account_subscription/presentation/screens/subscription_screen.dart';
import 'package:respyr_dietitian/features/account_subscription/services/check_client_plan_service.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/widgets/loading_screen.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/checking_features_sheet.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/qua_profile/presentation/screens/qua_profile.dart';
import 'package:respyr_dietitian/features/menu/services/notification_service.dart';
import 'package:respyr_dietitian/features/science/presentation/reference_screen.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../client-dashboard/extras/logout.dart';
import '../../../../../common/screens/app_webview_screen.dart';
import '../../../../../core/size/get_height.dart';
import '../../../../support/presentation/screens/support.dart' show SupportScreen;
import '../../../../webview/utils/urls.dart';
import '../../../qua_dashboard/bloc/qua_dashboard_bloc.dart';
import '../../../qua_dashboard/bloc/qua_dashboard_event.dart';
import '../../../qua_dashboard/bloc/qua_dashboard_state.dart';

class DashboardMenuScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final CheckClientPlanResponse planData;
  final UserHabitsModel userHabitsModel;

  const DashboardMenuScreen({
    super.key,
    required this.clientProfileModel, required this.planData, required this.userHabitsModel,
  });

  @override
  State<DashboardMenuScreen> createState() => _DashboardMenuScreenState();
}

class _DashboardMenuScreenState extends State<DashboardMenuScreen> {
  bool _isNotificationsEnabled = false;
  bool _isUpdatingNotification = false;

  @override
  void initState() {
    super.initState();
    _isNotificationsEnabled =
        widget.clientProfileModel.isNotificationsEnabledBool;
  }

  Future<void> _updateNotificationStatus(
      BuildContext context,
      QuaDashboardReady state,
      bool value,
      ) async {
    if (_isUpdatingNotification) return;

    final previousValue = _isNotificationsEnabled;

    setState(() {
      _isNotificationsEnabled = value;
      _isUpdatingNotification = true;
    });

    final isUpdated = await NotificationService().updateNotification(
      profileId: state.client.profileId,
      isEnabled: value,
    );

    if (!mounted) return;

    if (isUpdated) {

      FloatingMessage.show(context, message: value ? "Notification enabled" : "Notification disabled");

      context.read<QuaDashboardBloc>().add(
        QuaLoadClientAndDietitian(email: state.client.email),
      );
    } else {
      setState(() {
        _isNotificationsEnabled = previousValue;
      });

      FloatingMessage.show(context, message:  "Failed to update notification settings");

    }

    if (mounted) {
      setState(() {
        _isUpdatingNotification = false;
      });
    }
  }

  void navigateToDashboard(BuildContext context, ClientProfileModel client){
    // Navigator.pushReplacement(
    //   context,
    //   PageRouteBuilder(
    //     transitionDuration: const Duration(milliseconds: 300),
    //     reverseTransitionDuration: const Duration(milliseconds: 300),
    //     pageBuilder: (context, animation, secondaryAnimation) =>
    //         QuaDashboardScreen(clientProfileModel: client ),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       final tween = Tween<Offset>(
    //         begin: const Offset(-1.0, 0.0), // from left
    //         end: Offset.zero,
    //       ).chain(CurveTween(curve: Curves.easeInOut));
    //
    //       return SlideTransition(
    //         position: animation.drive(tween),
    //         child: child,
    //       );
    //     },
    //   ),
    // );
    context.go(AppRoutes.clientDashboard, extra: client);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuaDashboardBloc()
        ..add(
          QuaLoadClientAndDietitian(
            email: widget.clientProfileModel.email,
          ),
        ),
      child: BlocConsumer<QuaDashboardBloc, QuaDashboardState>(
        listenWhen: (previous, current) {
          final prevMsg =
          previous is QuaDashboardReady ? previous.errorMessage : null;
          final currMsg =
          current is QuaDashboardReady ? current.errorMessage : null;
          return currMsg != null && currMsg != prevMsg;
        },
        listener: (context, state) {
          if (state is QuaDashboardReady) {
            final serverNotificationValue =
                state.client.isNotificationsEnabledBool;

            if (!_isUpdatingNotification &&
                _isNotificationsEnabled != serverNotificationValue) {
              setState(() {
                _isNotificationsEnabled = serverNotificationValue;
              });
            }

            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: const Color(0xFFDA5747),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          }
        },
        builder: (context, state) {
          if (state is QuaDashboardLoading) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // context.go(AppRoutes.clientDashboard,  extra: widget.clientProfileModel);
                navigateToDashboard(context, widget.clientProfileModel);
              },
              child: LoadingScreen(),
            );
          }

          if (state is QuaDashboardError) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                // context.go(AppRoutes.clientDashboard,  extra: widget.clientProfileModel);

                navigateToDashboard(context, widget.clientProfileModel);
              },
              child: Scaffold(
                backgroundColor: const Color(0xFFF5F7FA),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  title: Text(
                    "General",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                  centerTitle: false,
                ),
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(rh(context: context, px: 16)),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is QuaDashboardReady) {
            return _buildScreen(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, QuaDashboardReady state) {
    final s = rh(context: context, px: 1);
    final client = state.client;

    _isNotificationsEnabled = state.client.isNotificationsEnabledBool ;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // context.go(AppRoutes.clientDashboard,  extra: client);
        // Navigator.pop(context);
        // if (didPop) return;
        // Navigator.of(context).maybePop();
        navigateToDashboard(context, state.client);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            "General",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15 * s,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.30,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * s),
                  child: SizedBox(height: 10 * s),
                ),

                /// Account Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Account",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 34 * s,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2.04,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuaProfile(
                              clientProfileModel: client, userHabitsModel: widget.userHabitsModel,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15 * s),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuaProfile(
                          clientProfileModel: client, userHabitsModel: widget.userHabitsModel,
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15 * s),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * s,
                        vertical: 30 * s,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoBlock(
                            label: "Name",
                            value: client.profileName,
                            s: s,
                          ),
                          SizedBox(height: 25 * s),
                          _InfoBlock(
                            label: "Email",
                            value: client.email,
                            s: s,
                          ),
                          SizedBox(height: 25 * s),
                          _InfoBlock(
                            label: "Reference ID",
                            value: client.dietitianId,
                            s: s,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// General Section
                SizedBox(height: 30 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * s),
                  child: Text(
                    "General",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34 * s,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15 * s),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15 * s, vertical: 20),

                      child: Column(
                        children: [

                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubscriptionScreen(
                                    clientProfileModel: client,
                                    // planData: widget.planData,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Your Plan",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 15 * s,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                            letterSpacing: -0.30,
                                          ),
                                        ),
                                        SizedBox(height: 10 * s),

                                        if (widget.planData.data!.isFreeTrial == true) ...[
                                          Text(
                                            "Free Trial",
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF535359),
                                              fontSize: 12 * s,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.24,
                                              height: 1.0,
                                            ),
                                          ),
                                        ] else if (widget.planData.data!.planStatus
                                            .toString()
                                            .toLowerCase() ==
                                            "expired") ...[
                                          Text(
                                            "No Active Plan",
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFA1A1A1),
                                              fontSize: 12 * s,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.24,
                                              height: 1.0,
                                            ),
                                          ),
                                        ] else if (widget.planData.data!.planStatus
                                            .toString()
                                            .toLowerCase() ==
                                            "active") ...[
                                          Row(
                                            children: [
                                              Text(
                                                widget.planData.data!.planName.toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFF535359),
                                                  fontSize: 12 * s,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: -0.24,
                                                  height: 1.0,
                                                ),
                                              ),
                                              SizedBox(width: rh(context: context, px: 10)),
                                              Container(
                                                width: 1,
                                                height: 12 * s,
                                                color: const Color(0xFF535359),
                                              ),
                                              SizedBox(width: rh(context: context, px: 10)),
                                              Text(
                                                "Active",
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFF3EAF58),
                                                  fontSize: 12 * s,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: -0.24,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          Text(
                                            "No Active Plan",
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFA1A1A1),
                                              fontSize: 12 * s,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: -0.24,
                                              height: 1.0,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20 * s,),

                          _buildButton(context, "Practice test", (){



                            CheckingFeaturesSheet.show(
                              context,
                              dieticianId: widget.clientProfileModel.dietitianId,
                              onComplete: (features, needsPractice) {

                                if(features.data.practiceTestAllow){
                                  context.push(
                                    '/practice-flow_shell',
                                    extra: widget.clientProfileModel,
                                  );
                                }else{
                                  FloatingMessage.show(
                                    context,
                                    message: "This featured is not available for your account ",
                                    type: FloatingMessageType.error,
                                  );
                                }

                              },
                            );





                          }, s),
                          SizedBox(height: 20 * s,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Notifications",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF252525),
                                          fontSize: 15 * s,
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                          letterSpacing: -0.30,
                                        ),
                                      ),
                                      SizedBox(height: 4 * s),
                                      Text(
                                        "Daily diet and test reminders",
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF535359),
                                          fontSize: 12 * s,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IgnorePointer(
                                  ignoring: _isUpdatingNotification,
                                  child: Opacity(
                                    opacity: _isUpdatingNotification ? 0.6 : 1,
                                    child: Switch(
                                      value: _isNotificationsEnabled,
                                      onChanged: (value) => _updateNotificationStatus(
                                        context,
                                        state,
                                        value,
                                      ),
                                      inactiveTrackColor: const Color(0xFFE1E6ED),
                                      inactiveThumbColor:  const Color(0xFFA1A1A1),
                                      trackOutlineWidth: const WidgetStatePropertyAll(0),
                                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                                      activeTrackColor: const Color(0xFF308BF9),
                                      activeColor: const Color(0xFFCAE1FF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

                /// Legal Section
                SizedBox(height: 30 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * s),
                  child: Text(
                    "Legal",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34 * s,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15 * s),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * s,
                      vertical: 10 * s,
                    ),
                    child: Column(
                      children: [
                        _buildButton(
                          context,
                          "Privacy Policy",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppWebViewScreen(
                                url: WebViewUrls.privacyPolicy,
                                title: "Privacy Policy",
                              ),
                            ),
                          ),
                          s,
                        ),
                        _buildButton(
                          context,
                          "Terms and Conditions",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppWebViewScreen(
                                url: WebViewUrls.termsAndConditions,
                                title: "Terms and Conditions",
                              ),
                            ),
                          ),
                          s,
                        ),
                      ],
                    ),
                  ),
                ),

                /// Resource Section
                SizedBox(height: 30 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * s),
                  child: Text(
                    "Resource",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34 * s,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15 * s),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * s,
                      vertical: 10 * s,
                    ),
                    child: Column(
                      children: [
                        _buildButton(
                          context,
                          "Science",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppWebViewScreen(
                                url: WebViewUrls.research,
                                title: "Research",
                              ),
                            ),
                          ),
                          s,
                        ),
                        _buildButton(
                          context,
                          "References",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReferenceScreen(),
                            ),
                          ),
                          s,
                        ),
                      ],
                    ),
                  ),
                ),

                /// Support Section
                SizedBox(height: 30 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17 * s),
                  child: Text(
                    "Support",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34 * s,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                SizedBox(height: 10 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15 * s),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * s,
                      vertical: 10 * s,
                    ),
                    child: _buildButton(
                      context,
                      "Support",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupportScreen(),
                        ),
                      ),
                      s,
                    ),
                  ),
                ),

                /// Logout Button
                SizedBox(height: 50 * s),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 17 * s,
                    vertical: 17 * s,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52 * s,
                    child: OutlinedButton(
                      onPressed: () => Logout().show(
                        context,
                        isLoggingOut: (bool _) {},
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDA5747),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1 * s,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * s),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/images/icons/ic_logout.svg",
                            width: 18 * s,
                            height: 18 * s,
                          ),
                          SizedBox(width: 10 * s),
                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFDA5747),
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      VoidCallback onPressed,
      double s,
      ) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFF252525),
          padding: EdgeInsets.symmetric(
            vertical: 10 * s,
            horizontal: 10 * s,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15 * s,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.30,
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_outlined),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final double s;

  const _InfoBlock({
    required this.label,
    required this.value,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15 * s,
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: -0.30,
          ),
        ),
        SizedBox(height: 2 * s),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12 * s,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }


}