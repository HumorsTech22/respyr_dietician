import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckAbortSheet {
  static void show({
    required BuildContext context,
    VoidCallback? onTakeTextClick,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return _CoolingDownContent(onTakeTextClick: onTakeTextClick);
      },
    );
  }
}

class _CoolingDownContent extends StatefulWidget {
  final VoidCallback? onTakeTextClick;

  const _CoolingDownContent({this.onTakeTextClick});

  @override
  State<_CoolingDownContent> createState() => _CoolingDownContentState();
}

class _CoolingDownContentState extends State<_CoolingDownContent> {
  static const String _keyCancelOrDisconnectTime = 'cancel_or_disconnect_time';

  // ✅ single source of truth
  static const int _cooldownSeconds = 35;

  int _remainingSeconds = _cooldownSeconds;
  bool _isButtonEnabled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
  }

  Future<void> _calculateRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTimeStr = prefs.getString(_keyCancelOrDisconnectTime);

    if (storedTimeStr != null) {
      final storedTime = DateTime.tryParse(storedTimeStr);
      if (storedTime != null) {
        final now = DateTime.now();
        final diff = now.difference(storedTime).inSeconds;
        final remaining = _cooldownSeconds - diff;

        if (remaining > 0) {
          setState(() {
            _remainingSeconds = remaining;
            _isButtonEnabled = false;
          });
          _startTimer();
          return;
        }
      }
    }

    setState(() {
      _remainingSeconds = 0;
      _isButtonEnabled = true;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isButtonEnabled = true;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, size: 24, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _isButtonEnabled
                ? SvgPicture.asset(
              "assets/images/device_connection/device_ready.svg",
            )
                : SvgPicture.asset(
              "assets/images/device_connection/device_error.svg",
            ),
            const SizedBox(height: 10),
            Text(
              _isButtonEnabled ? "Device is Ready Now" : "Device Cooling Down",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isButtonEnabled
                  ? "Device is ready now. You can continue with the test."
                  : "You aborted the previous test. Respyr needs to cool down. Please wait for few seconds before starting the next test.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            if (_remainingSeconds > 0)
              Text(
                "$_remainingSeconds seconds",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  Navigator.of(context).pop();
                  widget.onTakeTextClick?.call();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF308BF9),
                  disabledBackgroundColor: const Color(0xFFA1A1A1),
                ),
                child: Text(
                  _isButtonEnabled ? "Start Test" : "Please wait...",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
