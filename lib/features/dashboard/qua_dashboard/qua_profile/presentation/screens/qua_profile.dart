import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/client_dashboard.dart';
import 'package:respyr_dietitian/features/account_delete/services/delete_account_service.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/screens/qua_dashboard_screen.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/user_habits_model.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/screens/activity_update_screen.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/screens/food_preference_update_screen.dart';
import 'package:respyr_dietitian/features/user_habits/presentation/screens/goal_update_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../../client_login_manager/client_login_manager.dart';
import '../../../../../../core/size/get_height.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../bloc/qua_dashboard_bloc.dart';
import '../../../bloc/qua_dashboard_event.dart';
import '../../../bloc/qua_dashboard_state.dart';

class QuaProfile extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final UserHabitsModel userHabitsModel;

  const QuaProfile({
    super.key,
    required this.clientProfileModel,
    required this.userHabitsModel,
  });

  @override
  State<QuaProfile> createState() => _QuaProfileState();
}

class _QuaProfileState extends State<QuaProfile> {
  static const _bg = Color(0xFFF5F7FA);
  static const _textPrimary = Color(0xFF252525);
  static const _danger = Color(0xFFDA5747);
  static const _dangerPure = Color(0xFFDC2626);

  final DeleteAccountService _deleteAccountService = DeleteAccountService();

  bool _isDeletingAccount = false;
  bool _showDeleteSuccessOverlay = false;
  bool _navigationTriggered = false;

  late UserHabitsModel _safeHabitsModel;

  @override
  void initState() {
    super.initState();
    _safeHabitsModel = _buildSafeHabitsModel(widget.userHabitsModel);
  }

  UserHabitsModel _buildSafeHabitsModel(UserHabitsModel? habits) {
    if (habits != null) return habits;

    return UserHabitsModel(
      id: 0,
      profileId: widget.clientProfileModel.profileId,
      goal: "not_available",
      activity: "not_available",
      foodType: FoodTypeModel(
        dietType: "not_available",
        primaryCuisine: "not_available",
        secondaryCuisine: "not_available",
      ),
      dateTime: "",
      timeStamp: "",
    );
  }

  void _handleBack() {
    if (_showDeleteSuccessOverlay || _isDeletingAccount) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuaDashboardScreen(
          clientProfileModel: widget.clientProfileModel,
        ),
      ),
    );
  }

  String _formatHabitValue(String value) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == "not_available") {
      return "-";
    }
    return value.replaceAll("_", " ");
  }

  @override
  void dispose() {
    _deleteAccountService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuaDashboardBloc()
        ..add(
          QuaLoadClientAndDietitian(email: widget.clientProfileModel.email),
        ),
      child: BlocConsumer<QuaDashboardBloc, QuaDashboardState>(
        listenWhen: (prev, curr) {
          final prevMsg = (prev is QuaDashboardReady) ? prev.errorMessage : null;
          final currMsg = (curr is QuaDashboardReady) ? curr.errorMessage : null;
          return currMsg != null && currMsg != prevMsg;
        },
        listener: (context, state) {
          if (state is QuaDashboardReady && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: _danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is QuaDashboardLoading) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _handleBack();
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  leading: IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  title: Text(
                    "Profile",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                  centerTitle: false,
                ),
                body: const SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }

          if (state is QuaDashboardError) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _handleBack();
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  leading: IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  title: Text(
                    "Profile",
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
                          color: _textPrimary,
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
            return _buildScreen(context, state, state.client);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScreen(
      BuildContext context,
      QuaDashboardReady state,
      ClientProfileModel client,
      ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: (_showDeleteSuccessOverlay || _isDeletingAccount)
                ? null
                : _handleBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            "Account",
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
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: _isDeletingAccount || _showDeleteSuccessOverlay,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView(
                        padding: EdgeInsets.only(
                          bottom: rh(context: context, px: 16),
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: rh(context: context, px: 27)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 10),
                            ),
                            child: Row(
                              spacing: rh(context: context, px: 15),
                              children: [
                                SvgPicture.asset(
                                  "assets/images/icons/default1.svg",
                                  width: rh(context: context, px: 40),
                                  height: rh(context: context, px: 40),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    spacing: rh(context: context, px: 5),
                                    children: [
                                      Text(
                                        widget.clientProfileModel.profileName,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF252525),
                                          fontSize: rh(context: context, px: 20),
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                          letterSpacing: -0.80,
                                        ),
                                      ),
                                      Text(
                                        widget.clientProfileModel.email,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFA1A1A1),
                                          fontSize: rh(context: context, px: 12),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 25)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 10),
                            ),
                            child: _CardContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoItem(
                                    label: "Gender",
                                    value: widget.clientProfileModel.gender,
                                  ),
                                  SizedBox(
                                    height: rh(context: context, px: 28),
                                  ),
                                  _InfoItem(
                                    label: "Age",
                                    value: widget.clientProfileModel.age,
                                  ),
                                  SizedBox(
                                    height: rh(context: context, px: 28),
                                  ),
                                  _InfoItem(
                                    label: "Height",
                                    value:
                                    "${widget.clientProfileModel.height} cm",
                                  ),
                                  SizedBox(
                                    height: rh(context: context, px: 28),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _InfoItem(
                                          label: "Weight",
                                          value: "${state.client.weight} kg",
                                        ),
                                      ),
                                      SizedBox(
                                        width: rh(context: context, px: 12),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _showUpdateBottomSheet(
                                              context,
                                              state,
                                            ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: _textPrimary,
                                          minimumSize: Size(
                                            rh(context: context, px: 40),
                                            rh(context: context, px: 40),
                                          ),
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: rh(context: context, px: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 30)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 20),
                            ),
                            child: Column(
                              spacing: rh(context: context, px: 25),
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    final updatedActivity =
                                    await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ActivityUpdateScreen(
                                          initialActivity:
                                          _safeHabitsModel.activity,
                                          clientProfileModel:
                                          widget.clientProfileModel,
                                          userHabitsModel: _safeHabitsModel,
                                        ),
                                      ),
                                    );

                                    if (updatedActivity != null) {
                                      setState(() {
                                        _safeHabitsModel =
                                            _safeHabitsModel.copyWith(
                                              activity: updatedActivity,
                                            );
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          spacing:
                                          rh(context: context, px: 10),
                                          children: [
                                            Text(
                                              "Activity Level",
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF535359),
                                                fontSize: rh(
                                                  context: context,
                                                  px: 15,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                height: 1.0,
                                                letterSpacing: -0.30,
                                              ),
                                            ),
                                            Text(
                                              _formatHabitValue(
                                                _safeHabitsModel.activity,
                                              ),
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF535359),
                                                fontSize: rh(
                                                  context: context,
                                                  px: 12,
                                                ),
                                                height: 1.0,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        _safeHabitsModel.activity ==
                                            "not_available"
                                            ? Icons.add
                                            : Icons
                                            .keyboard_arrow_down_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    final updatedGoal =
                                    await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GoalUpdateScreen(
                                          initialGoal: _safeHabitsModel.goal,
                                          clientProfileModel:
                                          widget.clientProfileModel,
                                          userHabitsModel: _safeHabitsModel,
                                        ),
                                      ),
                                    );

                                    if (updatedGoal != null) {
                                      setState(() {
                                        _safeHabitsModel =
                                            _safeHabitsModel.copyWith(
                                              goal: updatedGoal,
                                            );
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Goal",
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF535359),
                                                fontSize: rh(
                                                  context: context,
                                                  px: 15,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.30,
                                              ),
                                            ),
                                            SizedBox(
                                              height: rh(
                                                context: context,
                                                px: 5,
                                              ),
                                            ),
                                            Text(
                                              _formatHabitValue(
                                                _safeHabitsModel.goal,
                                              ),
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF535359),
                                                fontSize: rh(
                                                  context: context,
                                                  px: 12,
                                                ),
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.24,
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        _safeHabitsModel.goal ==
                                            "not_available"
                                            ? Icons.add
                                            : Icons
                                            .keyboard_arrow_down_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    final updatedFoodType =
                                    await Navigator.push<FoodTypeModel>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            FoodPreferenceUpdateScreen(
                                              clientProfileModel:
                                              widget.clientProfileModel,
                                              userHabitsModel: _safeHabitsModel,
                                            ),
                                      ),
                                    );

                                    if (updatedFoodType != null) {
                                      setState(() {
                                        _safeHabitsModel =
                                            _safeHabitsModel.copyWith(
                                              foodType: updatedFoodType,
                                            );
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          spacing:
                                          rh(context: context, px: 10),
                                          children: [
                                            Text(
                                              "Food Preferences",
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF535359),
                                                fontSize: rh(
                                                  context: context,
                                                  px: 15,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                height: 1.0,
                                                letterSpacing: -0.30,
                                              ),
                                            ),
                                            Text(
                                              _safeHabitsModel
                                                  .foodType.dietType ==
                                                  "not_available"
                                                  ? "-"
                                                  : "${_formatHabitValue(_safeHabitsModel.foodType.dietType)}, ${_formatHabitValue(_safeHabitsModel.foodType.primaryCuisine)}, ${_formatHabitValue(_safeHabitsModel.foodType.secondaryCuisine)}",
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF535359),
                                                fontSize: rh(
                                                  context: context,
                                                  px: 12,
                                                ),
                                                height: 1.2,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        _safeHabitsModel.foodType.dietType ==
                                            "not_available"
                                            ? Icons.add
                                            : Icons
                                            .keyboard_arrow_down_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 50)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 10),
                            ),
                            child: _CardContainer(
                              child: Row(
                                children: [
                                  _DeleteAccountButton(
                                    onPressed: () => _showDeleteConfirmDialog(
                                      context,
                                      client,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Respyr Metabolism 1.0",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA0A8B2),
                          fontSize: rh(context: context, px: 12),
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 15)),
                    ],
                  ),
                ),
              ),
              if (_isDeletingAccount)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              if (_showDeleteSuccessOverlay) _buildSuccessOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context,
      ClientProfileModel client,
      ) {
    showDialog<void>(
      context: context,
      barrierDismissible: !_isDeletingAccount,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 20)),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(rh(context: context, px: 18)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delete account?",
                  style: GoogleFonts.poppins(
                    fontSize: rh(context: context, px: 16.5),
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: rh(context: context, px: 8)),
                Text(
                  "This action permanently deletes the account and data. This cannot be undone.",
                  style: GoogleFonts.poppins(
                    fontSize: rh(context: context, px: 12.5),
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: rh(context: context, px: 18)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 14),
                            ),
                          ),
                          side: BorderSide(
                            color: const Color(0xFFE5E7EB),
                            width: rh(context: context, px: 1),
                          ),
                          foregroundColor: const Color(0xFF374151),
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context: context, px: 12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: rh(context: context, px: 13.5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: rh(context: context, px: 10)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _deleteAccount(client);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dangerPure,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 14),
                            ),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context: context, px: 12),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: rh(context: context, px: 13.5),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount(ClientProfileModel client) async {
    if (_isDeletingAccount) return;

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final result = await _deleteAccountService.deleteAccount(
        profileId: client.profileId,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _isDeletingAccount = false;
          _showDeleteSuccessOverlay = true;
        });
      } else {
        setState(() {
          _isDeletingAccount = false;
        });

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                result.message.isNotEmpty
                    ? result.message
                    : "Failed to delete account.",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: _danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } on DeleteAccountException catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeletingAccount = false;
      });

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.message,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: _danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeletingAccount = false;
      });

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "Something went wrong while deleting the account.",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: _danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _performFinalCleanup() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}

    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}

    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {}

    try {
      await WebViewCookieManager().clearCookies();
    } catch (_) {}

    try {
      await ClientLoginManager().clearClientProfile();
    } catch (_) {}
  }

  Future<void> _onDoneDeleteSuccess() async {
    if (_navigationTriggered) return;

    if (mounted) {
      setState(() {
        _showDeleteSuccessOverlay = false;
      });
    }

    await _performFinalCleanup();

    if (!mounted) return;

    _goToSignInDirectly();
  }

  void _goToSignInDirectly() {
    if (_navigationTriggered) return;
    _navigationTriggered = true;

    if (!mounted) return;
    context.go(AppRoutes.signInOptions);
  }

  Widget _buildSuccessOverlay(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 24),
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.45,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rh(context: context, px: 28)),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: rh(context: context, px: 16)),
                    Container(
                      width: rh(context: context, px: 44),
                      height: rh(context: context, px: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 32)),
                    Container(
                      height: rh(context: context, px: 70),
                      width: rh(context: context, px: 70),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FAF58),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: rh(context: context, px: 36),
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 40)),
                    Text(
                      "Account Deleted",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 30),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.2,
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 16)),
                    Text(
                      "Your Respyr account has been successfully deleted.\nWe’re sorry to see you go.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 40)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            width: rh(context: context, px: 1),
                            color: const Color(0xFFA1A1A1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 50),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: rh(context: context, px: 30),
                            vertical: rh(context: context, px: 20),
                          ),
                        ),
                        onPressed: _onDoneDeleteSuccess,
                        child: Text(
                          "Done",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 15),
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: 0.30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: rh(context: context, px: 40)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateBottomSheet(BuildContext context, QuaDashboardReady state) {
    final bloc = context.read<QuaDashboardBloc>();
    final initialText = state.client.weight.trim();
    final controller = TextEditingController(text: initialText);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

            return GestureDetector(
              onTap: () => FocusScope.of(sheetContext).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(rh(context: context, px: 20)),
                      topRight: Radius.circular(rh(context: context, px: 20)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(rh(context: context, px: 20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: rh(context: context, px: 44),
                            height: rh(context: context, px: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 999),
                              ),
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 14)),
                          Text(
                            "Update weight",
                            style: GoogleFonts.poppins(
                              fontSize: rh(context: context, px: 18),
                              fontWeight: FontWeight.w500,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 20)),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    autofocus: false,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    style: GoogleFonts.poppins(
                                      fontSize: rh(context: context, px: 18),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}$'),
                                      ),
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                        rh(context: context, px: 16),
                                        vertical:
                                        rh(context: context, px: 12),
                                      ),
                                      hintText: "0.0",
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize:
                                        rh(context: context, px: 18),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    onChanged: (_) {
                                      if (errorText != null) {
                                        setState(() => errorText = null);
                                      }
                                    },
                                    onSubmitted: (_) =>
                                        FocusScope.of(sheetContext).unfocus(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: rh(context: context, px: 16),
                                  ),
                                  child: Text(
                                    "Kg",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (errorText != null) ...[
                            SizedBox(height: rh(context: context, px: 8)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                errorText!,
                                style: GoogleFonts.poppins(
                                  color: _danger,
                                  fontSize: rh(context: context, px: 12),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: rh(context: context, px: 18)),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                    ),
                                    side: BorderSide(
                                      color: const Color(0xFFE5E7EB),
                                      width: rh(context: context, px: 1),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: rh(context: context, px: 12),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: rh(context: context, px: 10)),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF308BF9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: rh(context: context, px: 12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    final input = controller.text.trim();
                                    final weight = double.tryParse(input);

                                    const double minWeight = 20.0;
                                    const double maxWeight = 250.0;

                                    if (weight == null) {
                                      setState(
                                            () => errorText =
                                        "Enter a valid number",
                                      );
                                      return;
                                    }

                                    if (weight < minWeight) {
                                      setState(
                                            () => errorText =
                                        "Weight must be at least ${minWeight.toStringAsFixed(0)} kg",
                                      );
                                      return;
                                    }

                                    if (weight > maxWeight) {
                                      setState(
                                            () => errorText =
                                        "Weight must be below ${maxWeight.toStringAsFixed(0)} kg",
                                      );
                                      return;
                                    }

                                    bloc.add(
                                      QuaUpdateWeight(
                                        profileId: state.client.profileId,
                                        weightKg: weight,
                                        email: state.client.email,
                                      ),
                                    );

                                    Navigator.pop(sheetContext);
                                  },
                                  child: Text(
                                    "Update",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: rh(context: context, px: 8)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteAccountButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFA1A1A1),
          ),
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: rh(context: context, px: 20),
        children: [
          Text(
            "Delete Account",
            style: GoogleFonts.poppins(
              color: const Color(0xFFDA5747),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          const Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 15),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: rh(context: context, px: 30),
        horizontal: rh(context: context, px: 20),
      ),
      child: child,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.30,
          ),
        ),
        SizedBox(height: rh(context: context, px: 10)),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}