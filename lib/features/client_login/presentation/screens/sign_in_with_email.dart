import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/widgets/terms_policy_links.dart';
import '../../../profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'email_otp.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  // All domains
  final List<String> allEmailTypes = [
    "@gmail.com",
    "@yahoo.com",
    "@hotmail.com",
    "@outlook.com",
    "@live.com",
    "@msn.com",
    "@icloud.com",
    "@aol.com",
    "@protonmail.com",
    "@yandex.com",
  ];

  // Filtered list (shown in chips)
  late List<String> filteredEmailTypes;

  String? errorText;
  bool isOtpSending = false;
  DateTime? _lastClickTime;

  @override
  void initState() {
    super.initState();
    filteredEmailTypes = List<String>.from(allEmailTypes);
  }

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
      ).whenComplete(() {
        setState(() {
          isOtpSending = false;
        });
      });
    }
  }

  bool isValidEmail(String email) {
    final emailRegex =
    RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  /// Filter chip list based on text after '@'
  void _filterDomains(String value) {
    final trimmed = value.trim();
    final atIndex = trimmed.indexOf('@');

    // If no '@' or nothing after '@' → show all
    if (atIndex == -1 || atIndex == trimmed.length - 1) {
      setState(() {
        filteredEmailTypes = List<String>.from(allEmailTypes);
      });
      return;
    }

    final typedDomainPart =
    trimmed.substring(atIndex + 1).toLowerCase(); // e.g. "gm"

    setState(() {
      filteredEmailTypes = allEmailTypes
          .where(
            (domain) =>
            domain.toLowerCase().contains(typedDomainPart), // "@gmail.com"
      )
          .toList();

      // If no match, still show all or empty? → choose show all for better UX
      if (filteredEmailTypes.isEmpty) {
        filteredEmailTypes = List<String>.from(allEmailTypes);
      }
    });
  }

  /// When user taps chip, apply that domain to email field
  void _onChipSelected(String domain) {
    String current = emailController.text.trim();
    String newEmail;

    int atIndex = current.indexOf('@');

    if (atIndex == -1) {
      // No '@' yet → append domain
      newEmail = current + domain;
    } else {
      // Replace everything after '@' with selected domain
      String namePart = current.substring(0, atIndex);
      newEmail = namePart + domain;
    }

    setState(() {
      emailController.text = newEmail;
      emailController.selection = TextSelection.fromPosition(
        TextPosition(offset: newEmail.length),
      );
      errorText = null;
      // After choosing a domain, reset chips to full list
      filteredEmailTypes = List<String>.from(allEmailTypes);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );

    final hintStyle = GoogleFonts.poppins(
      color: errorText==null ? Color(0xFF535359) : Colors.red,
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



    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child:
                SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Email",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: errorText != null
                            ? Colors.red
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/icons/ic_email.svg",
                          color: errorText==null ? Color(0xFF535359) : Colors.red,
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
                            onChanged: (value) {
                              if (errorText != null) {
                                setState(() => errorText = null);
                              }
                              _filterDomains(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (errorText != null && errorText!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(errorText!,
                        textAlign: TextAlign.left,
                        style: errorStyle
                    ),
                  ],

                  if (filteredEmailTypes.isNotEmpty && emailController.text.length>2)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 36,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Align(
                              alignment: Alignment.centerLeft,  // 👈 forces left alignment
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  filteredEmailTypes.length,
                                      (index) {
                                    final domain = filteredEmailTypes[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => _onChipSelected(domain),
                                        child: Chip(
                                          label: Text(
                                            domain,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF252525),
                                            ),
                                          ),
                                          backgroundColor: const Color(0xFFE1E6ED),
                                          side: BorderSide.none,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),



            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: IntrinsicHeight(
          child: Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              TermsPolicyWidgets().termsPolicyFooter(),
              ProfileBottomNavigation(
                onBack: () => Navigator.pop(context),
                onNext: _validateInput,
              ),
            ],
          ),
        ),
      ),


    );
  }
}
