import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/size/get_height.dart'; // Ensure this import is correct

class TermsPolicyWidgets {

  Widget termsPolicyFooter(BuildContext context) {
    final greyTextStyle = GoogleFonts.poppins(
      color: const Color(0xFFA1A1A1),
      fontSize: rh(context: context, px: 12),
      fontWeight: FontWeight.w500,
      letterSpacing: -0.72,
    );

    final linkTextStyle = greyTextStyle.copyWith(
        color: const Color(0xFF308BF9),
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFF308BF9)
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: rh(context: context, px: 3),       // horizontal gap scaled
        runSpacing: rh(context: context, px: 2),    // vertical gap scaled
        children: [
          Text(
            "By continuing, you agree to our ",
            style: greyTextStyle,
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(rh(context: context, px: 0), rh(context: context, px: 0)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Privacy policy",
              style: linkTextStyle,
            ),
          ),
          Text(
            " and ",
            style: greyTextStyle,
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(rh(context: context, px: 0), rh(context: context, px: 0)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Terms and Conditions",
              style: linkTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}