import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dashboard_menu/presentation/pages/profile.dart';

import '../../../../client-dashboard/extras/logout.dart';
import '../../../../common/screens/network_image_viewer.dart';
import '../../../profile_info/data/model/dietician_detail_model.dart';

class Settings extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianDetailModel;
  const Settings({super.key, required this.clientProfileModel, required this.dietitianDetailModel});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool value=false;
  bool isLoggingOut=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F7FA),
        surfaceTintColor: Color(0xFFF5F7FA),
        title: Text("Settings",
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
                  child: Text("Account",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                  Text(widget.clientProfileModel.profileName,
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

                              InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        backgroundColor: Colors.black,
                                        body: Center(
                                          child: Hero(
                                            tag: "client-image",
                                            child: InteractiveViewer(
                                              child: NetworkImageView(
                                                url: widget.clientProfileModel.profileImage.isNotEmpty
                                                    ? widget.clientProfileModel.profileImage
                                                    : "https://via.placeholder.com/300", // fallback
                                                width: double.infinity,
                                                height: double.infinity,
                                                borderRadius: 0,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(
                                    child: widget.clientProfileModel.profileImage.isNotEmpty
                                        ? Image.network(
                                      widget.clientProfileModel.profileImage,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          "assets/images/icons/default2.png",
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;

                                        final expected = loadingProgress.expectedTotalBytes;
                                        final loaded = loadingProgress.cumulativeBytesLoaded;

                                        return Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              value: expected != null ? loaded / expected : null, // safe
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                        : Image.asset(
                                      "assets/images/icons/default2.png",
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),

                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Text(widget.clientProfileModel.email,
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
                              Text("Consultant Linked",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Visibility(
                                visible: widget.dietitianDetailModel.name!="NA",
                                replacement: Text("Not Linked",   style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.24,
                                ),),
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Text(widget.dietitianDetailModel.name,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF535359),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.24,
                                        height: 1.2,
                                      ),
                                    ),
                                    Container(
                                      height: 12,
                                      width: 1.5,
                                      color: const Color(0xFF535359),
                                    ),
                                    Text("Active",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF3EAF58),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.24,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Text("General",
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


                          InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Profile(clientProfileModel: widget.clientProfileModel,),
                                ),
                              );
                            },
                            child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Profile Settings",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Plans",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  Text("Your Plans",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.24,
                                      height: 1.2,
                                    ),
                                  ),
                                  Container(
                                    height: 12,
                                    width: 1.5,
                                    color: const Color(0xFF535359),
                                  ),
                                  Text("Active",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF3EAF58),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.24,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Notifications",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                  Text("Daily diet and test reminders",
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
                              CupertinoSwitch(
                                value: value,
                                onChanged: (v) => setState(() => value = v),
                                activeTrackColor: const Color(0xFF308BF9),     // track when ON
                                thumbColor: const Color(0xFFCAE1FF),
                                trackOutlineWidth:WidgetStateProperty.resolveWith(
                                      (states) => states.contains(WidgetState.selected)
                                      ? 1  // no outline when ON
                                      : 1, // outline when OFF
                                ),
                                inactiveThumbColor: const Color(0xFFA1A1A1),
                                trackOutlineColor: WidgetStateProperty.resolveWith(
                                      (states) => states.contains(WidgetState.selected)
                                      ? Colors.transparent  // no outline when ON
                                      : const Color(0xFFA1A1A1), // outline when OFF
                                ),
                                // knob color
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Text("Help Center",
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
                              Text("FAQ",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Report An Issue",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Text("About",
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
                              Text("Privacy Policy",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Terms of Service",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: TextButton(
                      onPressed: (){


                        Logout().show(context,isLoggingOut: (bool isLoggingOut) {

                          setState(() {
                            isLoggingOut=this.isLoggingOut;
                          });

                        });
                      },
                      child: Text("Logout",style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.10,
                        letterSpacing: -0.30,
                      ),)
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
