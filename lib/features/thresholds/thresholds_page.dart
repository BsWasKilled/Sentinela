import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/content_column.dart';
import '../../core/widgets/info_banner.dart';
import '../../core/widgets/section_header.dart';
import '../alerts/domain/alert_thresholds.dart';
import '../territory/state/territory_provider.dart';
import 'threshold_validators.dart';

/// Formulário de limiares de alerta (persistidos; afetam o motor na hora).
class ThresholdsPage extends StatefulWidget {
  const ThresholdsPage({super.key});

  @override
  State<ThresholdsPage> createState() => _ThresholdsPageState();
}

class _ThresholdsPageState extends State<ThresholdsPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _c = _controllersFor(context.read<TerritoryProvider>().thresholds);
  }

  Map<String, TextEditingController> _controllersFor(AlertThresholds t) => {
        'rain24hMm': TextEditingController(text: _fmt(t.rain24hMm)),
        'floodMm': TextEditingController(text: _fmt(t.floodMm)),
        'landslideRainMm': TextEditingController(text: _fmt(t.landslideRainMm)),
        'windGustKmh': TextEditingController(text: _fmt(t.windGustKmh)),
        'heatTempC': TextEditingController(text: _fmt(t.heatTempC)),
        'fireTempC': TextEditingController(text: _fmt(t.fireTempC)),
        'fireHumidityPct': TextEditingController(text: _fmt(t.fireHumidityPct)),
        'fireDryDays': TextEditingController(text: '${t.fireDryDays}'),
        'waterIncreasePct': TextEditingController(text: _fmt(t.waterIncreasePct)),
        'energyPeakPct': TextEditingController(text: _fmt((t.energyPeakFactor - 1) * 100)),
      };

  static String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(String k) => ThresholdValidators.parse(_c[k]!.text);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<TerritoryProvider>().setThresholds(AlertThresholds(
          rain24hMm: _v('rain24hMm'),
          floodMm: _v('floodMm'),
          landslideRainMm: _v('landslideRainMm'),
          windGustKmh: _v('windGustKmh'),
          heatTempC: _v('heatTempC'),
          fireTempC: _v('fireTempC'),
          fireHumidityPct: _v('fireHumidityPct'),
          fireDryDays: _v('fireDryDays').round(),
          waterIncreasePct: _v('waterIncreasePct'),
          energyPeakFactor: 1 + _v('energyPeakPct') / 100,
        ));
    messenger.showSnackBar(
      const SnackBar(content: Text('Limiares salvos. Os alertas foram recalculados.')),
    );
    navigator.pop();
  }

  Future<void> _reset() async {
    final provider = context.read<TerritoryProvider>();
    await provider.resetThresholds();
    if (!mounted) return;
    final fresh = _controllersFor(provider.thresholds);
    for (final e in fresh.entries) {
      _c[e.key]!.text = e.value.text;
      e.value.dispose();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Limiares restaurados para o padrão.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limiares de alerta'),
        actions: [
          TextButton(onPressed: _saving ? null : _reset, child: const Text('Padrão')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ContentColumn(
          children: [
            const InfoBanner(
              icon: Icons.tune,
              text: 'Os limiares definem quando um alerta é gerado. Ajuste-os ao '
                  'histórico do território; valores muito baixos geram alertas demais.',
            ),
            const SectionHeader('Chuva e solo'),
            _Field(_c['rain24hMm']!, 'Chuva intensa em 24h', 'mm', min: 10, max: 300),
            _Field(_c['floodMm']!, 'Alagamento (24h + previsão 6h)', 'mm', min: 10, max: 400),
            _Field(_c['landslideRainMm']!, 'Deslizamento (chuva 24h em encosta)', 'mm', min: 10, max: 300),
            const SectionHeader('Vento e calor'),
            _Field(_c['windGustKmh']!, 'Vento forte (rajada)', 'km/h', min: 20, max: 200),
            _Field(_c['heatTempC']!, 'Onda de calor', '°C', min: 25, max: 50),
            const SectionHeader('Risco de incêndio'),
            _Field(_c['fireTempC']!, 'Temperatura mínima', '°C', min: 20, max: 50),
            _Field(_c['fireHumidityPct']!, 'Umidade máxima do ar', '%', min: 5, max: 80),
            _Field(_c['fireDryDays']!, 'Dias sem chuva', 'dias', min: 1, max: 90, integer: true),
            const SectionHeader('Recursos'),
            _Field(_c['waterIncreasePct']!, 'Alta do consumo de água (semana)', '%', min: 5, max: 100),
            _Field(_c['energyPeakPct']!, 'Pico de energia acima da média', '%', min: 5, max: 100),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar limiares'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
    this.controller,
    this.label,
    this.unit, {
    required this.min,
    required this.max,
    this.integer = false,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final double min;
  final double max;
  final bool integer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [
          FilteringTextInputFormatter.allow(integer ? RegExp(r'\d') : RegExp(r'[\d.,]')),
        ],
        decoration: InputDecoration(labelText: label, suffixText: unit),
        validator: (v) => ThresholdValidators.inRange(v, min: min, max: max, unit: unit),
      ),
    );
  }
}
