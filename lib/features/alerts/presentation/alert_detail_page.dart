import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_column.dart';
import '../../../core/widgets/human_decision_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../map/widgets/alerts_map.dart';
import '../../territory/domain/indicator.dart';
import '../../territory/state/territory_provider.dart';
import '../domain/territory_alert.dart';

class AlertDetailPage extends StatelessWidget {
  const AlertDetailPage({super.key, required this.alert});

  final TerritoryAlert alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final color = alert.priority.color;
    final pct = (alert.confidence * 100).round();
    final indicators = Indicator.values
        .where((i) => i.relatedTypes.contains(alert.type))
        .toList();
    final hasData = context.select<TerritoryProvider, bool>((s) => s.dataset != null);

    return Scaffold(
      appBar: AppBar(title: Text(alert.type.label)),
      body: ContentColumn(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(alert.type.icon, color: color, size: 30),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alert.priority.fullLabel,
                            style: theme.textTheme.titleLarge?.copyWith(color: color)),
                        const SizedBox(height: 2),
                        Text(
                          [
                            alert.source.label,
                            if (alert.location != null) alert.location!,
                            DateFormat('dd/MM/yyyy HH:mm').format(alert.generatedAt),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: 'Nível de confiança de $pct por cento',
            child: ExcludeSemantics(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Nível de confiança', style: theme.textTheme.titleSmall),
                          ),
                          Text('$pct%', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: alert.confidence, minHeight: 8),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _confidenceHint(alert.confidence),
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SectionHeader('Por que este alerta?'),
          ...alert.evidence.map((e) => _Bullet(e, icon: Icons.check_circle_outline)),
          const SectionHeader('Limitações'),
          ...alert.limitations.map((e) => _Bullet(e, icon: Icons.info_outline)),
          const SectionHeader('Ação sugerida'),
          Text(alert.suggestedAction),
          if (alert.latitude != null || alert.location != null) ...[
            const SectionHeader('No mapa'),
            AlertsMap(alerts: [alert], height: 180),
          ],
          if (indicators.isNotEmpty && hasData) ...[
            const SectionHeader('Indicadores relacionados'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final ind in indicators)
                  ActionChip(
                    avatar: Icon(ind.icon, size: 18),
                    label: Text(ind.label),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.indicatorDetail,
                      arguments: ind,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const HumanDecisionBanner(),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.method),
            icon: const Icon(Icons.help_outline, size: 18),
            label: const Text('Como os alertas são gerados'),
          ),
        ],
      ),
    );
  }

  static String _confidenceHint(double c) {
    if (c >= 0.8) return 'Vários sinais independentes concordam.';
    if (c >= 0.6) return 'Parte dos sinais confirma; vale checar no local.';
    return 'Poucos sinais ou sem verificação: trate como indício.';
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
