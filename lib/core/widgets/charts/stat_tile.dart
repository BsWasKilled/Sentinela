import 'package:flutter/material.dart';

import '../../../features/territory/domain/trend.dart';
import 'trend_badge.dart';

/// Card com valor atual, unidade e tendência; toca para ver o detalhe.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.trend,
    this.upIsBad = true,
    this.onTap,
    this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Trend? trend;
  final bool upIsBad;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    final trendText =
        trend == null ? '' : ', tendência ${trend!.direction.label}';
    return Semantics(
      button: onTap != null,
      label: '$label: $value $unit$trendText',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: value,
                      style: theme.textTheme.headlineSmall,
                      children: [
                        TextSpan(
                          text: ' $unit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trend != null) ...[
                    const SizedBox(height: 6),
                    TrendBadge(trend: trend!, upIsBad: upIsBad),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
