import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

import '../../../../core/size/get_height.dart';
import 'metabolism_tab_card_new.dart';

class SectionWidgetNew extends StatelessWidget {
  final String metabolismType;
  final DietitianResultState state;
  final ClientProfileModel clientProfileModel;
  final RespyrUnifiedResponse respyrUnifiedResponse;
  final BuildContext context;

  const SectionWidgetNew({
    super.key,
    required this.metabolismType,
    required this.state,
    required this.clientProfileModel,
    required this.respyrUnifiedResponse,
    required this.context,
  });

  static final Map<String, String> _metabolismTitle = {
    "Gut": "Digestive Balance Trends",
    "Fat": "Fuel & Energy Trends",
    "Liver": "Metabolic Recovery Trends",
  };

  static final Map<String, List<String>> _metabolismSubTypes = {
    "Gut": ["Nutrient Utilization Trend", "Digestive Activity"],
    "Fat": ["Fuel Utilization Trend", "Energy Source Trend"],
    "Liver": ["Recovery Activity Trend", "Metabolic Load Trend"],
  };

  static const Set<String> _range1Types = {
    "nutrient utilization trend",
    "fuel utilization trend",
    "recovery activity trend",
  };

  bool _isRange1(String subtype) {
    final n = subtype.toLowerCase().trim();
    return _range1Types.contains(n);
  }

  bool get _isMuscleGainPrimaryTrend {
    final trendKey =
    respyrUnifiedResponse.primaryTrend.trendKey.toLowerCase().trim();

    final screenTitle =
    respyrUnifiedResponse.primaryTrend.screenTitle.toLowerCase().trim();

    final mode = respyrUnifiedResponse.energy.mode.toLowerCase().trim();

    return trendKey == "muscle-gain trend" ||
        screenTitle.contains("muscle-gain") ||
        mode == "muscle_gain";
  }

  bool _getFinalRange(String subtype) {
    final normalRange = _isRange1(subtype);

    final isLiver = metabolismType.toLowerCase().trim() == "liver";
    final isGut = metabolismType.toLowerCase().trim() == "gut";

    if (_isMuscleGainPrimaryTrend && !isLiver && !isGut) {
      return !normalRange;
    }

    return normalRange;
  }

  @override
  Widget build(BuildContext context) {
    final subTypes = _metabolismSubTypes[metabolismType] ?? [];
    if (subTypes.length < 2) return const SizedBox();

    final metabolism = respyrUnifiedResponse.metabolismScoreAnalysis;

    final metab1 = switch (metabolismType) {
      "Gut" => metabolism.nutrientUtilizationTrend,
      "Fat" => metabolism.fuelUtilizationTrend,
      "Liver" => metabolism.recoveryActivityTrend,
      _ => metabolism.nutrientUtilizationTrend,
    };

    final metab2 = switch (metabolismType) {
      "Gut" => metabolism.digestiveActivityTrend,
      "Fat" => metabolism.energySourceTrend,
      "Liver" => metabolism.metabolicLoadTrend,
      _ => metabolism.digestiveActivityTrend,
    };

    final metab1Subtype = subTypes[0];
    final metab2Subtype = subTypes[1];

    final metab1IsRange1 = _getFinalRange(metab1Subtype);
    final metab2IsRange1 = _getFinalRange(metab2Subtype);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: rh(context: context, px: 10)),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDEE2E6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetabolismTabCardNew(
                metabolismSubtype: metab1Subtype,
                score: metab1.score,
                interpretation: metab1.interpretation,
                clientState: metab1.clientState,
                clientProfileModel: clientProfileModel,
                scoreZone: metab1.zone,
                whyIsThisScore: '',
                isRange1: metab1IsRange1,
                resultDateAndTime: respyrUnifiedResponse.dateTime,
              ),
              const SizedBox(height: 15),
              MetabolismTabCardNew(
                metabolismSubtype: metab2Subtype,
                score: metab2.score,
                interpretation: metab2.interpretation,
                clientState: metab2.clientState,
                clientProfileModel: clientProfileModel,
                scoreZone: metab2.zone,
                whyIsThisScore: '',
                isRange1: metab2IsRange1,
                resultDateAndTime: respyrUnifiedResponse.dateTime,
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            color: Colors.white,
            child: Text(
              _metabolismTitle[metabolismType] ?? '',
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}