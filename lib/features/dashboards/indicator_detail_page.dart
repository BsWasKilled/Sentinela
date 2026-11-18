import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/charts/history_bar_chart.dart';
import '../../core/widgets/charts/history_line_chart.dart';
import '../../core/widgets/charts/trend_badge.dart';
import '../../core/widgets/human_decision_banner.dart';
import '../../core/widgets/state_message.dart';
import '../alerts/presentation/widgets/alert_card.dart';
import '../territory/domain/indicator.dart';
import '../territory/domain/trend.dart';
import '../territory/state/territory_provider.dart';
import 'widgets/dashboard_shell.dart';

/// Detalhe de um indicador: série de 30 dias, tendência, método e alertas.
class IndicatorDetailPage extends StatelessWidget {
  const IndicatorDetailPage({super.key, required this.indicator});

  final Indicator indicator;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TerritoryProvider>();
    final data = state.dataset;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(indicator.label)),
        body: const Center(
          child: StateMessage(
            icon: Icons.cloud_off,
            title: 'Sem dados para este indicador',
            message: 'Atualize os dados na tela inicial.',
          ),
        ),
      );
    }

    final series = indicator.series(data.history);
    final dates = [for (final r in data.history) r.date];
    final trend = Trend.of(series);
    final current = series.isEmpty ? 0.0 : series.last;
    final periodValue = indicator.isCumulative
        ? series.fold(0.0, (a, b) => a + b)
        : meanOf(series);
    final maxValue = series.isEmpty ? 0.0 : series.reduce((a, b) => a > b ? a : b);
    final related = state.alertsOfTypes(indicator.relatedTypes);
    final upIsBad = indicator != Indicator.humidity;

    return Scaffold(
      appBar: AppBar(title: Text(indicator.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Icon(indicator.icon, size: 36, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: indicator.format(current),
                        style: theme.textTheme.headlineMedium,
                        children: [
                          TextSpan(
                            text: ' ${indicator.unit}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Leitura de hoje',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              TrendBadge(trend: trend, upIsBad: upIsBad),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Fact(
                  label: indicator.isCumulative ? 'Total em 30 dias' : 'Média de 30 dias',
                  value: '${indicator.format(periodValue)} ${indicator.unit}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Fact(
                  label: 'Maior valor',
                  value: '${indicator.format(maxValue)} ${indicator.unit}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChartCard(
            title: 'Últimos ${series.length} dias',
            caption: 'Semana atual: média de ${indicator.format(trend.recentMean)} ${indicator.unit}; '
                'semana anterior: ${indicator.format(trend.previousMean)} ${indicator.unit}.',
            child: indicator.isCumulative
                ? HistoryBarChart(
                    values: series,
                    dates: dates,
                    color: scheme.primary,
                    semanticsLabel: 'Gráfico de ${indicator.label} dos últimos ${series.length} dias',
                  )
                : HistoryLineChart(
                    values: series,
                    dates: dates,
                    color: scheme.primary,
                    formatY: (v) => indicator.format(v),
                    semanticsLabel: 'Gráfico de ${indicator.label} dos últimos ${series.length} dias',
                  ),
          ),
          const DashboardSection('Como a tendência é calculada'),
          const Text(
            'Comparamos a média dos últimos 7 dias com a média dos 7 dias '
            'anteriores. Variações de até 10% são tratadas como estáveis. '
            'Os alertas combinam essa tendência com limiares sobre a leitura atual.',
          ),
          const DashboardSection('Quando não confiar'),
          _Bullet(indicator.reliabilityNote),
          _Bullet(
            data.isStale
                ? 'Estes dados vêm do cache e podem estar desatualizados.'
                : data.isReal && (indicator == Indicator.water || indicator == Indicator.energy)
                    ? 'Consumo sintético para fins acadêmicos; só o clima é real.'
                    : data.isReal
                        ? 'Fonte: ${data.source}, previsão por modelo numérico; não substitui estação local.'
                        : 'Dados sintéticos para fins acadêmicos; não refletem medições reais.',
          ),
          const _Bullet('Série curta (30 dias): não captura sazonalidade anual.'),
          DashboardSection(
            related.isEmpty ? 'Nenhum alerta ligado a este indicador' : 'Alertas ligados a este indicador',
          ),
          for (final a in related)
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
          const SizedBox(height: 8),
          const HumanDecisionBanner(),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
