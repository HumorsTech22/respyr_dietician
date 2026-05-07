import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/features_allow/data/model/features_allow_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';

import '../../../../core/size/get_height.dart';
import '../../../../routes/app_routes.dart';
import '../../../bluetooth_device_connectivity/presentation/widgets/metabolism_scale.dart';

class OverallScoreNew extends StatefulWidget {
  final RespyrUnifiedResponse respyrUnifiedResponse;
  final ClientProfileModel clientProfileModel;
  final FeaturesAllowData featuresAllowData;

  const OverallScoreNew({
    super.key,
    required this.respyrUnifiedResponse,
    required this.clientProfileModel,
    required this.featuresAllowData,
  });

  @override
  State<OverallScoreNew> createState() => _OverallScoreNewState();
}

class _OverallScoreNewState extends State<OverallScoreNew> {
  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '';

    try {
      final ist = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTime, true);
      final utc = ist.subtract(const Duration(hours: 5, minutes: 30));
      final local = utc.toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(local);
    } catch (_) {
      return dateTime;
    }
  }

  Future<bool> navToDashboard(BuildContext context) async {
    if (context.mounted) {
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    final double horizontalPadding = isSmallScreen
        ? rh(context: context, px: 16.0)
        : rh(context: context, px: 20.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await navToDashboard(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF0F6FD),
          surfaceTintColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                navToDashboard(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0F6FD),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.7552],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: rh(context: context, px: 110),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: rh(context: context, px: 20)),
                        RepaintBoundary(
                          child: _buildHeaderSection(isSmallScreen),
                        ),
                        RepaintBoundary(
                          child: _buildMainContentSection(screenSize),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: rh(context: context, px: 12),
                  left: 0,
                  right: 0,
                  child: Visibility(
                    visible: widget.featuresAllowData.detailedScores,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          context.push(
                            AppRoutes.overallResultScreen,
                            extra: ResultScreenParamsNew(
                              respyrUnifiedResponse:
                              widget.respyrUnifiedResponse,
                              clientProfileModel: widget.clientProfileModel,
                              featuresAllowData: widget.featuresAllowData,
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF308BF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 50),
                            ),
                          ),
                          padding: EdgeInsets.all(
                            rh(context: context, px: 16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
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

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/images/icons/ic_test_check.svg"),
                SizedBox(width: rh(context: context, px: 5)),
                Text(
                  "Completed",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3EAF58),
                    fontSize: isSmallScreen
                        ? rh(context: context, px: 10)
                        : rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
            SizedBox(height: rh(context: context, px: 11)),
            Flexible(
              child: Text(
                formatDateTime(widget.respyrUnifiedResponse.dateTime),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: isSmallScreen
                      ? rh(context: context, px: 10)
                      : rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                  letterSpacing: -0.24,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: rh(context: context, px: 11)),
        Text(
          widget.respyrUnifiedResponse.primaryTrend.screenTitle,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: isSmallScreen
                ? rh(context: context, px: 28)
                : rh(context: context, px: 32),
            fontWeight: FontWeight.w400,
            letterSpacing: -2.04,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentSection(Size screenSize) {
    final bool isSmallScreen = screenSize.width < 360;

    final double scoreFontSize = isSmallScreen
        ? rh(context: context, px: 80.0)
        : rh(context: context, px: 100.0);

    final dailyFocusTitle = widget.respyrUnifiedResponse.dayFocus.title;
    final dailyFocusNote = widget.respyrUnifiedResponse.dayFocus.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildScoreDisplay(scoreFontSize),
        _buildZoneText(),
        SizedBox(height: rh(context: context, px: 48)),
        RepaintBoundary(
          child: MetabolismScale(
            value: widget.respyrUnifiedResponse.primaryTrend.score,
          ),
        ),
        SizedBox(height: rh(context: context, px: 37)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 0),
          ),
          child: Column(
            children: [
              Text(
                widget.respyrUnifiedResponse.primaryTrend.clientInterpretation.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 20),
                  fontWeight: FontWeight.w600,
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
              SizedBox(height: rh(context: context, px: 15)),
              Text(
                widget.respyrUnifiedResponse.primaryTrend.clientInterpretation.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: rh(context: context, px: 1.30),
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rh(context: context, px: 24)),
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F7FA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                rh(context: context, px: 10),
              ),
            ),
          ),
          padding: EdgeInsets.all(rh(context: context, px: 15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/images/icons/ic_icons.svg"),
              SizedBox(height: rh(context: context, px: 15)),
              Text(
                dailyFocusTitle,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 18),
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -0.72,
                ),
              ),
              SizedBox(height: rh(context: context, px: 20)),
              Text(
                dailyFocusNote,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: rh(context: context, px: 1.30),
                  letterSpacing: rh(context: context, px: -0.30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.respyrUnifiedResponse.primaryTrend.score.toStringAsFixed(0),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            letterSpacing: -2,
            height: 1.0,
          ),
        ),
        SizedBox(width: rh(context: context, px: 2)),
        Text(
          "%",
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: fontSize * 0.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.40,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Color getZoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case "focus":
        return const Color(0xFFE48326);
      case "moderate":
        return const Color(0xFFFFBF2D);
      case "optimal":
        return const Color(0xFF3FAF58);
      default:
        return Colors.grey;
    }
  }

  Widget _buildZoneText() {
    final String zone = widget.respyrUnifiedResponse.primaryTrend.zone;
    final String isNeeds = zone.toLowerCase() == "focus" ? "Needs to" : "is";

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "You're Trend $isNeeds ",
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: rh(context: context, px: 18),
          fontWeight: FontWeight.w600,
          letterSpacing: -0.72,
        ),
        children: [
          TextSpan(
            text: zone,
            style: GoogleFonts.poppins(
              color: getZoneColor(zone),
              fontSize: rh(context: context, px: 18),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.72,
            ),
          ),
        ],
      ),
    );
  }
}