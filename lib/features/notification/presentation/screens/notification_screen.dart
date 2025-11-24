import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../widgets/notification_item.dart';
import '../widgets/notification_type_chip.dart';

class NotificationScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const NotificationScreen({super.key, required this.clientProfileModel});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  final List<String> notificationTypes = ["All","Reminders","Promotions","Message"];
  String selectedNotificationLabel = "All";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),

        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("Notifications",
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
                  padding: EdgeInsets.symmetric(vertical: 18,horizontal: 20),
                  child: Row(
                    spacing: 30,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            Text("Turn ON/OFF Notifications",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: -0.30,
                              ),
                            ),
                            Text("Daily reminders, promotional and messages",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF535359),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: -0.24,
                              ),
                            )
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: true,
                        onChanged: (v) {



                        },
                        activeTrackColor: const Color(0xFF308BF9),
                        thumbColor: const Color(0xFFCAE1FF),
                        trackOutlineWidth: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.selected) ? 1 : 1,
                        ),
                        inactiveThumbColor: const Color(0xFFA1A1A1),
                        trackOutlineColor: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.selected)
                              ? Colors.transparent
                              : const Color(0xFFA1A1A1),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                      child: Column(
                        spacing: 20,
                        children: [

                          SizedBox(
                            height: 30,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              itemCount: notificationTypes.length,
                              itemBuilder: (context, index) {
                                final type = notificationTypes[index];

                                return notificationTypeChip(
                                  notificationType: type,
                                  isActive: selectedNotificationLabel == type,   // <-- FIXED
                                  onClick: () {
                                    setState(() {
                                      selectedNotificationLabel = type;          // <-- FIXED
                                    });
                                    print("Selected: $type");
                                  },
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(width: 10),
                            ),
                          ),



                          Expanded(
                            child: SingleChildScrollView(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                itemCount: 15,
                                itemBuilder: (context, index) {

                                  return notificationItem(
                                    notificationTitle: "Don’t forget to take your test, Buddy!",
                                    notificationMessage: 'Lorem ipsum dolor sit amet consectetur. Diam.',
                                    timeAgo: '16 hrs ago',
                                    isSeen: index==0 ? true :false,
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 20),
                              ),
                            ),
                          )





                        ],
                      ),
                    ),
                  )
              ),
              SizedBox(height: 10,),
            ],
          )
      ),

    );
  }
}
