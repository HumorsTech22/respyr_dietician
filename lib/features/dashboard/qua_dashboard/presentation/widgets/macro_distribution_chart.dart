import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/helpers/macro_colors.dart';

import '../../../../../core/size/get_height.dart';

class MacroDistributionChart extends StatelessWidget {
  final double carbs;
  final double fats;
  final double protein;
  final double fibre;

  const MacroDistributionChart({
    super.key,
    required this.carbs,
    required this.fats,
    required this.protein,
    required this.fibre,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rh(context: context, px: 145),
      width: double.infinity,
      child: CustomPaint(
        painter: _MacroChartPainter(
          context: context,
          carbs: carbs,
          fats: fats,
          protein: protein,
          fibre: fibre,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MacroChartPainter extends CustomPainter {
  final BuildContext context;
  final double carbs;
  final double fats;
  final double protein;
  final double fibre;

  _MacroChartPainter({
    required this.context,
    required this.carbs,
    required this.fats,
    required this.protein,
    required this.fibre,
  });

  double r(double px) => rh(context: context, px: px);

  @override
  void paint(Canvas canvas, Size size) {
    const int totalBars = 76;

    final bool hasMacroData =
        carbs > 0 || fats > 0 || protein > 0 || fibre > 0;

    final double chartStartX = 0;
    final double totalChartWidth = size.width;

    final double barWidth = r(3);
    final double gap =
        (totalChartWidth - (totalBars * barWidth)) / (totalBars - 1);

    final double topLabelY = r(0);
    final double barTop = r(10);
    final double barHeight = r(83);
    final double bottomLabelY = barTop + barHeight + r(8);

    final topTextStyle = GoogleFonts.poppins(
      fontSize: r(8),
      color: const Color(0xFF535359),
      fontWeight: FontWeight.w400,
      height: 1.10,
      letterSpacing: -r(0.16),
    );

    for (final value in [0, 20, 40, 60, 80, 100]) {
      final x = chartStartX + (totalChartWidth * value / 100);

      final tp = TextPainter(
        text: TextSpan(text: '$value', style: topTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      double labelX = x - tp.width / 2;

      if (value == 0) labelX = chartStartX;
      if (value == 100) {
        labelX = chartStartX + totalChartWidth - tp.width;
      }

      tp.paint(canvas, Offset(labelX, topLabelY));
    }

    final int carbsBars =
    ((carbs / 100) * totalBars).round().clamp(0, totalBars);

    final int fatsBars =
    ((fats / 100) * totalBars).round().clamp(0, totalBars - carbsBars);

    final int proteinBars = ((protein / 100) * totalBars)
        .round()
        .clamp(0, totalBars - carbsBars - fatsBars);

    final Paint emptyPaint = Paint()..color = const Color(0xFFE1E6ED);

    final Paint carbPaint =
    hasMacroData ? MacroColors.getPaint("Carbs") : emptyPaint;
    final Paint fatPaint =
    hasMacroData ? MacroColors.getPaint("Fats") : emptyPaint;
    final Paint proteinPaint =
    hasMacroData ? MacroColors.getPaint("Protein") : emptyPaint;
    final Paint fibrePaint =
    hasMacroData ? MacroColors.getPaint("Fibre") : emptyPaint;

    for (int i = 0; i < totalBars; i++) {
      Paint paint;

      if (!hasMacroData) {
        paint = emptyPaint;
      } else if (i < carbsBars) {
        paint = carbPaint;
      } else if (i < carbsBars + fatsBars) {
        paint = fatPaint;
      } else if (i < carbsBars + fatsBars + proteinBars) {
        paint = proteinPaint;
      } else {
        paint = fibrePaint;
      }

      final x = chartStartX + i * (barWidth + gap);

      canvas.drawRect(
        Rect.fromLTWH(x, barTop, barWidth, barHeight),
        paint,
      );
    }

    if (!hasMacroData) return;

    final labels = [
      _MacroLabel(
        centerX: chartStartX + (totalChartWidth * (carbs / 2) / 100),
        percentage: '${carbs.round()}%',
        name: 'Carbs',
        color: MacroColors.getColor("Carbs"),
      ),
      _MacroLabel(
        centerX: chartStartX + (totalChartWidth * (carbs + fats / 2) / 100),
        percentage: '${fats.round()}%',
        name: 'Fats',
        color: MacroColors.getColor("Fats"),
      ),
      _MacroLabel(
        centerX: chartStartX +
            (totalChartWidth * (carbs + fats + protein / 2) / 100),
        percentage: '${protein.round()}%',
        name: 'Protein',
        color: MacroColors.getColor("Protein"),
      ),
      _MacroLabel(
        centerX: chartStartX +
            (totalChartWidth * (carbs + fats + protein + fibre / 2) / 100),
        percentage: '${fibre.round()}%',
        name: 'Fibre',
        color: MacroColors.getColor("Fibre"),
      ),
    ];

    _drawSmartBottomLabels(
      canvas,
      size,
      labels,
      bottomLabelY,
    );
  }

  void _drawSmartBottomLabels(
      Canvas canvas,
      Size size,
      List<_MacroLabel> labels,
      double baseY,
      ) {
    final placed = <Rect>[];

    for (final label in labels) {
      final tp = _buildBottomTextPainter(
        percentage: label.percentage,
        name: label.name,
        color: label.color,
      );

      double x = label.centerX - tp.width / 2;

      if (x < 0) x = 0;
      if (x + tp.width > size.width) {
        x = size.width - tp.width;
      }

      double y = baseY;
      Rect rect = Rect.fromLTWH(x, y, tp.width, tp.height);

      bool moved = true;

      while (moved) {
        moved = false;

        for (final oldRect in placed) {
          if (rect.overlaps(oldRect.inflate(r(4)))) {
            y = oldRect.bottom + r(4);
            rect = Rect.fromLTWH(x, y, tp.width, tp.height);
            moved = true;
          }
        }
      }

      tp.paint(canvas, Offset(x, y));
      placed.add(rect);
    }
  }

  TextPainter _buildBottomTextPainter({
    required String percentage,
    required String name,
    required Color color,
  }) {
    return TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$percentage ',
            style: GoogleFonts.poppins(
              color: const Color(0xFF52535C),
              fontSize: r(10),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: name,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: r(10),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  bool shouldRepaint(covariant _MacroChartPainter oldDelegate) {
    return oldDelegate.carbs != carbs ||
        oldDelegate.fats != fats ||
        oldDelegate.protein != protein ||
        oldDelegate.fibre != fibre;
  }
}

class _MacroLabel {
  final double centerX;
  final String percentage;
  final String name;
  final Color color;

  _MacroLabel({
    required this.centerX,
    required this.percentage,
    required this.name,
    required this.color,
  });
}