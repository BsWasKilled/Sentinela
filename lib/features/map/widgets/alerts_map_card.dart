import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../alerts/domain/territory_alert.dart';
import 'alerts_map.dart';

/// Mapa compacto para os dashboards, com atalho para o mapa completo.
class AlertsMapCard extends StatelessWidget {
  const AlertsMapCard({
    super.key,
    required this.alerts,
    this.title = 'Mapa dos alertas',
  });

  final List<TerritoryAlert> alerts;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                  icon: const Icon(Icons.open_in_full, size: 16),
                  label: const Text('Abrir mapa'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AlertsMap(alerts: alerts, height: 200),
            const SizedBox(height: 10),
            const PriorityLegend(),
            if (alerts.isEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Nenhum alerta para marcar no mapa.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
