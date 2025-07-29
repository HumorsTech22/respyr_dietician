import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietician/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietician/routes/app_routes.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profileImage = state.profileImage;

        return Center(
          child: GestureDetector(
            onTap: () {
              if (profileImage != null) {
                context.push(
                  AppRoutes.fullScreenImageView,
                  extra: profileImage,
                );
              } else {
                return;
              }
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  profileImage != null ? MemoryImage(profileImage) : null,
              child:
                  profileImage == null
                      ? SvgPicture.asset(
                        "assets/images/common/profile_logo.svg",
                        height: 60,
                      )
                      : null,
            ),
          ),
        );
      },
    );
  }
}
