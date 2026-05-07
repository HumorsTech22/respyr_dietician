import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class ProfileCard extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.clientProfileModel,
    required this.onTap,
  });

  String _capitalizeWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
    word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final r = rh(context: context, px: 15);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(r),
      child: InkWell(
        borderRadius: BorderRadius.circular(r),
        onTap: onTap,
        child: Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF0F5FC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  "assets/images/icons/def1.svg",
                ),
              ),
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(r),
                      bottomRight: Radius.circular(r),
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: rh(context: context, px: 14),
                  vertical: rh(context: context, px: 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalizeWords(clientProfileModel.profileName),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: rh(context: context, px: 10),
                        fontWeight: FontWeight.w400,
                        letterSpacing: rh(context: context, px: -0.20),
                      ),
                    ),
                    Text(
                      "${clientProfileModel.age} years, ${clientProfileModel.gender}",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: rh(context: context, px: 10),
                        fontWeight: FontWeight.w400,
                        letterSpacing: rh(context: context, px: -0.20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}