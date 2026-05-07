import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/send_otp_email.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final List<String> allDomains = [
    "@gmail.com", "@yahoo.com", "@hotmail.com", "@outlook.com",
    "@live.com", "@msn.com", "@icloud.com", "@aol.com",
    "@protonmail.com", "@yandex.com",
  ];

  DateTime? _lastClickTime;

  SignInBloc() : super(SignInState()) {
    on<EmailChanged>(_onEmailChanged);
    on<DomainSelected>(_onDomainSelected);
    on<ValidateAndSendOtp>(_onValidateAndSendOtp);
    on<ResetSignInState>(_onResetSignInState);
  }

  void _onEmailChanged(EmailChanged event, Emitter<SignInState> emit) {
    debugPrint("📧 EmailChanged: ${event.email}");

    final trimmed = event.email.trim();
    final atIndex = trimmed.indexOf('@');
    List<String> filtered = [];

    if (trimmed.length > 2) {
      if (atIndex == -1 || atIndex == trimmed.length - 1) {
        filtered = allDomains;
      } else {
        final typedPart = trimmed.substring(atIndex + 1).toLowerCase();
        filtered = allDomains
            .where((d) => d.toLowerCase().contains(typedPart))
            .toList();
        if (filtered.isEmpty) filtered = allDomains;
      }
    }

    emit(state.copyWith(
      email: event.email,
      filteredDomains: filtered,
      clearErrorText: true,
      isSuccess: false,
      clearOtp: true,
    ));
  }

  void _onDomainSelected(DomainSelected event, Emitter<SignInState> emit) {
    debugPrint("🌐 DomainSelected: ${event.domain}");

    String current = state.email.trim();
    int atIndex = current.indexOf('@');
    String newEmail =
    (atIndex == -1) ? current + event.domain : current.substring(0, atIndex) + event.domain;

    emit(state.copyWith(
      email: newEmail,
      filteredDomains: [],
      clearErrorText: true,
      isSuccess: false,
      clearOtp: true,
    ));
  }

  void _onResetSignInState(ResetSignInState event, Emitter<SignInState> emit) {
    emit(state.copyWith(
      isSuccess: false,
      isOtpSending: false,
      clearErrorText: true,
      clearOtp: true,
    ));
  }

  Future<void> _onValidateAndSendOtp(
      ValidateAndSendOtp event,
      Emitter<SignInState> emit,
      ) async {
    debugPrint("➡️ ValidateAndSendOtp clicked");

    final now = DateTime.now();
    if (_lastClickTime != null &&
        now.difference(_lastClickTime!) < const Duration(seconds: 1)) {
      debugPrint("⏳ Click throttled");
      return;
    }
    _lastClickTime = now;

    final email = state.email.trim();
    debugPrint("📧 Validating email: $email");

    if (email.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email)) {
      emit(state.copyWith(
        errorText: "Please enter a valid email",
        isSuccess: false,
        clearOtp: true,
      ));
      return;
    }

    emit(state.copyWith(
      isOtpSending: true,
      clearErrorText: true,
      isSuccess: false,
      clearOtp: true,
    ));

    try {
      final generatedOtp =
      (1111 + Random.secure().nextInt(8889)).toString();

      final result = await sendOtpToEmail(email, generatedOtp);
      debugPrint("📩 API response: $result");

      if (result['success'] == true) {
        final finalOtp =
            int.tryParse(result['otp']?.toString() ?? '') ??
                int.parse(generatedOtp);

        emit(state.copyWith(
          isOtpSending: false,
          isSuccess: true,
          otp: finalOtp,
          clearErrorText: true,
        ));
      } else {
        final msg = result['message']?.toString() ?? "Failed to send OTP";

        emit(state.copyWith(
          isOtpSending: false,
          isSuccess: false,
          errorText: msg,
          clearOtp: true,
        ));
      }
    } catch (e, stack) {
      debugPrint("🔥 Exception while sending OTP: $e");
      debugPrint("$stack");

      emit(state.copyWith(
        isOtpSending: false,
        isSuccess: false,
        errorText: "Connection error. Please try again.",
        clearOtp: true,
      ));
    }
  }
}