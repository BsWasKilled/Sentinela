import 'package:flutter/material.dart';

import '../../../features/territory/domain/trend.dart';

/// Seta e variação percentual ("+24% em 7 dias").
class TrendBadge extends StatelessWidget {
  const TrendBadge({super.key, required this.trend, this.upIsBad = true});

  final Trend trend;

  /// Para chuva ou consumo, alta é ruim; para umidade, é o contrário.
  final bool upIsBad;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (trend.direction) {
      TrendDirection.up => (
          Icons.trending_up,
          upIsBad ? scheme.error : scheme.primary,
        ),
      TrendDirection.down => (
          Icons.trending_down,
          upIsBad ? scheme.primary : scheme.error,
        ),
      TrendDirection.stable => (Icons.trending_flat, scheme.onSurfaceVariant),
    };
    return Semantics(
      label: 'Tendência ${trend.direction.label}, ${trend.summary}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              trend.summary,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
