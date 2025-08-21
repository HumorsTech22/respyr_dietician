import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../client-dashboard/extras/date_helper.dart';
import '../blocs/notification_bloc.dart';
import '../repositories/notification_repository.dart';

class NotificationScreen extends StatelessWidget {
  final String targetId;
  const NotificationScreen({super.key, required this.targetId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      NotificationBloc(NotificationRepository())..add(FetchNotifications(targetId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text("Notifications")),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text("No notifications."));
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return Container(
                      height: 100,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 15,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(notification.title),
                              Text("${notification.message.substring(0,8)}......."),
                              Row(
                                children: [

                                ],
                              )
                            ],
                          ),
                          Positioned(
                            bottom: 6,
                              right: 10,
                              child: Text(formatToDateTimeString(notification.createdAt))
                          )
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
