import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Eixos padronizados para os gráficos de 30 dias.
abstract final class ChartAxis {
  static final _day = DateFormat('dd/MM');

  static FlTitlesData titles(
    BuildContext context,
    List<DateTime> dates, {
    required String Function(double) formatY,
  }) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          getTitlesWidget: (value, meta) {
            if (value == meta.max || value == meta.min) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                formatY(value),
                style: style,
                textAlign: TextAlign.right,
                maxLines: 1,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final i = value.round();
            final last = dates.length - 1;
            final show = i == 0 || i == last || (i % 7 == 0 && last - i >= 3);
            if (i < 0 || i > last || !show) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_day.format(dates[i]), style: style),
            );
          },
        ),
      ),
    );
  }

  static FlGridData grid(BuildContext context) => FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Theme.of(context).colorScheme.outlineVariant,
          strokeWidth: 1,
        ),
      );
}
