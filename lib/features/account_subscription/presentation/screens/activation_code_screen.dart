import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/account_subscription/bloc/activation_code_bloc.dart';
import 'package:respyr_dietitian/features/account_subscription/bloc/activation_code_event.dart';
import 'package:respyr_dietitian/features/account_subscription/bloc/activation_code_state.dart';
import 'package:respyr_dietitian/features/account_subscription/services/activate_coupon_service.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class ActivationCodeScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const ActivationCodeScreen({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<ActivationCodeScreen> createState() => _ActivationCodeScreenState();
}

class _ActivationCodeScreenState extends State<ActivationCodeScreen> {
  late final TextEditingController _codeController;
  late final ActivationCodeBloc _bloc;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _bloc = ActivationCodeBloc(
      service: ActivateCouponService(),
      profileId: widget.clientProfileModel.profileId,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _bloc.close();
    super.dispose();
  }

  String _formatPlanMessage({
    required String? planName,
    required String? subscriptionEndDate,
  }) {
    final safePlanName = (planName == null || planName.trim().isEmpty)
        ? "Your plan"
        : "Your ${planName.trim()}";

    String formattedDate = "";

    if (subscriptionEndDate != null && subscriptionEndDate.trim().isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(subscriptionEndDate);
        formattedDate = DateFormat("MMMM d, yyyy").format(parsedDate);
      } catch (_) {
        formattedDate = subscriptionEndDate;
      }
    }

    if (formattedDate.isNotEmpty) {
      return "$safePlanName is now active. Continue your journey with full access until $formattedDate.";
    }

    return "$safePlanName is now active. Continue your journey with full access.";
  }

  Future<void> _showSuccessDialog({
    required String? planName,
    required String? subscriptionEndDate,
  }) async {
    final popupMessage = _formatPlanMessage(
      planName: planName,
      subscriptionEndDate: subscriptionEndDate,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 20),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: rh(context: context, px: 20),
              right: rh(context: context, px: 20),
              top: rh(context: context, px: 47),
              bottom: rh(context: context, px: 20),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                rh(context: context, px: 24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Activation Successful",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.50,
                  ),
                ),
                SizedBox(height: rh(context: context, px: 25)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    popupMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: rh(context: context, px: 40)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go(
                      AppRoutes.clientDashboard,
                      extra: widget.clientProfileModel,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 16,), horizontal: rh(context: context, px: 50)),
                    backgroundColor: const Color(0xFF308BF9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rh(context: context, px: 50)),
                    ),
                  ),
                  child: Text(
                    "Ok",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rh(context: context, px: 15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
      borderSide: BorderSide.none,
    );

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ActivationCodeBloc, ActivationCodeState>(
        listener: (context, state) async {
          if (state.isSuccess && !_dialogShown) {
            _dialogShown = true;
            await _showSuccessDialog(
              planName: state.planName,
              subscriptionEndDate: state.subscriptionEndDate,
            );
          }
        },
        child: BlocBuilder<ActivationCodeBloc, ActivationCodeState>(
          builder: (context, state) {
            final String? errorText = state.errorText;

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                bottom: false,
                child: RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: rh(context: context, px: 47)),
                        Text(
                          "Enter Activation Code",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 34),
                            fontWeight: FontWeight.w400,
                            height: 1.21,
                            letterSpacing: -rh(context: context, px: 2.04),
                          ),
                        ),
                        SizedBox(height: rh(context: context, px: 10)),
                        Text(
                          "Enter the activation code provided by your trainer to continue using Respyr.",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: rh(context: context, px: 15),
                            fontWeight: FontWeight.w300,
                            letterSpacing: -rh(context: context, px: 0.30),
                          ),
                        ),
                        SizedBox(height: rh(context: context, px: 24)),
                        RepaintBoundary(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 10),
                              vertical: rh(context: context, px: 10),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 10),
                              ),
                              border: Border.all(
                                color: errorText != null
                                    ? Colors.red
                                    : Colors.transparent,
                                width: rh(context: context, px: 1),
                              ),
                            ),
                            child: TextFormField(
                              controller: _codeController,
                              maxLines: 1,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                _dialogShown = false;
                                context
                                    .read<ActivationCodeBloc>()
                                    .add(ActivationCodeChanged(value));
                              },
                              onFieldSubmitted: (_) {
                                if (!state.isLoading) {
                                  context
                                      .read<ActivationCodeBloc>()
                                      .add(SubmitActivationCode());
                                }
                              },
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 15),
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter Your Code",
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: rh(context: context, px: 15),
                                  fontWeight: FontWeight.w300,
                                  height: 1.10,
                                  letterSpacing:
                                  -rh(context: context, px: 0.30),
                                ),
                                fillColor: const Color(0xFFF0F0F0),
                                filled: true,
                                isDense: true,
                                counterText: "",
                                disabledBorder: noBorder,
                                enabledBorder: noBorder,
                                focusedBorder: noBorder,
                                errorBorder: noBorder,
                                focusedErrorBorder: noBorder,
                                border: noBorder,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        if (errorText != null) ...[
                          SizedBox(height: rh(context: context, px: 8)),
                          Text(
                            errorText,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: rh(context: context, px: 12),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: RepaintBoundary(
                  child: ProfileBottomNavigation(
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onNext: () {
                      if (!state.isLoading) {
                        context
                            .read<ActivationCodeBloc>()
                            .add(SubmitActivationCode());
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}