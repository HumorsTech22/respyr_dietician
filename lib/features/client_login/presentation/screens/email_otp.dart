import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../client-dashboard/presentation/screens/client_dashboard.dart';
import '../../../../client_login_manager/client_login_manager.dart';
import '../../../../routes/app_routes.dart';
import '../../../profile_info/presentation/widgets/profile_bottom_navigation.dart';
import '../../data/services/check_profile_client.dart';
import '../../data/services/download_network_image_service.dart';
import '../../data/services/send_otp_email.dart';
import '../widgets/otp_view.dart';


class EmailOtp extends StatefulWidget {
  final String enteredEmail;

  const EmailOtp({
    super.key,
    required this.enteredEmail,
  });

  @override
  State<EmailOtp> createState() => _EmailOtpState();
}

class _EmailOtpState extends State<EmailOtp> {
  String? errorText;
  int? enteredOTP;
  bool error = false;
  bool isLoading = false;

  int? _receivedOTP; // <- the OTP we actually sent (or received back from API)
  static const int _initialCountdown = 60;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _canResend = false;
  bool _isSending = false; // prevents concurrent sends

  // Styles
  final TextStyle errorStyle = GoogleFonts.poppins(
    color: Colors.red,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  final TextStyle greyTextStyle = GoogleFonts.poppins(
    color: const Color(0xFFA1A1A1),
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.72,
  );

  late final TextStyle linkTextStyle;

  @override
  void initState() {
    super.initState();
    linkTextStyle = greyTextStyle.copyWith(
      color: const Color(0xFF308BF9),
      decoration: TextDecoration.underline,
    );

    // Send OTP when screen loads (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtpAndStartTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Secure-ish random generator for OTP
  String _generateOtpString() {
    final random = Random.secure();
    final otp = 1111 + random.nextInt(8889); // range 1111..9999
    return otp.toString();
  }

  /// Send OTP then start countdown if success. Safe parsing of the OTP is used.
  Future<void> handleSendOtp(String email) async {
    if (_isSending) return;
    if (!_isValidEmail(email)) {
      setState(() => errorText = "Invalid email format");
      return;
    }

    setState(() {
      errorText = null;
      _isSending = true;
    });

    final generatedOtp = _generateOtpString();

    try {
      final result = await sendOtpToEmail(email, generatedOtp);

      // If API says success, prefer returned otp if present, otherwise fallback to generatedOtp
      if (result['success'] == true) {
        final returnedOtpString = result['otp']?.toString();
        final parsedReturned = int.tryParse(returnedOtpString ?? '');

        // prefer API OTP if valid, otherwise fallback to our generated OTP
        _receivedOTP = parsedReturned ?? int.tryParse(generatedOtp);

        Fluttertoast.showToast(
          msg: "OTP sent successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // start countdown
        _startCountdown(_initialCountdown);
      } else {
        final message = (result['message'] != null)
            ? result['message'].toString()
            : "Failed to send OTP";
        setState(() => errorText = message);
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() => errorText = "Error sending OTP: ${e.toString()}");
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Small wrapper used for initial post-frame send and resend button
  Future<void> _sendOtpAndStartTimer() async {
    await handleSendOtp(widget.enteredEmail);
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> validateOTP() async {
    // basic checks
    if (enteredOTP == null) {
      setState(() {
        error = true;
        errorText = "Please enter the OTP";
      });
      return;
    }

    if (_receivedOTP == null) {
      setState(() {
        error = true;
        errorText = "OTP not available. Please resend.";
      });
      return;
    }

    if (enteredOTP != _receivedOTP) {
      setState(() {
        error = true;
        errorText = "Invalid OTP entered";
      });
      return;
    }

    // Good -> verify profile
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {

      Fluttertoast.showToast(
        msg: "OTP verified successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );


      final profile = await checkClientProfile(widget.enteredEmail, "");
      setState(() => isLoading = false);
      if (profile != null) {
        bool isSaved = await ClientLoginManager().saveClientProfile(profile);
        if (isSaved && mounted) {
          context.go(
            AppRoutes.clientDashboard,
            extra: profile,
          );
        } else {
          _showSnackBar('Failed to save client profile.');
        }
      }else {

        if(mounted){
          context.push(
            AppRoutes.dietitianScreen,
            extra: {
              "enteredEmail": widget.enteredEmail,
              "profileImage": "NA",
              "profileName": "NA",
            },
          );
        }


      }









    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  String maskEmail(String email) {
    if (!_isValidEmail(email)) return email;
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${'*' * username.length}@$domain';
    }

    final visibleStart = 1;
    final visibleEnd = username.length > 4 ? 1 : 0;
    final maskedCount = username.length - visibleStart - visibleEnd;

    final maskedUsername = username.substring(0, visibleStart) +
        ('*' * maskedCount) +
        (visibleEnd > 0 ? username.substring(username.length - visibleEnd) : '');

    return '$maskedUsername@$domain';
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: 13, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "OTP",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  OtpTextField(
                    numberOfFields: 4,
                    alignment: Alignment.centerLeft,
                    borderColor:
                    error ? Colors.red : const Color(0xFFF0F0F0),
                    focusedBorderColor:
                    error ? Colors.red : const Color(0xFFF0F0F0),
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(10),
                    fillColor: const Color(0xFFF0F0F0),
                    filled: true,
                    fieldHeight: 60,
                    fieldWidth: 60,
                    showFieldAsBox: true,
                    onCodeChanged: (_) {
                      setState(() {
                        errorText = null;
                        error = false;
                      });
                    },
                    onSubmit: (String code) {
                      final otp = int.tryParse(code);
                      if (otp != null) enteredOTP = otp;
                    },
                  ),
                ],
              ),
              if (errorText != null && errorText!.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(errorText!, style: errorStyle),
              ],
              const SizedBox(height: 30),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "An OTP has been sent to\n",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.30,
                      ),
                    ),
                    TextSpan(
                      text: maskEmail(widget.enteredEmail),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: (_secondsRemaining > 0)
                          ? (_secondsRemaining / _initialCountdown)
                          : 0.0,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: (_canResend && !_isSending)
                        ? () async {
                      await _sendOtpAndStartTimer();
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFF0F0F0),
                      backgroundColor: const Color(0xFF308BF9),
                    ),
                    child: Text(
                      _canResend
                          ? "Resend OTP"
                          : "Resend available in $_secondsRemaining sec",
                      style: GoogleFonts.poppins(
                        color: (_canResend && !_isSending)
                            ? Colors.white
                            : const Color(0xFFB9B9B9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "By continuing, you agree to our ",
                          style: greyTextStyle),
                      TextSpan(text: "Terms and Conditions", style: linkTextStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ProfileBottomNavigation(
          onBack: () => Navigator.pop(context),
          onNext: isLoading ? null : validateOTP,
        ),
      ),
    );
  }
}
