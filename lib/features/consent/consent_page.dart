import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/content_column.dart';
import '../settings/state/settings_provider.dart';

/// Etapa de consentimento no primeiro uso: explica o que é coletado,
/// para quê, e só libera o app depois do aceite explícito.
class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key, this.reviewOnly = false});

  /// Quando aberto pelas configurações só para releitura.
  final bool reviewOnly;

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: widget.reviewOnly ? AppBar(title: const Text('Privacidade e consentimento')) : null,
      body: SafeArea(
        child: ContentColumn(
          children: [
            if (!widget.reviewOnly) ...[
              const SizedBox(height: AppSpacing.xl),
              Icon(Icons.shield_outlined, size: 56, color: scheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text('Bem-vindo ao Sentinela', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Antes de começar, veja como o app trata seus dados.',
                style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            const _Item(
              icon: Icons.email_outlined,
              title: 'Conta local',
              text: 'Seu e-mail identifica sua conta apenas neste aparelho. A senha é guardada '
                  'como um código irreversível, nunca em texto.',
            ),
            const _Item(
              icon: Icons.visibility_off_outlined,
              title: 'Relatos anônimos',
              text: 'Os alertas que você registrar não ficam ligados ao seu e-mail. Telefones '
                  'e e-mails digitados na descrição são bloqueados.',
            ),
            const _Item(
              icon: Icons.my_location,
              title: 'Localização só quando você pedir',
              text: 'Usada uma vez, ao tocar em "Usar minha localização", para sugerir a '
                  'região e buscar o clima. Se você anexar ao relato, é salva arredondada '
                  'a cerca de 1 km. Nada é rastreado.',
            ),
            const _Item(
              icon: Icons.cloud_outlined,
              title: 'Dados externos',
              text: 'O clima vem da Open-Meteo e os mapas do OpenStreetMap. Só as coordenadas '
                  'do território (ou a sua, se você pedir) são enviadas a esses serviços.',
            ),
            const _Item(
              icon: Icons.person_outline,
              title: 'Decisão humana',
              text: 'Os alertas apoiam, mas não substituem, a decisão de um gestor. Nenhuma '
                  'ação é tomada automaticamente.',
            ),
            const _Item(
              icon: Icons.delete_outline,
              title: 'Controle',
              text: 'Você pode excluir sua conta e limpar os dados salvos a qualquer momento, '
                  'no Perfil e nas Configurações.',
            ),
            if (!widget.reviewOnly) ...[
              const SizedBox(height: AppSpacing.lg),
              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Li e concordo com o uso dos dados descrito acima.'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _accepted
                    ? () => context.read<SettingsProvider>().acceptConsent()
                    : null,
                child: const Text('Continuar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
