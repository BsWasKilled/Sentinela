import 'package:flutter/material.dart';

class RankedEntry {
  const RankedEntry(this.label, this.value, {this.icon});

  final String label;
  final int value;
  final IconData? icon;
}

/// Barras horizontais ordenadas para contagens por categoria.
class RankedBars extends StatelessWidget {
  const RankedBars({
    super.key,
    required this.entries,
    required this.color,
    this.emptyMessage = 'Sem registros.',
  });

  final List<RankedEntry> entries;
  final Color color;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...entries]..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sorted.isEmpty ? 0 : sorted.first.value;
    if (maxValue == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          emptyMessage,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Column(
      children: [
        for (final e in sorted)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Semantics(
              label: '${e.label}: ${e.value}',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    if (e.icon != null) ...[
                      Icon(e.icon, size: 18, color: color),
                      const SizedBox(width: 8),
                    ],
                    SizedBox(
                      width: 120,
                      child: Text(
                        e.label,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value / maxValue,
                          minHeight: 10,
                          color: color,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
