import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/issue_with_connection/issue_with_connection_cubit.dart';
import 'package:respyr_dietitian/features/device_connectivity/presentation/cubit/issue_with_connection/issue_with_connection_state.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueWithConnectionScreen extends StatelessWidget {
  const IssueWithConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => OtgCubit(OpenSettingsUseCase(OtgRepository())),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<OtgCubit, OtgState>(
          listener: (context, state) {
            if (state is OtgError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final cubit = context.read<OtgCubit>();

            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: SvgPicture.asset(
                            "assets/images/common/closeicon.svg",
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: SvgPicture.asset(
                          "assets/images/device_connection/not_connected.svg",
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        "Issue with connection?",
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        'Solution',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3FAF58),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        'Turn on OTG connection and try again',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF595959),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Image.asset(
                        'assets/images/device_connection/issue_with_connection.png',
                        height: 100,
                      ),
                      SizedBox(height: height * 0.01),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _instructions(),
                      ),
                      if (Platform.isAndroid)
                        GestureDetector(
                          onTap: () => cubit.openSettings(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Go To Setting',
                                style: GoogleFonts.mulish(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF308BF9),
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/images/common/right_button.svg",
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF308BF9),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (state is OtgLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _bottomSection(context, height, width),
      ),
    );
  }

  Widget _instructions() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.mulish(
          fontSize: 15,
          color: const Color(0xFF595959),
          fontWeight: FontWeight.w400,
        ),
        children: const [
          TextSpan(text: '1. Go to '),
          TextSpan(
            text: 'Setting > Search for OTG ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: 'in phone settings\n\n'),
          TextSpan(text: '2. '),
          TextSpan(
            text: 'Turn On ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: 'OTG connection\n\n'),
          TextSpan(text: '3. '),
          TextSpan(
            text: 'Restart ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: 'respyr app\n\n'),
          TextSpan(text: '4. Now '),
          TextSpan(
            text: 'remove and reconnect ',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: 'the respyr device\n\n '),
        ],
      ),
    );
  }

  Widget _bottomSection(BuildContext context, double height, double width) {
    return SafeArea(
      bottom: true,
      child: Container(
        height: height * 0.15,
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            const Divider(color: Color(0xFFD9D9D9)),
            const Spacer(),
            Center(
              child: Text(
                "Still having issue with connection",
                textAlign: TextAlign.center,
                style: GoogleFonts.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF595959),
                ),
              ),
            ),
            SizedBox(height: height * 0.01),
            SizedBox(
              height: height * 0.07,
              width: width * 0.9,
              child: TextButton(
                onPressed: () => ShowSupportSheet.show(context),
                style: ButtonStyle(
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Color(0xFF308BF9)),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                child: Text(
                  'Contact Support',
                  style: GoogleFonts.mulish(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF308BF9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowSupportSheet {
  static void show(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: height * 0.32,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Contact Support Via',
                  style: GoogleFonts.mulish(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF308BF9),
                  ),
                ),
                SizedBox(height: height * 0.04),
                SupportButton(
                  label: 'WhatsApp',
                  iconPath: "assets/images/device_connection/whatsapp_icon.svg",
                  url: SupportLinks.whatsappUrl,
                ),
                SizedBox(height: height * 0.02),
                SupportButton(
                  label: 'E-mail',
                  iconPath: "assets/images/device_connection/mail_icon.svg",
                  url: SupportLinks.emailUrl,
                ),
              ],
            ),
          ),
    );
  }
}

class SupportButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final Uri url;

  const SupportButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height * 0.075,
      width: width * 0.9,
      child: TextButton(
        onPressed: () async {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch app')),
            );
          }
        },
        style: ButtonStyle(
          side: WidgetStateProperty.all(
            const BorderSide(color: Color(0xFF308BF9)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath),
            SizedBox(width: width * 0.02),
            Text(
              label,
              style: GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF595959),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportLinks {
  static final Uri whatsappUrl = Uri.parse(
    "https://wa.me/8296380628?text=Hi%2C%20I%20need%20some%20help",
  );

  static final Uri emailUrl = Uri.parse(
    "mailto:connect@humorstech.com?subject=Support%20Request&body=Hi%20team%2C%20I%20need%20assistance%20with...",
  );
}
