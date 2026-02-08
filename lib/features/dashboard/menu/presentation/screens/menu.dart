import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart';

class DashboardMenuScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const DashboardMenuScreen({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        title: Text("Settings",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(height: 10,),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Text("Account",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 40,
                    children: [
                     Row(
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             spacing: 2,
                             children: [
                               Text("Name",
                                 style: GoogleFonts.poppins(
                                   color: const Color(0xFF252525),
                                   fontSize: 15,
                                   fontWeight: FontWeight.w400,
                                   height: 1.10,
                                   letterSpacing: -0.30,
                                 ),
                               ),
                               Text(clientProfileModel.profileName,
                                 style: GoogleFonts.poppins(
                                   color: const Color(0xFF535359),
                                   fontSize: 12,
                                   fontWeight: FontWeight.w400,
                                   letterSpacing: -0.24,
                                 ),
                               )
                             ],
                           ),
                         ),
                         IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.right_chevron))
                       ],
                     ),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       spacing: 2,
                       children: [
                         Text("Email",
                           style: GoogleFonts.poppins(
                             color: const Color(0xFF252525),
                             fontSize: 15,
                             fontWeight: FontWeight.w400,
                             height: 1.10,
                             letterSpacing: -0.30,
                           ),
                         ),
                         Text(clientProfileModel.email,
                           style: GoogleFonts.poppins(
                             color: const Color(0xFF535359),
                             fontSize: 12,
                             fontWeight: FontWeight.w400,
                             letterSpacing: -0.24,
                           ),
                         )
                       ],
                     ),
                    ],
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
