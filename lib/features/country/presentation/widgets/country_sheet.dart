import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/country/data/model/country_model.dart';

class CountrySheet {
  static Future<CountryModel?> show({
    required BuildContext context,
  }) async {
    return await showModalBottomSheet<CountryModel>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rh(context: context, px: 24)),
        ),
      ),
      builder: (_) {
        return const _CountrySheetBody();
      },
    );
  }
}

class _CountrySheetBody extends StatefulWidget {
  const _CountrySheetBody();

  @override
  State<_CountrySheetBody> createState() => _CountrySheetBodyState();
}

class _CountrySheetBodyState extends State<_CountrySheetBody> {
  late Future<List<CountryModel>> _futureCountries;

  String? _selectedCountryCode;

  final List<CountryModel> _fallbackCountries = [
    CountryModel(
      id: 1,
      countryName: "India",
      countryCode: "india",
      telephoneCode: "+91",
    ),
    CountryModel(
      id: 2,
      countryName: "United States",
      countryCode: "usa",
      telephoneCode: "+1",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _futureCountries = _getCountries();
  }

  Future<List<CountryModel>> _getCountries() async {
    try {
      final response = await CountryService.fetchCountries();

      if (response.status && response.data.isNotEmpty) {
        return response.data;
      }

      return _fallbackCountries;
    } catch (_) {
      return _fallbackCountries;
    }
  }

  Future<void> _selectAndClose(CountryModel country) async {
    setState(() {
      _selectedCountryCode = country.countryCode;
    });

    await Future.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    Navigator.pop(context, country);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          rh(context: context, px: 24),
          rh(context: context, px: 44),
          rh(context: context, px: 24),
          rh(context: context, px: 60),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your country",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 34,
                fontWeight: FontWeight.w400,
                letterSpacing: -2.04,
              ),
            ),

            SizedBox(height: rh(context: context, px: 50)),

            FutureBuilder<List<CountryModel>>(
              future: _futureCountries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: rh(context: context, px: 30),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final countries = snapshot.data ?? _fallbackCountries;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: countries.length,
                  separatorBuilder: (_, __) {
                    return SizedBox(height: rh(context: context, px: 40));
                  },
                  itemBuilder: (context, index) {
                    final country = countries[index];

                    final bool isSelected =
                        _selectedCountryCode == country.countryCode;

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        rh(context: context, px: 12),
                      ),
                      splashColor: const Color(0xFF308BF9).withOpacity(0.08),
                      highlightColor: const Color(0xFF308BF9).withOpacity(0.04),
                      onTap: () {
                        _selectAndClose(country);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                country.countryName,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.10,
                                  letterSpacing: -0.30,
                                ),
                              ),
                            ),

                            Container(
                              width: rh(context: context, px: 25),
                              height: rh(context: context, px: 25),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: OvalBorder(
                                  side: BorderSide(
                                    width: rh(context: context, px: 1),
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: isSelected
                                        ? const Color(0xFF308BF9)
                                        : const Color(0xFF252525),
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                rh(context: context, px: 2),
                              ),
                              child: isSelected
                                  ? Container(
                                decoration: const ShapeDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0.50, -0.00),
                                    end: Alignment(0.50, 1.00),
                                    colors: [
                                      Color(0xFF308BF9),
                                      Color(0xFF8EC1FF),
                                    ],
                                  ),
                                  shape: OvalBorder(),
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}