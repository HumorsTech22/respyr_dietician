import 'dart:ui';

class MealColorHelper {
  Color getMealColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case "breakfast":
      case "snacks":
        return const Color(0xFFDA5747);

      case "lunch":
        return const Color(0xFFC9880F);

      case "dinner":
        return const Color(0xFF582699);

      default:
        return const Color(0xFFDA5747);
    }
  }
  Color getMealBgColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case "breakfast":
      case "snacks":
        return const Color(0xFFFFE0CD);

      case "lunch":
        return const Color(0xFFFFF48F);

      case "dinner":
        return const Color(0xFFEDDFFF);

      default:
        return const Color(0xFFDA5747);
    }
  }


}