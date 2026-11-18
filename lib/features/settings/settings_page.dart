import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../consent/consent_page.dart';
import '../territory/state/territory_provider.dart';
import 'domain/test_flags.dart';
import 'state/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _reload(BuildContext context) {
    context.read<TerritoryProvider>().load();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recarregando. Veja o resultado na tela inicial.')),
    );
  }

  Future<void> _clearAlerts(BuildContext context) async {
    final alerts = context.read<TerritoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _confirm(
      context,
      title: 'Limpar alertas salvos?',
      body: 'Todo o histórico guardado neste aparelho será apagado.',
      action: 'Limpar',
    );
    if (!confirmed) return;
    await alerts.clearAll();
    messenger.showSnackBar(const SnackBar(content: Text('Histórico apagado.')));
  }

  Future<void> _revokeConsent(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final navigator = Navigator.of(context);
    final confirmed = await _confirm(
      context,
      title: 'Revogar consentimento?',
      body: 'O app volta à tela inicial de consentimento. Seus dados não são apagados; '
          'para isso use "Excluir conta" no Perfil.',
      action: 'Revogar',
    );
    if (!confirmed) return;
    navigator.popUntil((r) => r.isFirst);
    await settings.revokeConsent();
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final flags = settings.flags;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          const _SectionHeader('Aparência'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final c in AppThemeChoice.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: settings.theme == c,
                    onSelected: (_) => settings.setTheme(c),
                  ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Tamanho do texto'),
            subtitle: Slider(
              value: settings.textScale,
              min: SettingsProvider.minTextScale,
              max: SettingsProvider.maxTextScale,
              divisions: 11,
              label: '${(settings.textScale * 100).round()}%',
              semanticFormatterCallback: (v) => '${(v * 100).round()} por cento',
              onChanged: settings.setTextScale,
            ),
            trailing: Text('${(settings.textScale * 100).round()}%'),
          ),
          const _SectionHeader('Alertas'),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Limiares de alerta'),
            subtitle: const Text('Quando cada tipo de alerta é gerado.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.thresholds),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Como os alertas são gerados'),
            subtitle: const Text('Método, métricas, limitações e vieses.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.method),
          ),
          const _SectionHeader('Fonte dos dados'),
          SwitchListTile(
            title: const Text('Usar clima real (Open-Meteo)'),
            subtitle: Text(
              settings.useRealWeather
                  ? 'Previsão e últimos 30 dias para o território. Água e energia seguem sintéticos.'
                  : 'Usando cenários sintéticos (escolha abaixo).',
            ),
            value: settings.useRealWeather,
            onChanged: (v) {
              settings.setRealWeather(v);
              context.read<TerritoryProvider>().refresh();
            },
          ),
          ListTile(
            title: const Text('Cenário dos dados simulados'),
            subtitle: Text(
              settings.useRealWeather
                  ? 'Desligue o clima real para usar os cenários.'
                  : 'Muda os alertas gerados na próxima atualização.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: IgnorePointer(
              ignoring: settings.useRealWeather,
              child: Opacity(
                opacity: settings.useRealWeather ? 0.4 : 1,
                child: SegmentedButton<DataScenario>(
                  segments: [
                    for (final s in DataScenario.values)
                      ButtonSegment(value: s, label: Text(s.label)),
                  ],
                  selected: {flags.scenario},
                  onSelectionChanged: (s) {
                    settings.setScenario(s.first);
                    context.read<TerritoryProvider>().refresh();
                  },
                ),
              ),
            ),
          ),
          const _SectionHeader('Testes'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Opções para demonstrar o comportamento do app. '
              'Elas voltam ao normal quando o app é fechado.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          SwitchListTile(
            title: const Text('Simular falha de rede'),
            subtitle: const Text('A atualização falha e o app usa os dados salvos.'),
            value: flags.simulateNetworkFailure,
            onChanged: settings.setNetworkFailure,
          ),
          SwitchListTile(
            title: const Text('Simular rede lenta'),
            subtitle: const Text('A atualização leva cerca de 4 segundos.'),
            value: flags.simulateSlowNetwork,
            onChanged: settings.setSlowNetwork,
          ),
          SwitchListTile(
            title: const Text('Simular erro de armazenamento'),
            subtitle: const Text('Faz a tela inicial mostrar o estado de erro.'),
            value: flags.simulateStorageError,
            onChanged: settings.setStorageError,
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Recarregar dados agora'),
            subtitle: const Text('Aplica as opções acima na tela inicial.'),
            onTap: () => _reload(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Limpar alertas salvos'),
            onTap: () => _clearAlerts(context),
          ),
          const _SectionHeader('Privacidade'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Como seus dados são usados'),
            subtitle: Text(
              settings.consentAt == null
                  ? 'Consentimento pendente'
                  : 'Consentimento aceito em ${_date(settings.consentAt!)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ConsentPage(reviewOnly: true),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Revogar consentimento'),
            onTap: () => _revokeConsent(context),
          ),
          const _SectionHeader('Sobre'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sentinela 1.0.0'),
            subtitle: Text(
              'Projeto acadêmico, FIAP, Global Solution 2026.2.\n'
              'Clima: Open-Meteo (CC BY 4.0). Mapas: © OpenStreetMap contributors.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
