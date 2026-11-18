import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/content_column.dart';
import '../alerts/domain/alert_type.dart';
import '../alerts/domain/territory_alert.dart';
import '../location/data/location_service.dart';
import '../map/widgets/alerts_map.dart';
import '../territory/data/open_meteo_client.dart';
import '../territory/domain/geo.dart';
import '../territory/domain/territory.dart';
import '../territory/state/territory_provider.dart';
import 'register_validators.dart';
import 'weather_suggestion.dart';

class RegisterAlertPage extends StatefulWidget {
  const RegisterAlertPage({super.key});

  @override
  State<RegisterAlertPage> createState() => _RegisterAlertPageState();
}

class _RegisterAlertPageState extends State<RegisterAlertPage> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  AlertType? _type;
  AlertPriority? _priority;
  String? _region;
  bool _saving = false;

  // Localização (opcional, só com ação explícita da pessoa).
  bool _locating = false;
  GeoPoint? _point;
  NearestRegion? _nearest;
  String? _locationError;
  bool _attachLocation = true;

  // Clima no momento (vem junto com a localização).
  OpenMeteoCurrent? _current;
  bool _attachConditions = true;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
      _current = null;
    });
    final location = context.read<LocationService>();
    final weather = context.read<OpenMeteoClient>();
    try {
      final point = await location.current();
      final nearest = Territory.nearest(point);
      OpenMeteoCurrent? current;
      try {
        current = await weather.current(point);
      } catch (_) {
        current = null; // Sem clima não impede o registro.
      }
      if (!mounted) return;
      setState(() {
        _point = point;
        _nearest = nearest;
        _region = nearest.region.name;
        _current = current;
        _type ??= current == null ? null : WeatherSuggestion.suggestType(current);
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() => _locationError = e.failure.message);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final point = _attachLocation ? _point?.rounded() : null;
    await context.read<TerritoryProvider>().addCitizenReport(
          type: _type!,
          priority: _priority!,
          location: _region!,
          description: _description.text,
          conditions: _attachConditions ? _current?.summary : null,
          latitude: point?.latitude,
          longitude: point?.longitude,
        );
    messenger.showSnackBar(const SnackBar(content: Text('Alerta registrado com sucesso.')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final suggestion = _current == null ? null : WeatherSuggestion.suggestType(_current!);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar alerta')),
      body: Form(
        key: _formKey,
        child: ContentColumn(
          padding: AppSpacing.page,
          children: [
            Text('Onde está acontecendo?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _locating ? null : _useMyLocation,
              icon: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_point == null ? 'Usar minha localização' : 'Atualizar localização'),
            ),
            const SizedBox(height: 4),
            Text(
              'A localização é usada uma vez, para sugerir a região e buscar o clima. '
              'Nada é rastreado.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            if (_locationError != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(_locationError!, style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
            if (_point != null && _nearest != null) ...[
              const SizedBox(height: 12),
              AlertsMap(
                alerts: const [],
                height: 160,
                extraPoint: _point,
                extraLabel: 'Sua localização aproximada',
              ),
              const SizedBox(height: 8),
              Text(
                Territory.contains(_point!)
                    ? 'Região sugerida: ${_nearest!.region.name} '
                        '(a ${_nearest!.distanceKm.toStringAsFixed(1)} km do centro da região).'
                    : 'Você está a ${_nearest!.distanceKm.round()} km do território. '
                        'Confira a região antes de enviar.',
                style: theme.textTheme.bodyMedium,
              ),
              CheckboxListTile(
                value: _attachLocation,
                onChanged: (v) => setState(() => _attachLocation = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Anexar localização aproximada (arredondada a cerca de 1 km)'),
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(_region),
              initialValue: _region,
              decoration: const InputDecoration(labelText: 'Região'),
              items: [
                for (final name in Territory.regionNames)
                  DropdownMenuItem(value: name, child: Text(name)),
              ],
              onChanged: (v) => setState(() => _region = v),
              validator: (v) => v == null ? 'Selecione a região' : null,
            ),
            if (_current != null) ...[
              const SizedBox(height: 20),
              Text('Condições agora', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(_current!.summary),
              if (suggestion != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text('Sugestão pelo clima:', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    ActionChip(
                      avatar: Icon(suggestion.icon, size: 18),
                      label: Text(suggestion.label),
                      onPressed: () => setState(() => _type = suggestion),
                    ),
                  ],
                ),
              ],
              CheckboxListTile(
                value: _attachConditions,
                onChanged: (v) => setState(() => _attachConditions = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Anexar as condições do momento ao relato'),
              ),
            ],
            const SizedBox(height: 20),
            Text('O que você viu?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<AlertType>(
              key: ValueKey(_type),
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo de alerta'),
              items: [
                for (final t in AlertType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (v) => setState(() => _type = v),
              validator: (v) => v == null ? 'Selecione o tipo de alerta' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AlertPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Prioridade'),
              items: [
                for (final s in AlertPriority.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() => _priority = v),
              validator: (v) => v == null ? 'Selecione a prioridade' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 4,
              maxLength: 280,
              decoration: const InputDecoration(
                labelText: 'O que está acontecendo?',
                alignLabelWithHint: true,
              ),
              validator: RegisterValidators.description,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 18, color: muted),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'O relato é anônimo. Não coletamos nome nem telefone, e a localização '
                    'exata nunca é salva.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Registrar alerta'),
            ),
          ],
        ),
      ),
    );
  }
}
