import 'dart:ui';

class MacroColors {
  static const Color carb = Color(0xFF2A9D8F);
  static const Color fat = Color(0xFF3A86FF);
  static const Color protein = Color(0xFFE76F51);
  static const Color fibre = Color(0xFFF4A261);

  static const Color carbBg = Color(0x192A9D8F);
  static const Color fatBg = Color(0x193A86FF);
  static const Color proteinBg = Color(0x19E76F51);
  static const Color fibreBg = Color(0x19F4A261);

  static Color getColor(String macroType) {
    switch (macroType.toLowerCase()) {
      case "carbs":
      case "carb":
        return carb;

      case "fat":
      case "fats":
        return fat;

      case "protein":
      case "protien":
        return protein;

      case "fibre":
      case "fiber":
        return fibre;

      default:
        return carb;
    }
  }

  static Color getBgColor(String macroType) {
    switch (macroType.toLowerCase()) {
      case "carbs":
      case "carb":
        return carbBg;

      case "fat":
      case "fats":
        return fatBg;

      case "protein":
      case "protien":
        return proteinBg;

      case "fibre":
      case "fiber":
        return fibreBg;

      default:
        return carbBg;
    }
  }

  static Paint getPaint(String macroType) {
    return Paint()..color = getColor(macroType);
  }

  static Paint getBgPaint(String macroType) {
    return Paint()..color = getBgColor(macroType);
  }
}