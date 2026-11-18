import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_column.dart';
import '../../../core/widgets/state_message.dart';
import '../../territory/domain/territory_dataset.dart';
import '../../territory/state/territory_provider.dart';

/// Estrutura comum dos dashboards: carregamento, erro, vazio e offline.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.title,
    required this.builder,
    this.embedded = false,
  });

  final String title;

  /// Dentro das abas de Painéis: sem Scaffold nem AppBar próprios.
  final bool embedded;
  final List<Widget> Function(BuildContext context, TerritoryDataset data)
      builder;

  static final _stamp = DateFormat('dd/MM HH:mm');

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TerritoryProvider>();
    final data = state.dataset;

    final Widget body;
    if (state.status == LoadStatus.error) {
      body = Center(
        child: StateMessage(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar os dados',
          message: 'Verifique o armazenamento do aparelho e tente novamente.',
          onAction: () => context.read<TerritoryProvider>().load(),
        ),
      );
    } else if (data == null && (state.status == LoadStatus.loading || state.isRefreshing)) {
      body = const Center(child: CircularProgressIndicator());
    } else if (data == null) {
      body = Center(
        child: StateMessage(
          icon: Icons.cloud_off,
          title: 'Sem dados do território',
          message: 'Nenhum dado foi baixado ainda e não há cache salvo. '
              'Conecte-se e tente de novo.',
          onAction: () => context.read<TerritoryProvider>().refresh(),
        ),
      );
    } else {
      body = ContentColumn(
        onRefresh: state.refresh,
        children: [
          _SourceLine(data: data, offline: state.isOffline),
          const SizedBox(height: AppSpacing.md),
          ...builder(context, data),
        ],
      );
    }

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: state.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: body,
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.data, required this.offline});

  final TerritoryDataset data;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final stale = data.isStale || offline;
    return Row(
      children: [
        Icon(
          stale ? Icons.cloud_off : Icons.cloud_done_outlined,
          size: 16,
          color: stale ? theme.colorScheme.error : muted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            stale
                ? 'Dados do cache de ${DashboardShell._stamp.format(data.fetchedAt)} · ${data.history.length} dias'
                : 'Atualizado ${DashboardShell._stamp.format(data.fetchedAt)} · ${data.history.length} dias · ${data.source}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: stale ? theme.colorScheme.error : muted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Título de seção dentro de um dashboard.
class DashboardSection extends StatelessWidget {
  const DashboardSection(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Semantics(
        header: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card que envolve um gráfico com título e legenda curta.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.caption,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? caption;
  final Widget? trailing;

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
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
            if (caption != null) ...[
              const SizedBox(height: 8),
              Text(
                caption!,
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
