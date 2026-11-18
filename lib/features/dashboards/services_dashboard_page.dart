import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/charts/ranked_bars.dart';
import '../../core/widgets/state_message.dart';
import '../alerts/domain/alert_type.dart';
import '../alerts/presentation/widgets/alert_card.dart';
import '../map/widgets/alerts_map_card.dart';
import '../territory/domain/territory.dart';
import '../territory/state/territory_provider.dart';
import 'widgets/dashboard_shell.dart';
import 'widgets/report_filters.dart';

/// Demanda por serviços: relatos dos cidadãos por região e por tipo.
class ServicesDashboardPage extends StatefulWidget {
  const ServicesDashboardPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ServicesDashboardPage> createState() => _ServicesDashboardPageState();
}

class _ServicesDashboardPageState extends State<ServicesDashboardPage> {
  String? _region;
  AlertType? _type;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Serviços',
      embedded: widget.embedded,
      builder: (context, data) {
        final state = context.watch<TerritoryProvider>();
        final filtered = state.reportsWhere(region: _region, type: _type);
        final impact = state.socialImpact;
        final scheme = Theme.of(context).colorScheme;

        // Os gráficos respeitam o outro filtro: por região mostra os tipos
        // daquela região, e por tipo mostra as regiões daquele tipo.
        final byRegion = [
          for (final r in Territory.regions)
            RankedEntry(
              r.name,
              state.reportsWhere(region: r.name, type: _type).length,
            ),
        ];
        final byType = [
          for (final t in AlertType.values)
            RankedEntry(
              t.label,
              state.reportsWhere(region: _region, type: t).length,
              icon: t.icon,
            ),
        ];

        return [
          const DashboardSection('Benefício social'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImpactRow(
                    icon: Icons.groups,
                    value: '${impact.residentsReached}',
                    label: 'moradores cobertos por alertas nas últimas 24h',
                    color: scheme.primary,
                  ),
                  const Divider(height: 24),
                  _ImpactRow(
                    icon: Icons.campaign,
                    value: '${impact.reportCount}',
                    label: 'relatos de cidadãos em '
                        '${impact.regionsWithReports} de ${Territory.regions.length} regiões',
                    color: scheme.tertiary,
                  ),
                ],
              ),
            ),
          ),
          const DashboardSection(
            'Relatos dos cidadãos',
            subtitle: 'Filtre por região e por tipo de relato',
          ),
          ReportFilters(
            region: _region,
            type: _type,
            onRegionChanged: (v) => setState(() => _region = v),
            onTypeChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: 12),
          AlertsMapCard(alerts: filtered, title: 'Relatos no mapa'),
          const SizedBox(height: 12),
          ChartCard(
            title: _type == null ? 'Relatos por região' : 'Relatos de ${_type!.label.toLowerCase()} por região',
            child: RankedBars(
              entries: byRegion,
              color: scheme.primary,
              emptyMessage: 'Nenhum relato com esse filtro.',
            ),
          ),
          const SizedBox(height: 12),
          ChartCard(
            title: _region == null ? 'Relatos por tipo' : 'Relatos por tipo em $_region',
            child: RankedBars(
              entries: byType,
              color: scheme.tertiary,
              emptyMessage: 'Nenhum relato com esse filtro.',
            ),
          ),
          DashboardSection(
            filtered.length == 1 ? '1 relato' : '${filtered.length} relatos',
          ),
          if (filtered.isEmpty)
            StateMessage(
              icon: Icons.inbox_outlined,
              title: state.reports.isEmpty
                  ? 'Nenhum relato registrado ainda'
                  : 'Nenhum relato com esse filtro',
              message: state.reports.isEmpty
                  ? 'Use "Registrar alerta" na tela inicial.'
                  : 'Tente outra região ou outro tipo.',
              actionLabel: 'Limpar filtros',
              onAction: state.reports.isEmpty
                  ? null
                  : () => setState(() {
                        _region = null;
                        _type = null;
                      }),
            )
          else
            for (final a in filtered)
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
        ];
      },
    );
  }
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$value $label',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
