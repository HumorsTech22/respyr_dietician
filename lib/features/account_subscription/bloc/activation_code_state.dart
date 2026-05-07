class ActivationCodeState {
  final String code;
  final bool isLoading;
  final bool isSuccess;
  final String? errorText;
  final String? message;
  final String? planName;
  final String? subscriptionEndDate;

  const ActivationCodeState({
    this.code = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorText,
    this.message,
    this.planName,
    this.subscriptionEndDate,
  });

  ActivationCodeState copyWith({
    String? code,
    bool? isLoading,
    bool? isSuccess,
    String? errorText,
    String? message,
    String? planName,
    String? subscriptionEndDate,
    bool clearError = false,
    bool clearMessage = false,
    bool clearPlanName = false,
    bool clearSubscriptionEndDate = false,
  }) {
    return ActivationCodeState(
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorText: clearError ? null : errorText ?? this.errorText,
      message: clearMessage ? null : message ?? this.message,
      planName: clearPlanName ? null : planName ?? this.planName,
      subscriptionEndDate: clearSubscriptionEndDate
          ? null
          : subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
}