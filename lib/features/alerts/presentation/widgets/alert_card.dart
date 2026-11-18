import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/territory_alert.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, required this.onTap});

  final TerritoryAlert alert;
  final VoidCallback onTap;

  static final _date = DateFormat('dd/MM HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert.priority.color;
    final place = alert.location == null ? '' : ' em ${alert.location}';
    return Semantics(
      button: true,
      onTap: onTap,
      label: '${alert.type.label}$place, ${alert.priority.fullLabel}, '
          'confiança ${(alert.confidence * 100).round()} por cento. Toque para ver detalhes.',
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(alert.type.icon, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(alert.type.label, style: theme.textTheme.titleMedium),
                            ),
                            Text(alert.priority.fullLabel,
                                style: theme.textTheme.labelLarge?.copyWith(color: color)),
                          ]),
                          const SizedBox(height: 8),
                          Text(
                            [
                              if (alert.location != null) alert.location!,
                              _date.format(alert.generatedAt),
                              'confiança ${(alert.confidence * 100).round()}%',
                            ].join(' · '),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.source.label,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
