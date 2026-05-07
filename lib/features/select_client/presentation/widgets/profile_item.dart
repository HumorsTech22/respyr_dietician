import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class ProfileItem extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final VoidCallback? onItemClick;

  const ProfileItem({
    super.key,
    required this.clientProfileModel,
    required this.onItemClick,
  });

  String capitalizeWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '',
    )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onItemClick,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: rh(context: context, px: 15),
        children: [
          SvgPicture.asset(
            "assets/images/icons/default1.svg",
            width: rh(context: context, px: 40),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: rh(context: context, px: 7),
              children: [
                Text(
                  capitalizeWords(clientProfileModel.profileName),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w600,
                    letterSpacing: rh(context: context, px: -0.24),
                    height: rh(context: context, px: 1),
                  ),
                ),
                Text(
                  clientProfileModel.email,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA1A1A1),
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.24),
                    height: rh(context: context, px: 1),
                  ),
                ),
                Text(
                  "${clientProfileModel.age} years, ${clientProfileModel.gender}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: rh(context: context, px: 10),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.20),
                    height: rh(context: context, px: 1),
                  ),
                ),
                Text(
                  "Weight Loss",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 10),
                    fontWeight: FontWeight.w400,
                    letterSpacing: rh(context: context, px: -0.20),
                    height: rh(context: context, px: 1),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}