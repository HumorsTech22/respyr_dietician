import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

import '../../../core/utils/date_helper.dart';
import '../../../features/menu/presentation/pages/settings.dart';
import '../../data/bloc/client_bloc.dart';
import '../../extras/meal_type_helper.dart';

class DashboardAppbar extends StatelessWidget {

  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianDetailModel;
  final bool isDefaultColor;
  const DashboardAppbar({super.key, required this.clientProfileModel,  this.isDefaultColor=false, required this.dietitianDetailModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi ${clientProfileModel.profileName}",
              style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.30,
                  height: 1.2
              ),
            ),
            Text(DateHelper().getGreeting(),
              style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  height: 1.2
              ),
            )
          ],
        ),
        Spacer(),
        IconButton(
            onPressed: (){},
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor:isDefaultColor? Colors.white : ThemeHelper().getThemeDarkColor(),
            ),
            icon: SvgPicture.asset("assets/images/icons/ic_message.svg", color: isDefaultColor ? Color(0xFF308BF9) :Colors.white,)
        ),
        IconButton(
            onPressed: (){
              final clientBloc = context.read<ClientBloc>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: clientBloc, // reuse the existing instance
                    child: Settings(
                      clientProfileModel: clientProfileModel,              // your current arg
                      dietitianDetailModel: dietitianDetailModel,  // your current arg
                    ),
                  ),
                ),
              );


            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor:isDefaultColor? Colors.white : ThemeHelper().getThemeDarkColor(),
            ),
            icon: SvgPicture.asset("assets/images/icons/ic_profile.svg", color: isDefaultColor ?  Color(0xFF308BF9) : Colors.white,)
        ),
      ],
    );
  }
}
