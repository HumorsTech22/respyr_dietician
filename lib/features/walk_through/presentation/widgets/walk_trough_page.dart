import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class WalkTroughPage extends StatelessWidget {
final String image;
final String title;
final String desc;
  const WalkTroughPage({super.key, required this.image, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [

        Spacer(),
        Image.asset(image,cacheHeight: 323, cacheWidth: 275,),
        SizedBox(height: 38,),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF308BF9),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  height: 1.06,
                  letterSpacing: -1.36,
                ),
              ),
            ),
            SizedBox(height: 12,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Text(desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.30,
                ),),
            )
          ],
        ),

      ],
    );
  }
}
