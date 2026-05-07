import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';
import 'package:respyr_dietitian/features/select_client/presentation/widgets/profile_item.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class SearchClientsScreen extends StatefulWidget {
  final List<ClientProfileModel> profiles;
  final CoachProfileModel coachProfileModel;

  const SearchClientsScreen({super.key, required this.profiles, required this.coachProfileModel});

  @override
  State<SearchClientsScreen> createState() => _SearchClientsScreenState();
}

class _SearchClientsScreenState extends State<SearchClientsScreen> {
  final TextEditingController _controller = TextEditingController();

  String _query = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ClientProfileModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.profiles;

    return widget.profiles.where((c) {
      final name = c.profileName.toLowerCase();
      final email = c.email.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _query = "");
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      // Ensure the Scaffold resizes when the keyboard opens
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: rh(context: context, px: 10)),
          child: Hero(
            tag: "search-bar",
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 12),
                        fontWeight: FontWeight.w400,
                        letterSpacing: rh(context: context, px: -0.24),
                      ),
                      decoration: InputDecoration(
                        hintText: "Name, Email address",
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
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 140),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _query.isNotEmpty
                        ? Row(
                      key: const ValueKey("clear"),
                      children: [
                        SizedBox(width: rh(context: context, px: 6)),
                        InkWell(
                          borderRadius: BorderRadius.circular(
                            rh(context: context, px: 20),
                          ),
                          onTap: _clearSearch,
                          child: Padding(
                            padding: EdgeInsets.all(
                              rh(context: context, px: 6),
                            ),
                            child: Icon(
                              Icons.close,
                              size: rh(context: context, px: 18),
                              color: const Color(0xFFA1A1A1),
                            ),
                          ),
                        ),
                      ],
                    )
                        : const SizedBox(key: ValueKey("empty")),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Removed AnimatedPadding as it causes layout conflicts with resizeToAvoidBottomInset
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 10),
            vertical: rh(context: context, px: 10),
          ),
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
            child: results.isEmpty
                ? Center(
              child: Text(
                "No clients found",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            )
                : ListView.separated(
              // Allows user to swipe down to hide keyboard
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: results.length,
              separatorBuilder: (_, __) => SizedBox(
                height: rh(context: context, px: 30),
              ),
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: ProfileItem(
                    clientProfileModel: results[index], onItemClick: () {


                    context.go(
                      AppRoutes.coachDashboardMain,
                      extra: {
                        'client': results[index],
                        'coach': widget.coachProfileModel,
                      },
                    );


                  },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}