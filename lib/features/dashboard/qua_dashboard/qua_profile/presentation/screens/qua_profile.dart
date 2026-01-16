import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../../client-dashboard/extras/logout.dart';
import '../../../bloc/qua_dashboard_bloc.dart';
import '../../../bloc/qua_dashboard_event.dart';
import '../../../bloc/qua_dashboard_state.dart';

class QuaProfile extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const QuaProfile({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<QuaProfile> createState() => _QuaProfileState();
}

class _QuaProfileState extends State<QuaProfile> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuaDashboardBloc()
        ..add(QuaLoadClientAndDietitian(email: widget.clientProfileModel.email)),
      child: BlocConsumer<QuaDashboardBloc, QuaDashboardState>(
        listenWhen: (prev, curr) {
          final prevMsg = (prev is QuaDashboardReady) ? prev.errorMessage : null;
          final currMsg = (curr is QuaDashboardReady) ? curr.errorMessage : null;
          return currMsg != null && currMsg != prevMsg;
        },
        listener: (context, state) {



          if (state is QuaDashboardReady && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: const Color(0xFFDA5747),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {




          if (state is QuaDashboardLoading) {
            return const Scaffold(
              body: SafeArea(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (state is QuaDashboardError) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is QuaDashboardReady) {
            return _buildScreen(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, QuaDashboardReady state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text(
          "General",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
        bottom: state.isUpdating
            ? const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: LinearProgressIndicator(minHeight: 2, color: Colors.blue),
        )
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _CardContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoItem(label: "Name", value: widget.clientProfileModel.profileName),
                              const SizedBox(height: 28),
                              _InfoItem(label: "Gender", value: widget.clientProfileModel.gender),
                              const SizedBox(height: 28),
                              _InfoItem(label: "Age", value: widget.clientProfileModel.age),
                              const SizedBox(height: 28),
                              _InfoItem(label: "Height", value: "${widget.clientProfileModel.height} cm"),
                              const SizedBox(height: 28),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _InfoItem(
                                      label: "Weight",
                                      value: "${state.client.weight} kg",
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () => _showUpdateDialog(context, state),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF252525),
                                      minimumSize: const Size(40, 40),
                                      padding: EdgeInsets.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _CardContainer(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: () {
                                Logout().show(context, isLoggingOut: (bool isLoggingOut) {});
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFA1A1A1), width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2500)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/icons/ic_logout.svg",
                                    width: 18,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Logout",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFDA5747),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.10,
                                      letterSpacing: -0.24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "Respyr Metabolism 1.0",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA0A8B2),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ FIXED: uses bloc captured from parent context
  void _showUpdateDialog(BuildContext context, QuaDashboardReady state) {
    final bloc = context.read<QuaDashboardBloc>(); // ✅ IMPORTANT FIX
    final initialText = state.client.weight.trim();
    final controller = TextEditingController(text: initialText);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            final viewInsets = MediaQuery.of(dialogContext).viewInsets.bottom;

            return GestureDetector(
              onTap: () => FocusScope.of(dialogContext).unfocus(),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Update weight",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF252525),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      autofocus: false,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textInputAction: TextInputAction.done,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        hintText: "0.0",
                                      ),
                                      onChanged: (_) {
                                        if (errorText != null) setState(() => errorText = null);
                                      },
                                      onSubmitted: (_) => FocusScope.of(dialogContext).unfocus(),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Text("Kg", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),

                            if (errorText != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  errorText!,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFDA5747),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF308BF9),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () {
                                      final input = controller.text.trim();
                                      final weight = double.tryParse(input);

                                      const double minWeight = 20.0;
                                      const double maxWeight = 400.0;

                                      if (weight == null) {
                                        setState(() => errorText = "Enter a valid number");
                                        return;
                                      }
                                      if (weight < minWeight) {
                                        setState(() =>
                                        errorText = "Weight must be at least ${minWeight.toStringAsFixed(0)} kg");
                                        return;
                                      }
                                      if (weight > maxWeight) {
                                        setState(() =>
                                        errorText = "Weight must be below ${maxWeight.toStringAsFixed(0)} kg");
                                        return;
                                      }

                                      // ✅ NOW THIS WILL ALWAYS FIRE
                                      bloc.add(
                                        QuaUpdateWeight(
                                          profileId: state.client.profileId,
                                          weightKg: weight,
                                          email: state.client.email,
                                        ),
                                      );

                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text("Update", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: child,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
