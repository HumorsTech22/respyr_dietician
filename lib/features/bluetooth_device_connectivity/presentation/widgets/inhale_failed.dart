import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';

class InhaleFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const InhaleFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  bool _isExhaleCase(String t) {
    final s = t.toLowerCase();
    return s.contains("exhale");
  }

  bool _isDroppedCase(String t) {
    return t.trim() == "Inhale dropped to 0";
  }

  @override
  Widget build(BuildContext context) {

    final isExhale = _isExhaleCase(text);
    final isDropped = _isDroppedCase(text);




    if(isDropped){
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          children: [
            Spacer(),
            Center(child: Image.asset("assets/images/device_connection/img_inhale_exhale_dropped.png",)),
            SizedBox(height: rh(context: context, px: 48),),
            Center(
              child: Text("Keep the ball in the\nrange for longer",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                  height: rh(context: context, px: 1.29),
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              height: rh(context: context, px: 61),
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: (){
                    onStartAgain();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308BF9),
                      padding: EdgeInsetsGeometry.symmetric(vertical: rh(context: context, px: 16)),
                      elevation: 0
                  ),
                  child: Text("Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)
                    ),
                  )
              ),
            ),
            SizedBox(height: rh(context: context, px: 20),),
          ],
        ),
      );
    }
    if(isExhale){
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You breathed air out\nInstead of In",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(child: Image.asset("assets/images/device_connection/img_inhale_screen_exhale.png",),),
            SizedBox(
              width: double.infinity,
              height: rh(context: context, px: 61),
              child: ElevatedButton(
                  onPressed: (){
                    onStartAgain();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF308BF9),
                      padding: EdgeInsetsGeometry.symmetric(vertical: rh(context: context, px: 16)),
                      elevation: 0
                  ),
                  child: Text("Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)
                    ),
                  )
              ),
            ),
            SizedBox(height: rh(context: context, px: 20),),
          ],
        ),
      );
    }

    // return Padding(
    //   padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text("Something went wrong.",
    //         style: GoogleFonts.poppins(
    //           color: const Color(0xFF252525),
    //           fontSize: rh(context: context, px: 25),
    //           fontWeight: FontWeight.w600,
    //           height: rh(context: context, px: 1.29),
    //           letterSpacing: rh(context: context, px: -1),
    //         ),
    //       ),
    //       SizedBox(height: rh(context: context, px: 25),),
    //       Text("Don’t worry—let’s give it another try.",
    //         style: GoogleFonts.poppins(
    //           color: const Color(0xFF535359),
    //           fontSize: rh(context: context, px: 15),
    //           fontWeight: FontWeight.w400,
    //           height: rh(context: context, px: 1.30),
    //           letterSpacing: rh(context: context, px: -0.30),
    //         ),
    //       ),
    //       SizedBox(height: rh(context: context, px: 37)),
    //       Expanded(child: Container(),),
    //       SizedBox(
    //         width: double.infinity,
    //         height: rh(context: context, px: 61),
    //         child: ElevatedButton(
    //             onPressed: (){
    //               onStartAgain();
    //             },
    //             style: ElevatedButton.styleFrom(
    //                 backgroundColor: const Color(0xFF308BF9),
    //                 padding: EdgeInsetsGeometry.symmetric(vertical: rh(context: context, px: 16)),
    //                 elevation: 0
    //             ),
    //             child: Text("Start Again",
    //               style: GoogleFonts.poppins(
    //                   color: Colors.white,
    //                   fontSize: rh(context: context, px: 15),
    //                   fontWeight: FontWeight.w700,
    //                   height: rh(context: context, px: 1.0),
    //                   letterSpacing: rh(context: context, px: 0.30)
    //               ),
    //             )
    //         ),
    //       ),
    //       SizedBox(height: rh(context: context, px: 20),),
    //     ],
    //   ),
    // );

    return SizedBox.shrink();
  }
}