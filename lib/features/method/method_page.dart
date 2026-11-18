import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/content_column.dart';
import '../../core/widgets/human_decision_banner.dart';
import '../../core/widgets/section_header.dart';
import '../territory/state/territory_provider.dart';

/// Transparência do método: como os alertas nascem, métricas, limitações,
/// vieses e quando não confiar.
class MethodPage extends StatelessWidget {
  const MethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TerritoryProvider>().thresholds;
    return Scaffold(
      appBar: AppBar(title: const Text('Como os alertas são gerados')),
      body: ContentColumn(
        children: [
          const HumanDecisionBanner(),
          const SectionHeader('Método'),
          const _P(
            'Cada alerta nasce de regras sobre a leitura atual do território, '
            'reforçadas pela tendência dos últimos 7 dias. A tendência compara a '
            'média da semana atual com a da semana anterior; variações de até 10% '
            'são tratadas como estáveis.',
          ),
          _P(
            'Os limiares são configuráveis. Hoje: chuva intensa a partir de '
            '${t.rain24hMm.round()} mm em 24h, vento forte a partir de '
            '${t.windGustKmh.round()} km/h, onda de calor a partir de '
            '${t.heatTempC.round()} °C, alta de água a partir de '
            '${t.waterIncreasePct.round()}% na semana.',
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.thresholds),
            icon: const Icon(Icons.tune),
            label: const Text('Ajustar limiares'),
          ),
          const SectionHeader('Prioridade'),
          const _P(
            'Baixa: a leitura passou do limiar. Média: passou em 20% ou mais. '
            'Alta: passou em 50% ou mais. Para incêndio, a prioridade sobe com o '
            'número de sinais que concordam (umidade, calor, dias secos e vento).',
          ),
          const SectionHeader('Nível de confiança'),
          const _P(
            'Começa em 50% e soma até 40% conforme a fração de sinais que '
            'confirmam o alerta (por exemplo, previsão de chuva e tendência de '
            'alta). Cai 15 pontos quando os dados vêm do cache e nunca passa de 95%, '
            'porque nenhuma regra elimina a incerteza.',
          ),
          const _P(
            'Relatos de cidadãos entram com 40% (50% quando trazem as condições '
            'do momento), pois não passam por verificação técnica.',
          ),
          const SectionHeader('Métricas usadas'),
          const _Bullet('Razão entre a leitura e o limiar (quanto passou).'),
          const _Bullet('Variação percentual da média semanal (tendência).'),
          const _Bullet('Dias consecutivos sem chuva e umidade do solo.'),
          const _Bullet('Fração de sinais confirmados por alerta (confiança).'),
          const SectionHeader('Limitações e vieses'),
          const _Bullet('O clima vem de um único ponto (centro do território): bairros de serra e vale podem diferir bastante.'),
          const _Bullet('A previsão de chuva de curto prazo é de modelo numérico e perde precisão em tempestades localizadas.'),
          const _Bullet('O mapa de suscetibilidade a deslizamento é estático e simplificado.'),
          const _Bullet('Consumo de água e energia é sintético: não há API pública com dados diários por município.'),
          const _Bullet('Relatos de cidadãos refletem quem tem celular e conexão; regiões com menos acesso podem parecer "mais calmas" do que são (viés de inclusão).'),
          const _Bullet('A série histórica tem 30 dias e não captura sazonalidade anual.'),
          const SectionHeader('Quando não confiar'),
          const _Bullet('Quando o aviso de "dados do cache" estiver visível.'),
          const _Bullet('Em eventos extremos fora do histórico recente (a tendência não os antecipa).'),
          const _Bullet('Quando os limiares foram alterados sem base no histórico local.'),
          const _Bullet('Para decidir sobre uma rua ou um imóvel específico: o alerta é territorial.'),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
