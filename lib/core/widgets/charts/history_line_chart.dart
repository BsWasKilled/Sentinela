import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_axis.dart';

/// Linha de 30 dias com área preenchida.
class HistoryLineChart extends StatelessWidget {
  const HistoryLineChart({
    super.key,
    required this.values,
    required this.dates,
    required this.color,
    required this.semanticsLabel,
    this.fromZero = false,
    this.height = 180,
    this.formatY,
  });

  final List<double> values;
  final List<DateTime> dates;
  final Color color;
  final String semanticsLabel;
  final bool fromZero;
  final double height;
  final String Function(double)? formatY;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);
    final lo = values.reduce(min);
    final hi = values.reduce(max);
    final double pad =
        (hi - lo).abs() < 0.01 ? max(hi.abs() * 0.1, 1.0) : (hi - lo) * 0.15;
    final minY = fromZero ? 0.0 : (lo - pad);
    final maxY = hi + pad;
    final fmt = formatY ?? (v) => v.round().toString();

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: 0,
              maxX: (values.length - 1).toDouble(),
              gridData: ChartAxis.grid(context),
              borderData: FlBorderData(show: false),
              titlesData: ChartAxis.titles(context, dates, formatY: fmt),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < values.length; i++)
                      FlSpot(i.toDouble(), values[i]),
                  ],
                  isCurved: true,
                  curveSmoothness: 0.25,
                  preventCurveOverShooting: true,
                  color: color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
