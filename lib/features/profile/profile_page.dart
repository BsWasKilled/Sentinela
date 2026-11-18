import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/state/auth_provider.dart';
import '../settings/state/settings_provider.dart';
import '../territory/state/territory_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static final _date = DateFormat('dd/MM/yyyy');

  Future<void> _signOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    await auth.signOut();
    navigator.popUntil((route) => route.isFirst);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: const Text(
          'Seu e-mail e sua senha serão apagados deste aparelho. '
          'Os alertas já registrados continuam no histórico, pois são anônimos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await auth.deleteAccount();
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AuthProvider>().account;
    if (account == null) return const Scaffold();

    final reports = context.watch<TerritoryProvider>().citizenReportCount;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Semantics(
              label: 'Avatar com a inicial do e-mail',
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  account.email[0].toUpperCase(),
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(account.email,
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          Text(
            'Conta criada em ${_date.format(account.createdAt)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.volunteer_activism,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Relatos registrados neste aparelho',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Text('$reports', style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Privacidade', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Consentimento de uso do e-mail aceito em '
                    '${_date.format(account.consentAt)}.',
                  ),
                  if (context.watch<SettingsProvider>().consentAt case final c?)
                    Text('Termos do app aceitos em ${_date.format(c)}.'),
                  const SizedBox(height: 4),
                  Text(
                    'Seus relatos de alerta não são ligados ao seu e-mail.',
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _deleteAccount(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir conta'),
          ),
        ],
      ),
    );
  }
}
