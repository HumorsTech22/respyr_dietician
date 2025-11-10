import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/chat_manger/presentation/screen/chat_screen.dart';
import '../../../client-dashboard/data/model/dietitian_model.dart';
import '../../../client-dashboard/extras/date_helper.dart';
import '../../../common/widgets/common_appbar.dart';
import '../../../common/widgets/pill.dart';
import '../../../core/utils/date_helper.dart';
import '../blocs/notification_bloc.dart';
import '../repositories/notification_repository.dart';

class NotificationScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianModel? dietitianModel;

  const NotificationScreen({
    super.key,
    required this.clientProfileModel,
    this.dietitianModel,   // optional now
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(NotificationRepository())
        ..add(FetchNotifications(clientProfileModel.profileId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: commonAppbar(
          onBackButtonPress: () {},
          title: 'Notifications',
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Notifications",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA1A1A1),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.20,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: ListView.builder(
                  itemCount: state.notifications.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return GestureDetector(
                      onTap: () {
                        if (notification.notificationType == "message" &&
                            dietitianModel != null) {   // check before using
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => ChatScreen(
                          //       dietitianModel: dietitianModel!,
                          //     ),
                          //   ),
                          // );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          notification.title,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            height: 1.26,
                                            letterSpacing: -0.30,
                                          ),
                                        ),
                                        Spacer(),
                                        Visibility(
                                          visible: DateHelper().isNewNotification(notification.createdAt),
                                          child: Pill(label: 'New',
                                            variant: PillVariant.soft,
                                            backgroundColor: Colors.green.shade400,
                                            textColor: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 50),
                                      child: Text(
                                        notification.message,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF252525),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.24,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        formatToDateTimeString(notification.createdAt),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF535359),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                          letterSpacing: -0.24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else if (state is NotificationError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
