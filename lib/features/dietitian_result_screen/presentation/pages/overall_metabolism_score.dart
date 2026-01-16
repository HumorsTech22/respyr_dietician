import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';

class OverallMetabolismScore extends StatefulWidget {
  final GeneratingResultModel result;
  final ClientProfileModel clientProfileModel;

  const OverallMetabolismScore({
    super.key,
    required this.result,
    required this.clientProfileModel,
  });

  @override
  State<OverallMetabolismScore> createState() => _OverallMetabolismScoreState();
}

class _OverallMetabolismScoreState extends State<OverallMetabolismScore> {
  String _formatDttm(String? dttm) {
    if (dttm == null || dttm.isEmpty) return '';
    try {
      final date = DateTime.parse(dttm).toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(date);
    } catch (_) {
      return dttm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final double horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await navToDashboard(context);

          if (shouldExit) {}
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header Section with Title
                _buildHeaderSection(isSmallScreen),
      
                // Main Content Section
                Expanded(
                  child: _buildMainContentSection(screenSize),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }


  Future<bool> navToDashboard(BuildContext context) async {
    bool didCancel = false;

    if (context.mounted) {
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
    }

    return didCancel;
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status and Date Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Completed Status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/images/icons/ic_test_check.svg"),
                const SizedBox(width: 5),
                Text(
                  "Completed",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3EAF58),
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),

            // Date Time
            Flexible(
              child: Text(
                _formatDttm(widget.result.dateTime.toString()),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                  letterSpacing: -0.24,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 11),

        // Title
        Text(
          "Metabolism Score",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: isSmallScreen ? 28 : 34,
            fontWeight: FontWeight.w400,
            letterSpacing: -2.04,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentSection(Size screenSize) {
    final bool isSmallScreen = screenSize.width < 360;
    final double scoreFontSize = isSmallScreen ? 80.0 : 100.0;
    final double zoneFontSize = isSmallScreen ? 20.0 : 25.0;
    final double interpretationFontSize = isSmallScreen ? 11.0 : 12.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Score Display
        _buildScoreDisplay(scoreFontSize),

        const SizedBox(height: 50),

        // Metabolism Scale
        MetabolismScale(value: widget.result.respyrResponse.fatLossMetabolismScore.score),

        const SizedBox(height: 37),

        // Zone Text
        _buildZoneText(zoneFontSize),

        const SizedBox(height: 40),

        // Interpretation Text
        _buildInterpretationText(interpretationFontSize),
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
          widget.result.respyrResponse.fatLossMetabolismScore.score
              .toStringAsFixed(0),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(width: 2),
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
          ),
        ),
      ],
    );
  }

  Color getZoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case "poor":
        return const Color(0xFFDA5747); // red
      case "fair":
        return const Color(0xFFF8B10F); // yellow
      case "good":
        return const Color(0xFF3FAF58); // green
      default:
        return Colors.grey;
    }
  }


  Widget _buildZoneText(double fontSize) {
    return RichText(
      text: TextSpan(
        text: "You're Score is ",
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(
            text: widget.result.respyrResponse.fatLossMetabolismScore.zone,
            style: GoogleFonts.poppins(
              color: getZoneColor(widget.result.respyrResponse.fatLossMetabolismScore.zone),
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationText(double fontSize) {
    return Text(
      widget.result.respyrResponse.fatLossMetabolismScore.clientInterpretation,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: const Color(0xFF535359),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.30,
        letterSpacing: -0.24,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
              },

              style:ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                elevation: 0
              ) ,
              child:  Text("Done",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.10,
                  letterSpacing: 0.30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetabolismScale extends StatelessWidget {
  /// Value between 0–100
  final double value;

  const MetabolismScale({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    const double barHeight = 54;
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        _buildTitle(),

        // Scale Bar
        _buildScaleBar(barHeight, scaleFactor),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8),
      child: Text(
        'Metabolism Scale',
        style: GoogleFonts.poppins(
          color: const Color(0xFF535359),
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.10,
          letterSpacing: -0.20,
        ),
      ),
    );
  }

  Widget _buildScaleBar(double barHeight, double scaleFactor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double clampedValue = value.clamp(0, 100);
        final double indicatorX = constraints.maxWidth * (clampedValue / 100);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bar with indicator
            _buildBarWithIndicator(barHeight, indicatorX),

            const SizedBox(height: 6),

            // Labels
            _buildScaleLabels(),
          ],
        );
      },
    );
  }

  Widget _buildBarWithIndicator(double barHeight, double indicatorX) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Colored Bar Segments
        Row(
          children: [
            _buildBarSegment(
              flex: 60,
              color: const Color(0xFFDA5747),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              height: barHeight,
            ),
            _buildBarSegment(
              flex: 20,
              color: const Color(0xFFF8B10F),
              borderRadius: BorderRadius.zero,
              height: barHeight,
            ),
            _buildBarSegment(
              flex: 20,
              color: const Color(0xFF3EAF58),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              height: barHeight,
            ),
          ],
        ),

        // Indicator
        _buildIndicator(indicatorX, barHeight),
      ],
    );
  }

  Widget _buildBarSegment({
    required int flex,
    required Color color,
    required BorderRadius borderRadius,
    required double height,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildIndicator(double indicatorX, double barHeight) {
    return Positioned(
      left: indicatorX - 1.5,
      top: 20,
      bottom: 0,
      child: Container(
        width: 5,
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildScaleLabels() {
    return SizedBox(
      height: 14,
      width: double.infinity,
      child: Stack(
        children: [
          _buildScaleLabel(0.0, '0'),
          _buildScaleLabel(0.60, '60'),
          _buildScaleLabel(0.80, '80'),
          _buildScaleLabel(1.0, '100'),
        ],
      ),
    );
  }


  Widget _buildScaleLabel(double fraction, String text) {
    double alignX(double fraction) => (2 * fraction) - 1;

    return Align(
      alignment: Alignment(alignX(fraction), 0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF535359),
          fontSize: 8,
          fontWeight: FontWeight.w400,
          height: 1.10,
          letterSpacing: -0.16,
        ),
      ),
    );
  }
}