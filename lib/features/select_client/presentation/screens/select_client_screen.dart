import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';
import 'package:respyr_dietitian/features/select_client/bloc/client_profile_bloc.dart';
import 'package:respyr_dietitian/features/select_client/bloc/client_profile_event.dart';
import 'package:respyr_dietitian/features/select_client/bloc/client_profile_state.dart';
import 'package:respyr_dietitian/features/select_client/presentation/widgets/profile_item.dart';
import 'package:respyr_dietitian/features/select_client/services/client_profile_service.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

enum ClientSortOption { recentlyAdded, aToZ, zToA }

class SelectClientScreen extends StatefulWidget {
  final CoachProfileModel coachProfileModel;
  const SelectClientScreen({super.key, required this.coachProfileModel});

  @override
  State<SelectClientScreen> createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  ClientSortOption _sortOption = ClientSortOption.recentlyAdded;

  String _sortLabel(ClientSortOption option) {
    switch (option) {
      case ClientSortOption.recentlyAdded:
        return "Recently Added";
      case ClientSortOption.aToZ:
        return "A to Z";
      case ClientSortOption.zToA:
        return "Z to A";
    }
  }

  List _applySort(List clients) {
    final sorted = List.from(clients);

    if (_sortOption == ClientSortOption.aToZ) {
      sorted.sort((a, b) => a.profileName
          .toString()
          .toLowerCase()
          .compareTo(b.profileName.toString().toLowerCase()));
      return sorted;
    }

    if (_sortOption == ClientSortOption.zToA) {
      sorted.sort((a, b) => b.profileName
          .toString()
          .toLowerCase()
          .compareTo(a.profileName.toString().toLowerCase()));
      return sorted;
    }

    return sorted.reversed.toList();
  }

  Future<void> _openSortMenu() async {
    final selected = await showMenu<ClientSortOption>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 220, 12, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rh(context: context, px: 12)),
      ),
      color: Colors.white,
      items: [
        PopupMenuItem(
          value: ClientSortOption.recentlyAdded,
          child: Text(
            "Recently Added",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.24),
            ),
          ),
        ),
        PopupMenuItem(
          value: ClientSortOption.aToZ,
          child: Text(
            "A to Z",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.24),
            ),
          ),
        ),
        PopupMenuItem(
          value: ClientSortOption.zToA,
          child: Text(
            "Z to A",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 12),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.24),
            ),
          ),
        ),
      ],
    );

    if (selected != null) {
      setState(() => _sortOption = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientProfileBloc(service: ClientProfileService())
        ..add( FetchClientsByDietician(widget.coachProfileModel.dietitianId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FA),
          surfaceTintColor: const Color(0xFFF5F7FA),
          elevation: 0,
          centerTitle: false,
          title: Text(
            "Clients",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 15),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(context: context, px: -0.30),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 10),
              vertical: rh(context: context, px: 10),
            ),
            child: BlocBuilder<ClientProfileBloc, ClientProfileState>(
              builder: (context, state) {
                final canOpen = state is ClientProfileLoaded;
                final showSection = state is ClientProfileLoading ||
                    state is ClientProfileLoaded ||
                    state is ClientProfileError;

                return Column(
                  children: [
                    InkWell(
                      onTap: canOpen
                          ? () {
                        final clients = (state).clients;
                        context.push(
                          AppRoutes.searchClients,
                          extra: {
                            'profiles': clients,
                            'coach': widget.coachProfileModel,
                          },
                        );
                      }
                          : null,
                      child: Hero(
                        tag: "search-bar",
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 13),
                              vertical: rh(context: context, px: 14),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 15),
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/icons/ic_search.svg",
                                  width: rh(context: context, px: 18),
                                  height: rh(context: context, px: 18),
                                ),
                                SizedBox(width: rh(context: context, px: 10)),
                                Expanded(
                                  child: TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      hintText: "Name, Mobile number, Email address",
                                      hintStyle: GoogleFonts.poppins(
                                        color: const Color(0xFFA1A1A1),
                                        fontSize: rh(context: context, px: 12),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: rh(context: context, px: -0.24),
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (showSection) ...[
                      SizedBox(height: rh(context: context, px: 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxHeight: rh(context: context, px: 31),
                              minHeight: rh(context: context, px: 31)
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 10),
                              ),
                              border: Border.all(
                                color: const Color(0xFFD9D9D9),
                                width: rh(context: context, px: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: rh(context: context, px: 15)),
                                Text(
                                  "Sort By",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: rh(context: context, px: 12),
                                    fontWeight: FontWeight.w600,
                                    height: rh(context: context, px: 1.10),
                                    letterSpacing: rh(context: context, px: -0.24),
                                  ),
                                ),
                                SizedBox(width: rh(context: context, px: 10)),
                                Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      left: BorderSide(
                                        width: rh(context: context, px: 1),
                                        color: const Color(0xFFD9D9D9),
                                      ),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                      bottomRight: Radius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                      bottomRight: Radius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                    ),
                                    onTap: state is ClientProfileLoaded ? _openSortMenu : null,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: rh(context: context, px: 0),
                                        horizontal: rh(context: context, px: 10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _sortLabel(_sortOption),
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF535359),
                                              fontSize: rh(context: context, px: 12),
                                              fontWeight: FontWeight.w400,
                                              height: rh(context: context, px: 1.0),
                                              letterSpacing: rh(context: context, px: -0.24),
                                            ),
                                          ),
                                          SizedBox(width: rh(context: context, px: 13.92)),
                                          Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            color: const Color(0xFF535359),
                                            size: rh(context: context, px: 15),
                                          ),
                                          SizedBox(width: rh(context: context, px: 15)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: rh(context: context, px: 12)),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: rh(context: context, px: 20),
                            vertical: rh(context: context, px: 19),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 15),
                            ),
                          ),
                          child: Builder(
                            builder: (_) {
                              if (state is ClientProfileLoading) {
                                return Center(
                                  child: SizedBox(
                                    width: rh(context: context, px: 22),
                                    height: rh(context: context, px: 22),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  ),
                                );
                              }

                              if (state is ClientProfileError) {
                                return Center(
                                  child: Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: rh(context: context, px: 12),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: rh(context: context, px: -0.24),
                                    ),
                                  ),
                                );
                              }

                              if (state is ClientProfileLoaded) {
                                final sortedClients = _applySort(state.clients);

                                if (sortedClients.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No clients found",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF535359),
                                        fontSize: rh(context: context, px: 12),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: rh(context: context, px: -0.24),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  itemCount: sortedClients.length,
                                  separatorBuilder: (context, index) => SizedBox(
                                    height: rh(context: context, px: 30),
                                  ),
                                  itemBuilder: (context, index) {
                                    final client = sortedClients[index];
                                    return ProfileItem(clientProfileModel: client, onItemClick: () {

                                      context.go(
                                        AppRoutes.coachDashboardMain,
                                        extra: {
                                          'client': client,
                                          'coach': widget.coachProfileModel,
                                        },
                                      );

                                    },);
                                  },
                                );
                              }

                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF308BF9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                rh(context: context, px: 15),
              ),
            ),
            elevation: rh(context: context, px: 0),
            padding: EdgeInsets.symmetric(
              vertical: rh(context: context, px: 14),
              horizontal: rh(context: context, px: 20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/images/icons/ic_add_client.svg"),
              SizedBox(width: rh(context: context, px: 6)),
              Text(
                "Add New Client",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w600,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}