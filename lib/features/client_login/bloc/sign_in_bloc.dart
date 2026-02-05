import 'dart:async';
import 'dart:math';
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
  }

  void _onEmailChanged(EmailChanged event, Emitter<SignInState> emit) {
    final trimmed = event.email.trim();
    final atIndex = trimmed.indexOf('@');
    List<String> filtered = [];

    if (trimmed.length > 2) {
      if (atIndex == -1 || atIndex == trimmed.length - 1) {
        filtered = allDomains;
      } else {
        final typedPart = trimmed.substring(atIndex + 1).toLowerCase();
        filtered = allDomains.where((d) => d.toLowerCase().contains(typedPart)).toList();
        if (filtered.isEmpty) filtered = allDomains;
      }
    }

    emit(state.copyWith(
      email: event.email,
      filteredDomains: filtered,
      errorText: null, // Clear error on type
    ));
  }

  void _onDomainSelected(DomainSelected event, Emitter<SignInState> emit) {
    String current = state.email.trim();
    int atIndex = current.indexOf('@');
    String newEmail = (atIndex == -1) ? current + event.domain : current.substring(0, atIndex) + event.domain;

    emit(state.copyWith(
      email: newEmail,
      filteredDomains: [],
      errorText: null,
    ));
  }

  Future<void> _onValidateAndSendOtp(ValidateAndSendOtp event, Emitter<SignInState> emit) async {
    // Throttling
    final now = DateTime.now();
    if (_lastClickTime != null && now.difference(_lastClickTime!) < const Duration(seconds: 1)) return;
    _lastClickTime = now;

    final email = state.email.trim();
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      emit(state.copyWith(errorText: "Please enter a valid email"));
      return;
    }

    emit(state.copyWith(isOtpSending: true, errorText: null));

    try {
      final generatedOtp = (1111 + Random.secure().nextInt(8889)).toString();
      final result = await sendOtpToEmail(email, generatedOtp);

      if (result['success'] == true) {
        final finalOtp = int.tryParse(result['otp']?.toString() ?? '') ?? int.parse(generatedOtp);
        emit(state.copyWith(isOtpSending: false, isSuccess: true, otp: finalOtp));
      } else {
        emit(state.copyWith(isOtpSending: false, errorText: result['message']?.toString() ?? "Failed to send OTP"));
      }
    } catch (e) {
      emit(state.copyWith(isOtpSending: false, errorText: "Connection error. Please try again."));
    }
  }
}
