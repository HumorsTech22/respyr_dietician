import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/account_subscription/data/model/user_plan_model.dart';
import 'package:respyr_dietitian/features/account_subscription/presentation/screens/activation_code_screen.dart';
import 'package:respyr_dietitian/features/account_subscription/services/fetch_user_plans_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const SubscriptionScreen({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  String _errorMessage = "";
  List<UserPlanModel> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final result = await FetchUserPlansService.fetchUserPlans(
        profileId: widget.clientProfileModel.profileId,
      );

      if (!mounted) return;

      setState(() {
        _plans = result.data;
        _isLoading = false;
        if (!result.status && result.data.isEmpty) {
          _errorMessage = result.message;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to fetch plans";
      });
    }
  }

  String _toTitleCase(String value) {
    if (value.trim().isEmpty) return "";
    return value
        .split(' ')
        .map((word) => word.isEmpty
        ? word
        : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) return null;

    try {
      return DateTime.parse(value);
    } catch (_) {}

    try {
      return DateFormat("yyyy-MM-dd").parse(value);
    } catch (_) {}

    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(value);
    } catch (_) {}

    try {
      return DateFormat("dd-MM-yyyy").parse(value);
    } catch (_) {}

    return null;
  }

  String _formatDate(String value) {
    final parsed = _parseDate(value);
    if (parsed == null) return value.isEmpty ? "-" : value;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  UserPlanModel? get _latestPlan {
    if (_plans.isEmpty) return null;
    return _plans.first;
  }

  bool _isFreeTrialPlan(UserPlanModel? plan) {
    if (plan == null) return false;

    final planNameRaw = plan.planName.toLowerCase().trim();
    final planCodeRaw = plan.planCode.toLowerCase().trim();

    return planNameRaw.contains("free trial") ||
        planNameRaw.contains("trial") ||
        planCodeRaw.contains("free_trial") ||
        planCodeRaw.contains("trial");
  }

  bool get _hasActivePlan {
    return _plans.any((e) => e.status.toLowerCase().trim() == "active");
  }

  String _formatCurrentPlanBottomText(UserPlanModel? plan, bool isFreeTrial) {
    if (plan == null) return "-";

    if (isFreeTrial) {
      return "Trial ends on ${_formatDate(plan.subscriptionEndDate)}";
    }

    return "Renewal on ${_formatDate(plan.subscriptionEndDate)}";
  }

  @override
  Widget build(BuildContext context) {
    final latestPlan = _latestPlan;
    final latestStatus = latestPlan?.status.toLowerCase().trim() ?? "";
    final isActiveLatestPlan = latestStatus == "active";
    final isExpiredLatestPlan = latestStatus == "expired";
    final isFreeTrial = _isFreeTrialPlan(latestPlan);
    final showEnterCodeCard = !_hasActivePlan || isExpiredLatestPlan;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        elevation: 0,
        titleSpacing: rh(context: context, px: 17),
        title: Text(
          "General",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subscription",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 34),
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
              SizedBox(height: rh(context: context, px: 14)),

              if (_errorMessage.isNotEmpty && _plans.isEmpty)
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No Plan Found",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 15),
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 10)),
                      Text(
                        _errorMessage,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: rh(context: context, px: 12),
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: -0.24,
                        ),
                      ),
                    ],
                  ),
                ),

              if (latestPlan != null) ...[
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Plan",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: rh(context: context, px: 12),
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 12)),
                      if (isFreeTrial)
                        Text(
                          "7-day free trial",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 15),
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: -0.30,
                          ),
                        )
                      else if (isExpiredLatestPlan)
                        Text(
                          "No Active Plan",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFA1A1A1),
                            fontSize: rh(context: context, px: 12),
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                            height: 1.0,
                          ),
                        )
                      else
                        Text(
                          latestPlan.planName.isEmpty
                              ? "No Plan Name"
                              : latestPlan.planName,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 15),
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: -0.30,
                          ),
                        ),
                      SizedBox(height: rh(context: context, px: 10)),
                      if (isFreeTrial)
                        Text(
                          _formatCurrentPlanBottomText(latestPlan, true),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: rh(context: context, px: 12),
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                          ),
                        )
                      else if (isActiveLatestPlan)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: rh(context: context, px: 8),
                          runSpacing: rh(context: context, px: 6),
                          children: [
                            Text(
                              _toTitleCase(latestPlan.status),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF3EAF58),
                                fontSize: rh(context: context, px: 12),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.24,
                              ),
                            ),
                            Container(
                              width: rh(context: context, px: 1),
                              height: rh(context: context, px: 12),
                              color: const Color(0xFF535359),
                            ),
                            Text(
                              _formatCurrentPlanBottomText(latestPlan, false),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF535359),
                                fontSize: rh(context: context, px: 12),
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.24,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          "Expired on ${_formatDate(latestPlan.subscriptionEndDate)}",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: rh(context: context, px: 12),
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: rh(context: context, px: 10)),
              ],

              if (showEnterCodeCard) ...[
                _buildCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Have an activation code?",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: rh(context: context, px: 15),
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: rh(context: context, px: 18)),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivationCodeScreen(
                                clientProfileModel:
                                widget.clientProfileModel,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: rh(context: context, px: 14),
                            vertical: rh(context: context, px: 14),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF308BF9),
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Enter code",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: rh(context: context, px: 12),
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                                size: rh(context: context, px: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rh(context: context, px: 10)),
              ],

              if (_plans.isNotEmpty)
                Expanded(
                  child: _buildCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Plan History",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 15),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.30,
                          ),
                        ),
                        SizedBox(height: rh(context: context, px: 16)),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _plans.length,
                            itemBuilder: (context, index) {
                              final item = _plans[index];
                              final isActive =
                                  item.status.toLowerCase().trim() ==
                                      "active";
                              final isTrial = _isFreeTrialPlan(item);

                              return Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTrial
                                        ? "7-day free trial"
                                        : (item.planName.isEmpty
                                        ? "No Plan Name"
                                        : item.planName),
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize:
                                      rh(context: context, px: 13),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                  SizedBox(
                                    height: rh(context: context, px: 6),
                                  ),
                                  Text(
                                    "Code: ${item.couponCode.isEmpty ? '-' : item.couponCode}",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize:
                                      rh(context: context, px: 11),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.22,
                                    ),
                                  ),
                                  SizedBox(
                                    height: rh(context: context, px: 4),
                                  ),
                                  Text(
                                    "${_toTitleCase(item.status)} • ${_formatDate(item.subscriptionStartDate)} - ${_formatDate(item.subscriptionEndDate)}",
                                    style: GoogleFonts.poppins(
                                      color: isActive
                                          ? const Color(0xFF3EAF58)
                                          : const Color(0xFF535359),
                                      fontSize:
                                      rh(context: context, px: 11),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.22,
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: rh(context: context, px: 12),
                                ),
                                child: const Divider(
                                  height: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (isActiveLatestPlan && !isFreeTrial) ...[
                SizedBox(height: rh(context: context, px: 16)),
                _buildCard(
                  context,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: rh(context: context, px: 14),
                        vertical: rh(context: context, px: 14),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color(0xFFA1A1A1),
                        ),
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 9),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Cancel Subscription",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFDA5747),
                              fontSize: rh(context: context, px: 12),
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: const Color(0xFFDA5747),
                            size: rh(context: context, px: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: rh(context: context, px: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
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
        vertical: rh(context: context, px: 20),
        horizontal: rh(context: context, px: 20),
      ),
      child: child,
    );
  }
}