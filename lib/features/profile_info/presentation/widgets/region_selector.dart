import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/text_input_decoration.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';

class RegionSelectorField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> regions;
  final String? selectedRegion;

  const RegionSelectorField({
    super.key,
    required this.controller,
    required this.regions,
    required this.selectedRegion,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      cursorColor: Colors.blue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        value = value?.trim();
        if (value == null || value.isEmpty) {
          return 'Location should not be empty';
        }
        return null;
      },
      onTap: () => _showRegionBottomSheet(context),
      decoration: buildInputDecoration(
        hintText: "Select Location",
        prefixIcon: "assets/images/common/profile_location_icon.svg",
        suffixIcon: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SvgPicture.asset(
            "assets/images/common/down_arrow_icon.svg",
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }

  void _showRegionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        String? tempSelection = selectedRegion;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Select Region",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...regions.map(
                    (region) => GestureDetector(
                      onTap: () {
                        setState(() => tempSelection = region);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color:
                              tempSelection == region
                                  ? const Color(0xFFE6F0FF)
                                  : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                tempSelection == region
                                    ? Colors.blue
                                    : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              tempSelection == region
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color:
                                  tempSelection == region
                                      ? Colors.blue
                                      : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              region,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (tempSelection != null) {
                          controller.text = tempSelection!;
                          context.read<ProfileCubit>().updateLocation(
                            tempSelection!,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        "Continue",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
