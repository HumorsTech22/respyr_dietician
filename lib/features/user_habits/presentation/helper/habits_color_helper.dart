import 'dart:ui';

class HabitsColorHelper {
   Color getHabitColorDark(int index){
     switch(index){
       case 1: return const Color(0xFF90850E);
       case 2: return const Color(0xFF078C21);
       case 3: return const Color(0xFFB42525);
       case 4: return const Color(0xFF1D579F);
       case 5: return const Color(0xFF179B9B);


       default: return const Color(0xFF90850E);
     }
   }

   Color getHabitColorBg(int index){
     switch(index){
       case 1: return const Color(0xFFFCF8CF);
       case 2: return const Color(0xFFC9E7D0);
       case 3: return const Color(0xFFFFECEC);
       case 4: return const Color(0xFFE4F0FF);
       case 5: return const Color(0xFFE1F3F3);


       default: return const Color(0xFF90850E);
     }
   }
}