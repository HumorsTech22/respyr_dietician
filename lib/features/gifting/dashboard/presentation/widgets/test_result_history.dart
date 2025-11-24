import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../../core/utils/date_helper.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';
import '../../../../bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import '../../../../dietitian_result_screen/presentation/pages/overall_metabolism_score.dart';
import '../../services/complete_test_history.dart';

class TestResultHistory extends StatefulWidget {
  final GeneratingResultModel? result; // from latest test
  final ClientProfileModel clientProfileModel;

  const TestResultHistory({
    super.key,
    required this.result,
    required this.clientProfileModel,
  });

  @override
  State<TestResultHistory> createState() => _TestResultHistoryState();
}

class _TestResultHistoryState extends State<TestResultHistory> {



  @override
  Widget build(BuildContext context) {
    final hasResult = widget.result != null;
    final r = widget.result;


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

    Widget _buildInterpretationText(double fontSize) {
      if (!hasResult) {
        return Text(
          "-",
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

      return Text(
        widget.result!.respyrResponse.fatLossMetabolismScore.clientInterpretation,
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

    Widget _buildZoneText(double fontSize) {
      if (!hasResult) {
        return Text(
          "-",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
        );
      }

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
              text: widget.result!.respyrResponse.fatLossMetabolismScore.zone,
              style: GoogleFonts.poppins(
                color: getZoneColor(widget.result!.respyrResponse.fatLossMetabolismScore.zone),
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      );
    }

    // Get the fat loss metabolism score safely
    double getFatLossMetabolismScore() {
      if (!hasResult) return 0.0;
      return widget.result!.respyrResponse.fatLossMetabolismScore.score;
    }

    // Get the date safely
    String getTestDate() {
      if (!hasResult) return "-";
      return DateHelper().formatToDateTimeString(widget.result!.dateTime);
    }

    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Metabolism Score",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 17),

          Visibility(
            visible: hasResult,
            replacement: Text(
              "Not yet tracked",
              style: GoogleFonts.poppins(
                color: const Color(0xFFA1A1A1),
                fontSize:  12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/images/icons/ic_test_check.svg"),
                const SizedBox(width: 5),
                Text(
                  "Completed",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3EAF58),
                    fontSize:  12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),

          Text(getTestDate()),

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 15,
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                )
              ],
            ),
            padding: EdgeInsets.only(top: 50, bottom: 93, left: 11, right: 11),
            child: Column(
              children: [
                Visibility(
                  visible: hasResult,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: 5,
                    children: [
                      Text(
                        getFatLossMetabolismScore().toStringAsFixed(0), // Safe call
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF252525),
                            fontSize: 100,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -2,
                            height: 1
                        ),
                      ),
                      Text("%",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.40,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Visibility(visible: hasResult, child: MetabolismScale(value: getFatLossMetabolismScore())), // Safe call
                const SizedBox(height: 37),
                _buildZoneText(25),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildInterpretationText(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}