import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Lista rolável centralizada e limitada em largura (responsividade).
class ContentColumn extends StatelessWidget {
  const ContentColumn({
    super.key,
    required this.children,
    this.padding = AppSpacing.page,
    this.onRefresh,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: padding,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
