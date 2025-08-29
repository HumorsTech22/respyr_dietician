import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/domain/dietitian_result_view_model.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/cubit/dietitian_result_cubit.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/cubit/dietitian_result_state.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/bmi_bmr_widget.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/metabolism_card.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/section_widget.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/sliver_tabbar_delegate.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/presentation/widgets/tab_widget.dart';

// class DietitianResultCntent extends StatelessWidget {
//   const DietitianResultCntent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }

class DietitianResultScreen extends StatefulWidget {
  const DietitianResultScreen({super.key});

  @override
  State<DietitianResultScreen> createState() => _DietitianResultScreenState();
}

class _DietitianResultScreenState extends State<DietitianResultScreen> {
  final viewModel = DietitianResultViewModel();

  @override
  void initState() {
    super.initState();

    viewModel.scrollController.addListener(_onVerticalScroll);
  }

  void _onVerticalScroll() {
    if (!viewModel.tabScrollController.hasClients || viewModel.isAnimating) {
      return;
    }
    final offset = viewModel.scrollController.offset;
    final gutPos = _getOffSet(viewModel.gutKey);
    final fatPos = _getOffSet(viewModel.fatKey);
    final liverPos = _getOffSet(viewModel.liverKey);

    final cubit = context.read<DietitianResultCubit>();

    if (offset >= gutPos && offset < fatPos) {
      if (cubit.state.selectedTab != "Gut") {
        cubit.changeTab("Gut");
        viewModel.tabScrollTo(viewModel.tabGutKey);
      }
    } else if (offset >= fatPos && offset < liverPos) {
      if (cubit.state.selectedTab != "Fat") {
        cubit.changeTab("Fat");
        viewModel.tabScrollTo(viewModel.tabFatKey);
      }
    } else if (offset >= liverPos) {
      if (cubit.state.selectedTab != "Liver") {
        cubit.changeTab("Liver");
        viewModel.tabScrollTo(viewModel.tabLiverKey);
      }
    }
  }

  double _getOffSet(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return double.infinity;

    final box = ctx.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero).dy +
        viewModel.scrollController.offset;
  }

  @override
  void dispose() {
    viewModel.scrollController.removeListener(_onVerticalScroll);
    viewModel.scrollController.dispose();
    viewModel.tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DietitianResultCubit, DietitianResultState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            controller: viewModel.scrollController,
            slivers: [
              /// Sliver AppBar
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFF308BF9),
                expandedHeight: 50,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Shubham Deshmukh',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.72,
                        ),
                      ),
                      Text(
                        '25 June 2025, 12:00pm',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/images/result_screen/dietitian_result_share.svg",
                    ),
                  ),
                ],
              ),

              /// Content above sticky tabs
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BmiBmrCard(
                            bodyMassIndex: 25.0,
                            basalMetabolicRate: 1827.00,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Scores Overview',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            "assets/images/result_screen/dietitian.png",
                            height: MediaQuery.of(context).size.height * 0.55,
                            width: MediaQuery.of(context).size.width * 0.55,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                SizedBox(height: 15),
                                MetabolismCard(metabolismType: 'Liver'),
                                SizedBox(height: 25),
                                MetabolismCard(metabolismType: 'Fat'),
                                SizedBox(height: 25),
                                MetabolismCard(metabolismType: 'Gut'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scores Interpretation',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.26,
                                letterSpacing: -0.24,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Scores interpretations are based on the values recorded by Respyr device. Please refer to the reference ',
                                ),
                                TextSpan(
                                  text: 'link',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF308BF9),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: ' for more details.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Sticky Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverTabBarDelegate(
                  child:
                      BlocBuilder<DietitianResultCubit, DietitianResultState>(
                        builder: (context, state) {
                          return SingleChildScrollView(
                            controller: viewModel.tabScrollController,
                            scrollDirection: Axis.horizontal,

                            child: _buildTabs(state),
                          );
                        },
                      ),
                ),
              ),

              /// Sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SectionWidget(
                    sectionKey: viewModel.gutKey,
                    sectionType: 'Gut',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SectionWidget(
                    sectionKey: viewModel.fatKey,
                    sectionType: 'Fat',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SectionWidget(
                    sectionKey: viewModel.liverKey,
                    sectionType: 'Liver',
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SafeArea(
                  minimum: EdgeInsets.only(bottom: 26),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disclaimer',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.30,
                            letterSpacing: -0.24,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'This is a sample interpretation guide designed for use by certified dietitians and wellness professionals.  Respyr is a non-invasive lifestyle monitoring tool. It does not diagnose, prevent, or treat disease.   All data is derived from breath-based VOC analysis and should be interpreted within lifestyle and nutritional context.   For medical conditions or abnormalities (e.g., diabetic ketoacidosis, chronic liver disease, IBS/SIBO), users should be referred to licensed physicians.',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.30,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() {
    return Container(height: 43, width: 1, color: Colors.black);
  }

  Widget _buildTabs(DietitianResultState state) {
    final cubit = context.read<DietitianResultCubit>();
    return Row(
      children: [
        TabWidget(
          key: viewModel.tabGutKey,
          text: "Gut Fermentation Metabolism",
          isActive: state.selectedTab == "Gut",
          onTap: () async {
            if (!mounted) return;

            cubit.changeTab("Gut");
            await viewModel.scrollTo(viewModel.gutKey);
            viewModel.tabScrollTo(viewModel.tabGutKey);
          },
        ),
        _divider(),
        TabWidget(
          key: viewModel.tabFatKey,
          text: "Glucose vs Fat Metabolism",
          isActive: state.selectedTab == "Fat",
          onTap: () async {
            if (!mounted) return;

            cubit.changeTab("Fat");
            await viewModel.scrollTo(viewModel.fatKey);
            viewModel.tabScrollTo(viewModel.tabFatKey);
          },
        ),
        _divider(),
        TabWidget(
          key: viewModel.tabLiverKey,
          text: "Liver Hepatic Metabolism",
          isActive: state.selectedTab == "Liver",
          onTap: () async {
            if (!mounted) return;

            cubit.changeTab("Liver");
            await viewModel.scrollTo(viewModel.liverKey);
            viewModel.tabScrollTo(viewModel.tabLiverKey);
          },
        ),
      ],
    );
  }
}
