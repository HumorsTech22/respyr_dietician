import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class CuisineSheet {

  static Future<String?> show({required BuildContext context, required List<String> cuisines}) {

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      builder: (context) {
        return SafeArea(
          child: Column(
            spacing: rh(context: context, px: 16),
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context, cuisines[0]);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rh(context: context, px: 5)),
                  ),
                ),
                icon: Icon(Icons.close, size: rh(context: context, px: 20)),
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: rh(context: context, px: 30),
                  horizontal: rh(context: context, px: 20),
                ),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "Select Primary Cuisine",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.30,
                      ),
                    ),

                    SizedBox(height: rh(context: context, px: 30)),

                    Wrap(
                      spacing: rh(context: context, px: 10),
                      runSpacing: rh(context: context, px: 10),
                      children: cuisines.map((cuisine) {

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context, cuisine);
                          },

                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 10),
                              vertical: rh(context: context, px: 10),
                            ),

                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: rh(context: context, px: 1),
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: const Color(0xFF308BF9),
                                ),
                                borderRadius: BorderRadius.circular(
                                  rh(context: context, px: 8),
                                ),
                              ),
                            ),

                            child: Text(
                              cuisine,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF308BF9),
                                fontSize: rh(context: context, px: 12),
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: -0.24,
                              ),
                            ),
                          ),
                        );

                      }).toList(),
                    ),

                    SizedBox(height: rh(context: context, px: 50)),

                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}