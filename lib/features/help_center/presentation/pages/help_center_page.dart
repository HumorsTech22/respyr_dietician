import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/help_center/data/help_center_faq_quest.dart';
import '../cubit/help_center_cubit.dart';
import '../cubit/help_center_state.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      builder: (context, state) {
        if (state is HelpCenterLoaded) {
          return Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Help Center',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FAQ',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 34,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -2.04,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Here are some frequently asked question with solutions',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(faqItems.length, (index) {
                        final isExpanded = state.expandedFaqs[index];

                        return CustomFaqTile(
                          question: faqItems[index].question,
                          answer: faqItems[index].answer,
                          isExpanded: isExpanded,
                          onToggle: () {
                            context.read<HelpCenterCubit>().toggleFaq(index);
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              height: 180,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Didn't find what you're looking for?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                      letterSpacing: -0.24,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF252525),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFC7C6CE),
                          ),

                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Contact Support',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.10,
                          letterSpacing: 0.30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 33,
                    child: TextButton(
                      onPressed: () {},
                      clipBehavior: Clip.antiAlias,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFC7C6CE),
                          ),
                          borderRadius: BorderRadius.circular(25.5),
                        ),
                      ),
                      child: Text(
                        "Report An Issue",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 12,

                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class CustomFaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CustomFaqTile({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(isExpanded ? Icons.remove : Icons.add),
                color: Color(0xFF308BF9),
              ),
            ],
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
