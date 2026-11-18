import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/charts/history_bar_chart.dart';
import '../../core/widgets/charts/history_line_chart.dart';
import '../../core/widgets/charts/trend_badge.dart';
import '../alerts/presentation/widgets/alert_card.dart';
import '../map/widgets/alerts_map_card.dart';
import '../territory/domain/indicator.dart';
import '../territory/domain/trend.dart';
import '../territory/state/territory_provider.dart';
import 'widgets/dashboard_shell.dart';
import 'widgets/indicator_grid.dart';

class ClimateDashboardPage extends StatelessWidget {
  const ClimateDashboardPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final thresholds = context.watch<TerritoryProvider>().thresholds;
    return DashboardShell(
      title: 'Clima',
      embedded: embedded,
      builder: (context, data) {
        final dates = [for (final r in data.history) r.date];
        final rain = Indicator.rain.series(data.history);
        final temp = Indicator.temperature.series(data.history);
        final rainTrend = Trend.of(rain);
        final tempTrend = Trend.of(temp);
        final rainTotal = rain.fold(0.0, (a, b) => a + b);
        final scheme = Theme.of(context).colorScheme;
        final related = context.watch<TerritoryProvider>().alertsOfTypes([
          ...Indicator.rain.relatedTypes,
          ...Indicator.temperature.relatedTypes,
          ...Indicator.wind.relatedTypes,
        ]);
        final relatedTop = related.take(3).toList();

        return [
          const DashboardSection('Agora', subtitle: 'Toque em um indicador para ver o histórico'),
          IndicatorGrid(
            indicators: const [
              Indicator.rain,
              Indicator.temperature,
              Indicator.humidity,
              Indicator.wind,
            ],
            data: data,
          ),
          const DashboardSection('Últimos 30 dias'),
          ChartCard(
            title: 'Chuva diária (mm)',
            trailing: TrendBadge(trend: rainTrend),
            caption: 'Total de ${rainTotal.round()} mm no período. '
                'Barras em vermelho passam do limiar de chuva intensa '
                '(${thresholds.rain24hMm.round()} mm).',
            child: HistoryBarChart(
              values: rain,
              dates: dates,
              color: scheme.primary,
              highlightFrom: thresholds.rain24hMm,
              semanticsLabel:
                  'Gráfico de chuva diária dos últimos 30 dias, total ${rainTotal.round()} milímetros, tendência ${rainTrend.direction.label}',
            ),
          ),
          const SizedBox(height: 12),
          ChartCard(
            title: 'Temperatura máxima (°C)',
            trailing: TrendBadge(trend: tempTrend),
            caption: 'Média recente de ${tempTrend.recentMean.toStringAsFixed(1)} °C. '
                'Limiar de onda de calor: ${thresholds.heatTempC.round()} °C.',
            child: HistoryLineChart(
              values: temp,
              dates: dates,
              color: scheme.tertiary,
              semanticsLabel:
                  'Gráfico de temperatura máxima dos últimos 30 dias, média recente ${tempTrend.recentMean.toStringAsFixed(1)} graus, tendência ${tempTrend.direction.label}',
            ),
          ),
          const DashboardSection('No mapa'),
          AlertsMapCard(alerts: related),
          if (related.isNotEmpty) ...[
            const DashboardSection('Alertas ligados ao clima'),
            for (final a in relatedTop)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(
                  alert: a,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.alertDetail,
                    arguments: a,
                  ),
                ),
              ),
          ],
        ];
      },
    );
  }
}
