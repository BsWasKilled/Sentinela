import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum InfoBannerTone { neutral, warning, error }

/// Faixa de aviso reutilizável (offline, consentimento, decisão humana).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.tone = InfoBannerTone.neutral,
    this.action,
  });

  final IconData icon;
  final String text;
  final InfoBannerTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      InfoBannerTone.neutral => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      InfoBannerTone.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      InfoBannerTone.error => (scheme.errorContainer, scheme.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
            ),
          ),
          if (action != null) ...[const SizedBox(width: AppSpacing.sm), action!],
        ],
      ),
    );
  }
}
