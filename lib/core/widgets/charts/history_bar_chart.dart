import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'chart_axis.dart';

/// Barras diárias de 30 dias (ex.: chuva).
class HistoryBarChart extends StatelessWidget {
  const HistoryBarChart({
    super.key,
    required this.values,
    required this.dates,
    required this.color,
    required this.semanticsLabel,
    this.height = 180,
    this.highlightFrom,
  });

  final List<double> values;
  final List<DateTime> dates;
  final Color color;
  final String semanticsLabel;
  final double height;

  /// Valores a partir deste limiar ganham destaque.
  final double? highlightFrom;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);
    final hi = values.reduce(max);
    final maxY = hi <= 0 ? 10.0 : hi * 1.15;
    final highlight = Theme.of(context).colorScheme.error;

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              alignment: BarChartAlignment.spaceBetween,
              gridData: ChartAxis.grid(context),
              borderData: FlBorderData(show: false),
              titlesData: ChartAxis.titles(
                context,
                dates,
                formatY: (v) => v.round().toString(),
              ),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        width: 5,
                        borderRadius: BorderRadius.circular(2),
                        color: highlightFrom != null && values[i] >= highlightFrom!
                            ? highlight
                            : color,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
