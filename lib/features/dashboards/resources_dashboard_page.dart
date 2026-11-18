import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/charts/history_line_chart.dart';
import '../../core/widgets/charts/trend_badge.dart';
import '../alerts/presentation/widgets/alert_card.dart';
import '../map/widgets/alerts_map_card.dart';
import '../territory/domain/indicator.dart';
import '../territory/domain/territory.dart';
import '../territory/domain/trend.dart';
import '../territory/state/territory_provider.dart';
import 'widgets/dashboard_shell.dart';
import 'widgets/indicator_grid.dart';

class ResourcesDashboardPage extends StatelessWidget {
  const ResourcesDashboardPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final thresholds = context.watch<TerritoryProvider>().thresholds;
    return DashboardShell(
      title: 'Recursos',
      embedded: embedded,
      builder: (context, data) {
        final dates = [for (final r in data.history) r.date];
        final water = Indicator.water.series(data.history);
        final energy = Indicator.energy.series(data.history);
        final waterTrend = Trend.of(water);
        final energyTrend = Trend.of(energy);
        final energyMean = meanOf(energy);
        final perCapita = water.isEmpty ? 0 : water.last * 1000 / Territory.population;
        final scheme = Theme.of(context).colorScheme;
        final related = context.watch<TerritoryProvider>().alertsOfTypes([
          ...Indicator.water.relatedTypes,
          ...Indicator.energy.relatedTypes,
        ]);
        final relatedTop = related.take(3).toList();

        return [
          DashboardSection(
            'Agora',
            subtitle: data.isReal
                ? 'Consumo diário sintético (não há API pública de consumo por município)'
                : 'Consumo diário do território',
          ),
          IndicatorGrid(
            indicators: const [Indicator.water, Indicator.energy],
            data: data,
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.groups_outlined, color: scheme.primary),
              title: Text('${perCapita.round()} litros por habitante hoje'),
              subtitle: Text(
                'Para ${Territory.population} moradores em ${Territory.regions.length} regiões.',
              ),
            ),
          ),
          const DashboardSection('Últimos 30 dias'),
          ChartCard(
            title: 'Consumo de água (m³/dia)',
            trailing: TrendBadge(trend: waterTrend),
            caption: 'Última semana: ${waterTrend.recentMean.round()} m³/dia '
                '(semana anterior: ${waterTrend.previousMean.round()}). '
                'Alta de ${thresholds.waterIncreasePct.round()}% ou mais sugere vazamento.',
            child: HistoryLineChart(
              values: water,
              dates: dates,
              color: scheme.primary,
              semanticsLabel:
                  'Gráfico de consumo de água dos últimos 30 dias, tendência ${waterTrend.direction.label}, ${waterTrend.summary}',
            ),
          ),
          const SizedBox(height: 12),
          ChartCard(
            title: 'Consumo de energia (MWh/dia)',
            trailing: TrendBadge(trend: energyTrend),
            caption: 'Média do período: ${energyMean.toStringAsFixed(1)} MWh. '
                'Dia ${((thresholds.energyPeakFactor - 1) * 100).round()}% acima da média gera alerta de pico.',
            child: HistoryLineChart(
              values: energy,
              dates: dates,
              color: scheme.tertiary,
              formatY: (v) => v.toStringAsFixed(0),
              semanticsLabel:
                  'Gráfico de consumo de energia dos últimos 30 dias, média ${energyMean.toStringAsFixed(1)} megawatt-hora, tendência ${energyTrend.direction.label}',
            ),
          ),
          const DashboardSection('No mapa'),
          AlertsMapCard(alerts: related),
          if (related.isNotEmpty) ...[
            const DashboardSection('Alertas ligados aos recursos'),
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
