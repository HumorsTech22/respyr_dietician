import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/widgets/loading_screen.dart';
import 'package:respyr_dietitian/features/select_client/bloc/client_profile_event.dart';
import 'package:respyr_dietitian/features/select_client/bloc/client_profile_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../bloc/client_profile_bloc.dart';
import '../../services/client_profile_service.dart';
import '../widgets/profile_card.dart';

class WhoIsUsingScreen extends StatelessWidget {
  final CoachProfileModel coachProfileModel;

  const WhoIsUsingScreen({
    super.key,
    required this.coachProfileModel,
  });

  @override
  Widget build(BuildContext context) {
    final padH = rh(context: context, px: 17);
    final padTop = rh(context: context, px: 47);
    final padBottomGrid = rh(context: context, px: 30);

    final titleStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontSize: rh(context: context, px: 34),
      fontWeight: FontWeight.w400,
      letterSpacing: rh(context: context, px: -2.04),
    );

    final featuredStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontSize: rh(context: context, px: 25),
      fontWeight: FontWeight.w600,
      letterSpacing: rh(context: context, px: -1),
    );

    final addBtnTextStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontSize: rh(context: context, px: 12),
      fontWeight: FontWeight.w600,
      letterSpacing: rh(context: context, px: -0.24),
    );

    final addBtnRadius = rh(context: context, px: 30);
    final addBtnPadV = rh(context: context, px: 14);
    final addBtnPadH = rh(context: context, px: 20);
    final addBtnGap = rh(context: context, px: 10);

    final fabGap = rh(context: context, px: 12);
    final iconPad = rh(context: context, px: 14);

    final v39 = rh(context: context, px: 39);
    final v30 = rh(context: context, px: 30);
    final v47 = rh(context: context, px: 47);
    final v6 = rh(context: context, px: 6);

    return BlocProvider(
      create: (_) => ClientProfileBloc(service: ClientProfileService())
        ..add(FetchClientsByDietician(coachProfileModel.dietitianId)),
      child: BlocBuilder<ClientProfileBloc, ClientProfileState>(
        buildWhen: (p, c) =>
        p.runtimeType != c.runtimeType || c is ClientProfileLoaded,
        builder: (context, state) {
          if (state is ClientProfileLoading) {
            return const LoadingScreen();
          }

          if (state is ClientProfileLoaded) {
            final clients = state.clients;

            if (clients.isEmpty) {
              return Scaffold(
                backgroundColor: const Color(0xFF308BF9),
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padH, padTop, padH, 0),
                    child: Column(
                      children: [
                        Text("Who’s using Respyr today?", style: titleStyle),
                        SizedBox(height: v47),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF252525),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 38),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: rh(context: context, px: 16),
                              horizontal: rh(context: context, px: 26),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                  "assets/images/icons/ic_add_client.svg"),
                              SizedBox(width: v6),
                              Text("Add New Client", style: addBtnTextStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final itemCount = clients.length >= 6 ? 6 : clients.length;

            return Scaffold(
              backgroundColor: const Color(0xFF308BF9),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    padH,
                    padTop,
                    padH,
                    padBottomGrid,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Who’s using Respyr today?", style: titleStyle),
                      SizedBox(height: v39),
                      Text("Featured", style: featuredStyle),
                      SizedBox(height: v30),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            const crossAxisCount = 2;
                            const rows = 3;

                            final spacing = rh(context: context, px: 10);

                            final maxW = c.maxWidth;
                            final maxH = c.maxHeight;

                            final itemW = (maxW - (crossAxisCount - 1) * spacing) / crossAxisCount;
                            final itemH = (maxH - (rows - 1) * spacing) / rows;

                            final size = itemW < itemH ? itemW : itemH;

                            final itemCount = clients.length >= 6 ? 6 : clients.length;

                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: itemCount,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                mainAxisExtent: size,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: size,
                                  height: size,
                                  child: ProfileCard(
                                    clientProfileModel: clients[index],
                                    onTap: () {
                                      context.go(
                                        AppRoutes.coachDashboardMain,
                                        extra: {
                                          'client': clients[index],
                                          'coach': coachProfileModel,
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF252525),
                        padding: EdgeInsets.symmetric(
                          horizontal: addBtnPadH,
                          vertical: addBtnPadV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(addBtnRadius),
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                              "assets/images/icons/ic_add_client.svg"),
                          SizedBox(width: addBtnGap),
                          Text("Add Client", style: addBtnTextStyle),
                        ],
                      ),
                    ),
                    SizedBox(width: fabGap),
                    IconButton(
                      onPressed: () => context.push(
                        AppRoutes.selectClient,
                        extra: coachProfileModel,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF252525),
                        padding: EdgeInsets.all(iconPad),
                        shape: const CircleBorder(),
                      ),
                      icon: SvgPicture.asset(
                          "assets/images/icons/ic_search.svg"),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}