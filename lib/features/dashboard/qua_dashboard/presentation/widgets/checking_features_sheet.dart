import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/features_allow/data/model/features_allow_model.dart';
import 'package:respyr_dietitian/common/features_allow/data/services/features_allow_service.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/practice_test/data/services/practice_service.dart';

class CheckingFeaturesSheet {
  static Future<void> show(
      BuildContext context, {
        required String dieticianId,
        String? profileId,
        required void Function(
            FeaturesAllowResponse featuresResult,
            bool needsPractice,
            ) onComplete,
      }) async {
    final featureService = FeaturesAllowService();
    final practiceService = PracticeService();

    // Capture the sheet's own navigator so we can pop it reliably,
    // independent of the caller's context.mounted state.
    NavigatorState? sheetNavigator;
    bool sheetClosed = false;

    // Fire-and-forget: we manage dismissal manually in `finally`.
    // ignore: unawaited_futures
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        sheetNavigator = Navigator.of(sheetCtx);
        return const _LoadingSheet();
      },
    ).then((_) {
      sheetClosed = true;
    });

    // Tiny delay so the sheet has a frame to render before heavy work.
    await Future.delayed(const Duration(milliseconds: 100));

    FeaturesAllowResponse featuresResult;
    bool needsPractice = false;

    try {
      if (profileId != null) {
        // Feature check + practice check in parallel
        final results = await Future.wait([
          featureService.fetchFeaturesAllow(dieticianId: dieticianId),
          practiceService.checkNeedsPractice(profileId),
        ]);

        featuresResult = results[0] as FeaturesAllowResponse;
        needsPractice = results[1] as bool;
      } else {
        featuresResult = await featureService.fetchFeaturesAllow(
          dieticianId: dieticianId,
        );
      }
    } catch (e) {
      // Safe fallback so the user isn't blocked by a transient API failure.
      featuresResult = FeaturesAllowResponse(
        success: false,
        failReason: e.toString(),
        data: FeaturesAllowData(
          testAllow: true,
          practiceTestAllow: true,
          detailedScores: true,
          id: 0,
          dieticianId: '',
          multipleReading: true,
        ),
      );
    } finally {
      // Guaranteed dismissal — runs whether the try succeeded or threw.
      // Uses the sheet's own NavigatorState, so it doesn't depend on the
      // caller's BuildContext still being mounted.
      if (!sheetClosed && (sheetNavigator?.canPop() ?? false)) {
        sheetNavigator!.pop();
        sheetClosed = true;
      }
    }

    // Hand control back to the caller AFTER the sheet is gone.
    onComplete(featuresResult, needsPractice);
  }
}

class _LoadingSheet extends StatelessWidget {
  const _LoadingSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: rh(context: context, px: 20),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: rh(context: context, px: 47)),
            const CircularProgressIndicator(
              color: Color(0xFF308BF9),
              backgroundColor: Color(0xFFF0F0F0),
            ),
            SizedBox(height: rh(context: context, px: 16)),
            Text(
              "Checking wait...",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                height: 1.30,
                letterSpacing: -0.30,
              ),
            ),
            SizedBox(height: rh(context: context, px: 65)),
          ],
        ),
      ),
    );
  }
}