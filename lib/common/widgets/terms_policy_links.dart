import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPolicyWidgets{



  Widget termsPolicyFooter(){


    final greyTextStyle = GoogleFonts.poppins(
      color: const Color(0xFFA1A1A1),
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.72,
    );

    final linkTextStyle = greyTextStyle.copyWith(
        color: const Color(0xFF308BF9),
        decoration: TextDecoration.underline,
        decorationColor:  Color(0xFF308BF9)
    );


    return   Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 3,       // horizontal gap
        runSpacing: 2,    // vertical gap if it wraps
        children: [
          Text(
            "By continuing, you agree to our ",
            style: greyTextStyle,
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
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
              minimumSize: Size(0, 0),
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