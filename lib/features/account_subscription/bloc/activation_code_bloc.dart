import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/account_subscription/services/activate_coupon_service.dart';
import 'activation_code_event.dart';
import 'activation_code_state.dart';

class ActivationCodeBloc
    extends Bloc<ActivationCodeEvent, ActivationCodeState> {
  final ActivateCouponService service;
  final String profileId;

  ActivationCodeBloc({
    required this.service,
    required this.profileId,
  }) : super(const ActivationCodeState()) {
    on<ActivationCodeChanged>(_onCodeChanged);
    on<SubmitActivationCode>(_onSubmitActivationCode);
  }

  void _onCodeChanged(
      ActivationCodeChanged event,
      Emitter<ActivationCodeState> emit,
      ) {
    emit(
      state.copyWith(
        code: event.code,
        clearError: true,
        clearMessage: true,
        clearPlanName: true,
        clearSubscriptionEndDate: true,
        isSuccess: false,
      ),
    );
  }

  Future<void> _onSubmitActivationCode(
      SubmitActivationCode event,
      Emitter<ActivationCodeState> emit,
      ) async {
    final code = state.code.trim();

    if (code.isEmpty) {
      emit(
        state.copyWith(
          errorText: "Please enter activation code",
          isLoading: false,
          isSuccess: false,
          clearMessage: true,
          clearPlanName: true,
          clearSubscriptionEndDate: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearMessage: true,
        clearPlanName: true,
        clearSubscriptionEndDate: true,
        isSuccess: false,
      ),
    );

    final result = await service.activateCoupon(
      profileId: profileId,
      couponCode: code,
    );

    if (result.status) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          message: result.message,
          planName: result.data?.planName,
          subscriptionEndDate: result.data?.subscriptionEndDate,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorText: result.message,
          clearMessage: true,
          clearPlanName: true,
          clearSubscriptionEndDate: true,
        ),
      );
    }
  }
}