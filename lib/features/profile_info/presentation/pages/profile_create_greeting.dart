import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class ProfileCreateGreeting extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const ProfileCreateGreeting({super.key, required this.clientProfileModel,});

  @override
  State<ProfileCreateGreeting> createState() => _ProfileCreateGreetingState();
}

class _ProfileCreateGreetingState extends State<ProfileCreateGreeting>
    with SingleTickerProviderStateMixin {
  static const Duration _totalDuration = Duration(milliseconds: 3500);
  static const Duration _startDelay = Duration(milliseconds: 500);

  late final AnimationController _controller;

  late final Animation<double> _topSectionMove;
  late final Animation<double> _statsFade;
  late final Animation<Offset> _blueShapeSlide;
  late final Animation<double> _bottomTextFade;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    _topSectionMove = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOutCubic),
      ),
    );

    _statsFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );

    _blueShapeSlide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _bottomTextFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.85, curve: Curves.easeIn),
      ),
    );

    _buttonFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(_startDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replayAnimation() {
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    final Widget topSectionChild = RepaintBoundary(
      child: Column(
        children: [
          const _ProfileAvatar(),
          SizedBox(height: rh(context: context, px: 24)),
          SizedBox(
            width: rh(context: context, px: 279),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                'Welcome ${widget.clientProfileModel.profileName}!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 34),
                  fontWeight: FontWeight.w400,
                  letterSpacing: rh(context: context, px: -2.04),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 8)),
          SizedBox(
            width: rh(context: context, px: 279),
            child: Text(
              'Your profile has been created',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                letterSpacing: rh(context: context, px: -0.30),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 32)),
          FadeTransition(
            opacity: _statsFade,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatColumn(title: 'Current BMI', value: CalculateBMI().call(double.parse(widget.clientProfileModel.weight), double.parse(widget.clientProfileModel.height)).toStringAsFixed(2)),
                Container(
                  height: rh(context: context, px: 35),
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 24),
                  ),
                ),
                _StatColumn(title: 'Current BMR', value: CalculateBMR().call(
                    weightKg: double.parse(widget.clientProfileModel.weight),
                    heightCm: double.parse(widget.clientProfileModel.height),
                    age: int.parse(widget.clientProfileModel.age),
                    gender: widget.clientProfileModel.gender).toStringAsFixed(2)),

              ],
            ),
          ),
        ],
      ),
    );

    final Widget blueCurveChild = RepaintBoundary(
      child: Container(
        width: rh(context: context, px: 628),
        height: rh(context: context, px: 628),
        decoration: const ShapeDecoration(
          color: Color(0xFF308BF9),
          shape: OvalBorder(),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedBuilder(
              animation: _buttonFade,
              builder: (context, child) {
                final double shiftUp =
                    lerpDouble(0, -rh(context: context, px: 35), _buttonFade.value) ?? 0;
                return Positioned(
                  top: rh(context: context, px: 110) + shiftUp,
                  child: Opacity(
                    opacity: _bottomTextFade.value,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: rh(context: context, px: 324),
                child: Text(
                  'Let’s get familiar with\nRespyr',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: rh(context: context, px: 25),
                    fontWeight: FontWeight.w600,
                    letterSpacing: rh(context: context, px: -1),
                    height: 1.2,
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _buttonFade,
              builder: (context, child) {
                final double buttonTop =
                    lerpDouble(
                      rh(context: context, px: 200),
                      rh(context: context, px: 170),
                      _buttonFade.value,
                    ) ??
                        rh(context: context, px: 170);

                return Positioned(
                  top: buttonTop,
                  child: Opacity(
                    opacity: _buttonFade.value,
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
                  },
                  borderRadius: BorderRadius.circular(
                    rh(context: context, px: 50),
                  ),
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    height: rh(context: context, px: 61),
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 20),
                      vertical: rh(context: context, px: 10),
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(
                          rh(context: context, px: 50),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Lets begin',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: rh(context: context, px: 13),
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: rh(context: context, px: 0.30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _topSectionMove,
              child: topSectionChild,
              builder: (context, child) {
                final double topPadding = lerpDouble(
                  size.height * 0.35,
                  size.height * 0.10,
                  _topSectionMove.value,
                ) ??
                    size.height * 0.10;
        
                return Positioned(
                  top: topPadding,
                  left: 0,
                  right: 0,
                  child: child!,
                );
              },
            ),
            AnimatedBuilder(
              animation: _blueShapeSlide,
              child: blueCurveChild,
              builder: (context, child) {
                final double dy = _blueShapeSlide.value.dy;
                final double visibleHeight = size.height * 0.45;
                final double topPos = size.height - (visibleHeight * (1 - dy));
        
                return Positioned(
                  left: (size.width - rh(context: context, px: 628)) / 2,
                  top: topPos,
                  child: child!,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        child: Visibility(
          visible: false,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _replayAnimation,
            child: const Icon(Icons.refresh, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rh(context: context, px: 120),
      height: rh(context: context, px: 120),
      decoration: const ShapeDecoration(
        color: Color(0xFFF0F0F0),
        shape: OvalBorder(),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;

  const _StatColumn({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: rh(context: context, px: 10),
            color: const Color(0xFF535359),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: rh(context: context, px: 4)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: rh(context: context, px: 16),
            color: const Color(0xFF252525),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}