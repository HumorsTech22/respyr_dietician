import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../client_login_manager/client_login_manager.dart';
import '../../routes/app_routes.dart';

class Logout {
  Future<void> show(
      BuildContext context, {
        required void Function(bool) isLoggingOut,
      }) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _ConfirmCard(
          title: 'Confirm Logout',
          message: 'Are you sure you want to logout?',
          cancelText: 'Cancel',
          confirmText: 'Logout',
          onCancel: () => Navigator.pop(ctx, false),
          onConfirm: () => Navigator.pop(ctx, true),
        ),
      ),
    );

    if (confirm != true) return;

    isLoggingOut(true);
    bool isCleared = false;

    try {
      isCleared = await ClientLoginManager().clearClientProfile();
    } catch (_) {
      isCleared = false;
    } finally {
      isLoggingOut(false);
    }

    if (!context.mounted) return;

    if (isCleared) {
      context.go(AppRoutes.signInOptions);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }
}

/// A reusable custom "container" dialog card
class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.title,
    required this.message,
    required this.onCancel,
    required this.onConfirm,
    this.cancelText = 'Cancel',
    this.confirmText = 'OK',
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 12),
            color: Color(0x1A000000), // subtle shadow
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEFF4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.logout, color: Color(0xFF2F80ED)),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.24,
              letterSpacing: -0.34,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),

          // Actions
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF252525))),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
