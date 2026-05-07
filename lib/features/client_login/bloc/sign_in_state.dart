class SignInState {
  final String email;
  final List<String> filteredDomains;
  final String? errorText;
  final bool isOtpSending;
  final bool isSuccess;
  final int? otp;

  SignInState({
    this.email = '',
    this.filteredDomains = const [],
    this.errorText,
    this.isOtpSending = false,
    this.isSuccess = false,
    this.otp,
  });

  SignInState copyWith({
    String? email,
    List<String>? filteredDomains,
    String? errorText,
    bool clearErrorText = false,
    bool? isOtpSending,
    bool? isSuccess,
    int? otp,
    bool clearOtp = false,
  }) {
    return SignInState(
      email: email ?? this.email,
      filteredDomains: filteredDomains ?? this.filteredDomains,
      errorText: clearErrorText ? null : (errorText ?? this.errorText),
      isOtpSending: isOtpSending ?? this.isOtpSending,
      isSuccess: isSuccess ?? this.isSuccess,
      otp: clearOtp ? null : (otp ?? this.otp),
    );
  }
}