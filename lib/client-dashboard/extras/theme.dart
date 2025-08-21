
import 'package:flutter/material.dart';

class DietTheme{

  ////
  Color morningStatusBarColor =Color(0xFFFFE29F);
  Color afternoonStatusBarColor =Color(0xFFFFD6A5);
  Color nightStatusBarColor =Color(0xFF8093F1);

  //// Morning Theme//////////////////////////////////////////////////////////////////////////
  Color morningDietDarkColor =Color(0xFFDA5747);

  LinearGradient morningHeroGradient = LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.50, 1.00),
    colors: [const Color(0xFFFFE29F), const Color(0xFFFFA99F)],
  );

  LinearGradient morningItemGradient = LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.50, 1.00),
    colors: [Colors.white, Colors.white, Colors.white.withValues(alpha: 0)],
  );

  //// Afternoon Theme//////////////////////////////////////////////////////////////////////////
  Color afternoonDietDarkColor =Color(0xFFC9880F);

  LinearGradient afternoonHeroGradient =LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.50, 1.00),
    colors: [const Color(0xFFFFD6A5), const Color(0xFFFDCB6E)],
  );

  LinearGradient afternoonItemGradient = LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.50, 1.00),
    colors: [Colors.white, Colors.white, Colors.white.withValues(alpha: 0)],
  );


  //// Night Theme//////////////////////////////////////////////////////////////////////////
  Color nightDietDarkColor =Color(0xFF582699);

  LinearGradient nightHeroGradient =LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.50, 1.00),
    colors: [const Color(0xFF8093F1), const Color(0xFFB388EB)],
  );

  LinearGradient nightItemGradient =LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.50, 1.00),
    colors: [Colors.white, Colors.white, Colors.white.withValues(alpha: 0)],
  );


}