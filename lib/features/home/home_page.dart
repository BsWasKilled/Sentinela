import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/content_column.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/human_decision_banner.dart';
import '../../core/widgets/info_banner.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/state_message.dart';
import '../alerts/presentation/widgets/alert_card.dart';
import '../territory/domain/indicator.dart';
import '../territory/domain/territory.dart';
import '../territory/domain/territory_dataset.dart';
import '../territory/domain/trend.dart';
import '../territory/state/territory_provider.dart';
import 'home_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TerritoryProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sentinela'),
            Text(
              Territory.name,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
        bottom: state.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'register-fab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
        icon: const Icon(Icons.add_alert),
        label: const Text('Registrar alerta'),
      ),
      body: switch (state.status) {
        LoadStatus.loading => const Center(child: CircularProgressIndicator()),
        LoadStatus.error => Center(
            child: StateMessage(
              icon: Icons.error_outline,
              title: 'Não foi possível carregar os alertas',
              message: 'Verifique o armazenamento do aparelho e tente novamente.',
              onAction: () => context.read<TerritoryProvider>().load(),
            ),
          ),
        LoadStatus.ready => _Content(state: state),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final TerritoryProvider state;

  static final _stamp = DateFormat('dd/MM HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = state.recent;
    final data = state.dataset;
    final impact = state.socialImpact;
    final shell = HomeShellScope.maybeOf(context);

    return ContentColumn(
      padding: AppSpacing.pageWithFab,
      onRefresh: state.refresh,
      children: [
        if (state.isOffline) ...[
          const InfoBanner(
            icon: Icons.cloud_off,
            tone: InfoBannerTone.error,
            text: 'Sem conexão com a fonte de dados. Mostrando os últimos dados salvos.',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const HumanDecisionBanner(),
        if (data != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Atualizado ${_stamp.format(data.fetchedAt)} · ${data.source}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
        SectionHeader(
          'Alertas recentes',
          subtitle: state.all.length > recent.length
              ? '${state.all.length} no total'
              : null,
          action: TextButton.icon(
            onPressed: () => _open(context, shell, tab: 3, route: AppRoutes.history),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Ver histórico'),
          ),
        ),
        if (recent.isEmpty)
          const StateMessage(
            icon: Icons.check_circle_outline,
            title: 'Nenhum alerta por enquanto',
            message: 'Quando houver risco no território, ele aparece aqui.',
          )
        else
          for (final (i, alert) in recent.indexed)
            FadeSlideIn(
              key: ValueKey(alert.id),
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AlertCard(
                  alert: alert,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.alertDetail,
                    arguments: alert,
                  ),
                ),
              ),
            ),
        const SectionHeader('Benefício social'),
        Row(
          children: [
            Expanded(
              child: _ImpactTile(
                icon: Icons.groups_outlined,
                value: _compact(impact.residentsReached),
                label: 'moradores cobertos por alertas (24h)',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ImpactTile(
                icon: Icons.campaign_outlined,
                value: '${impact.reportCount}',
                label: impact.reportCount == 1
                    ? 'relato de cidadão'
                    : 'relatos de cidadãos',
              ),
            ),
          ],
        ),
        const SectionHeader('Painéis', subtitle: 'Indicadores com histórico e tendência'),
        _DashboardCard(
          kind: DashboardKind.climate,
          summary: _climateSummary(data),
          onTap: () => _open(context, shell, dashboard: 0, route: AppRoutes.dashboardClimate),
        ),
        _DashboardCard(
          kind: DashboardKind.resources,
          summary: _resourcesSummary(data),
          onTap: () => _open(context, shell, dashboard: 1, route: AppRoutes.dashboardResources),
        ),
        _DashboardCard(
          kind: DashboardKind.services,
          summary: state.citizenReportCount == 0
              ? 'Nenhum relato de cidadão ainda'
              : '${state.citizenReportCount} relatos em '
                  '${impact.regionsWithReports} regiões',
          onTap: () => _open(context, shell, dashboard: 2, route: AppRoutes.dashboardServices),
        ),
      ],
    );
  }

  /// Dentro da casca troca de aba; fora dela (rota direta) empurra a tela.
  static void _open(
    BuildContext context,
    HomeShellScope? shell, {
    int? tab,
    int? dashboard,
    required String route,
  }) {
    if (shell == null) {
      Navigator.pushNamed(context, route);
    } else if (dashboard != null) {
      shell.goToDashboard(dashboard);
    } else if (tab != null) {
      shell.goToTab(tab);
    }
  }

  static String _compact(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)} mil' : '$n';

  String _climateSummary(TerritoryDataset? d) {
    if (d == null) return 'Aguardando dados';
    final c = d.current;
    return 'Chuva 24h ${c.rain24hMm.round()} mm · ${c.tempC.round()} °C · '
        'rajadas ${c.windGustKmh.round()} km/h';
  }

  String _resourcesSummary(TerritoryDataset? d) {
    if (d == null || d.history.isEmpty) return 'Aguardando dados';
    final water = Trend.of(Indicator.water.series(d.history));
    final energy = Trend.of(Indicator.energy.series(d.history));
    return 'Água ${water.direction.label} (${water.summary}) · '
        'energia ${energy.direction.label}';
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$value $label',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(value, style: theme.textTheme.headlineSmall),
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.kind,
    required this.summary,
    required this.onTap,
  });

  final DashboardKind kind;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Icon(kind.icon),
          ),
          title: Text(kind.label),
          subtitle: Text(summary),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
