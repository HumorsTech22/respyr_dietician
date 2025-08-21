import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'email_otp.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  String? errorText;
  bool isOtpSending = false;
  DateTime? _lastClickTime;

  @override
  void dispose() {
    emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    final now = DateTime.now();

    // Prevent double-tap within 1 second
    if (_lastClickTime != null &&
        now.difference(_lastClickTime!) < const Duration(seconds: 1)) {
      return;
    }
    _lastClickTime = now;

    final email = emailController.text.trim();

    if (email.isEmpty || !isValidEmail(email)) {
      setState(() => errorText = "Please enter a valid email");
      return;
    }

    if (!isOtpSending) {
      setState(() => isOtpSending = true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailOtp(
            enteredEmail: email,
          ),
        ),
      );
    }
  }





  bool isValidEmail(String email) {
    final emailRegex =
    RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );

    final hintStyle = GoogleFonts.poppins(
      color: const Color(0xFF535359),
      fontSize: 15,
      fontWeight: FontWeight.w300,
      height: 1.10,
      letterSpacing: -0.30,
    );

    final errorStyle = GoogleFonts.poppins(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final greyTextStyle = GoogleFonts.poppins(
      color: const Color(0xFFA1A1A1),
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.72,
    );

    final linkTextStyle = greyTextStyle.copyWith(
      color: const Color(0xFF308BF9),
      decoration: TextDecoration.underline,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
              const SizedBox(height: 18),
              Text(
                "Email",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: errorText != null ? Colors.red : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/icons/ic_email.svg",
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        focusNode: _emailFocusNode,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 50,
                        decoration: InputDecoration(
                          hintText: "Enter email address",
                          hintStyle: hintStyle,
                          counterText: "",
                          border: noBorder,
                          enabledBorder: noBorder,
                          focusedBorder: noBorder,
                          disabledBorder: noBorder,
                        ),
                        onChanged: (_) {
                          if (errorText != null) {
                            setState(() => errorText = null);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (errorText != null && errorText!.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(errorText!, style: errorStyle),
              ],
              const Spacer(),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "By continuing, you agree to our ",
                          style: greyTextStyle),
                      TextSpan(
                          text: "Terms and Conditions",
                          style: linkTextStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProfileBottomNavigation(
        onBack: () => Navigator.pop(context),
        onNext: _validateInput,
      ),
    );
  }
}
