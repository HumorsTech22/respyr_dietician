import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../profile_info/data/model/dietician_detail_model.dart';

class DietitianInfo extends StatelessWidget {
  final DietitianDetailModel? dietitianDetailModel;
  const DietitianInfo({super.key, this.dietitianDetailModel});

  @override
  Widget build(BuildContext context) {
    final String consultantName =
    (dietitianDetailModel?.dietitianId?.trim().isNotEmpty ?? false)
        ? dietitianDetailModel!.dietitianId!.trim()
        : "-";

    final String clinicName =
    (dietitianDetailModel?.clinicName?.trim().isNotEmpty ?? false)
        ? dietitianDetailModel!.clinicName!.trim()
        : "-";

    final String city =
    (dietitianDetailModel?.location?.trim().isNotEmpty ?? false)
        ? dietitianDetailModel!.location!.trim()
        : "";

    final String clinicLine = city.isNotEmpty
        ? "@ $clinicName, $city"
        : "@ $clinicName";

    final String? logoUrl = (dietitianDetailModel?.logoUrl?.trim().isNotEmpty ?? false)
        ? dietitianDetailModel!.logoUrl!.trim()
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 54),
        decoration: ShapeDecoration(
          gradient: const RadialGradient(
            center: Alignment(0.50, 0.50),
            radius: 0.50,
            colors: [Color(0xFFF5F7FA), Color(0xFFEDF5FF)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Text(
              "Your Consultant",
              style: GoogleFonts.poppins(
                color: const Color(0xFF308BF9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: -0.72,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 70,
              width: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: logoUrl != null
                    ? Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SvgPicture.asset(
                      "assets/images/icons/default1.svg",
                      fit: BoxFit.contain,
                    );
                  },
                )
                    : SvgPicture.asset(
                  "assets/images/icons/default1.svg",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 26),

            // ✅ Name
            Text(
              consultantName,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 25,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Dietitian",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  clinicLine,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
