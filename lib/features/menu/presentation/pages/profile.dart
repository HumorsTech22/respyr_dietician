import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class Profile extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const Profile({super.key, required this.clientProfileModel});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F7FA),
        surfaceTintColor: Color(0xFFF5F7FA),
        title: Text("General",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Text("Profile Settings",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 26,
                        children: [


                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Phone",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Text(widget.clientProfileModel.phoneNo,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                  height: 1.2,
                                ),
                              )
                            ],
                          ),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gender",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Text(widget.clientProfileModel.gender,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                  height: 1.2,
                                ),
                              )
                            ],
                          ),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Height",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Text("${widget.clientProfileModel.height} cm",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                  height: 1.2,
                                ),
                              )
                            ],
                          ),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Weight",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Text("${widget.clientProfileModel.weight} kgs",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                  height: 1.2,
                                ),
                              )
                            ],
                          ),



                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 54,),
                Center(
                  child: Text("Respyr Dietician 1.0",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFA0A8B2),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          )
      ),
    );
  }
}
