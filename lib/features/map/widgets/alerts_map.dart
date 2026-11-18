import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../alerts/domain/alert_geo.dart';
import '../../alerts/domain/territory_alert.dart';
import '../../territory/domain/geo.dart';
import '../../territory/domain/territory.dart';

/// Mapa OpenStreetMap com um marcador por ponto de cada alerta.
class AlertsMap extends StatelessWidget {
  const AlertsMap({
    super.key,
    required this.alerts,
    this.interactive = false,
    this.height,
    this.extraPoint,
    this.extraLabel,
  });

  final List<TerritoryAlert> alerts;

  /// Falso dentro de listas roláveis (evita disputa de gestos).
  final bool interactive;
  final double? height;

  /// Ponto adicional (ex.: a posição do usuário no registro).
  final GeoPoint? extraPoint;
  final String? extraLabel;

  static LatLng _toLatLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final markers = <Marker>[];
    final points = <LatLng>[];

    for (final alert in alerts) {
      for (final p in AlertGeo.pointsFor(alert)) {
        final latLng = _toLatLng(p);
        points.add(latLng);
        markers.add(Marker(
          point: latLng,
          width: 34,
          height: 34,
          child: _AlertPin(alert: alert),
        ));
      }
    }
    if (extraPoint != null) {
      final latLng = _toLatLng(extraPoint!);
      points.add(latLng);
      markers.add(Marker(
        point: latLng,
        width: 34,
        height: 34,
        child: Semantics(
          label: extraLabel ?? 'Sua localização',
          child: Icon(Icons.my_location, color: scheme.primary, size: 30),
        ),
      ));
    }

    final fitAll = points.length >= 2;
    final options = MapOptions(
      initialCenter: points.length == 1 ? points.first : _toLatLng(Territory.center),
      initialZoom: points.length == 1 ? 12 : 10.5,
      initialCameraFit: fitAll
          ? CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(40),
            )
          : null,
      interactionOptions: InteractionOptions(
        flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
      ),
    );

    final map = FlutterMap(
      options: options,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.fiap.sentinela',
        ),
        MarkerLayer(markers: markers),
        SimpleAttributionWidget(
          source: const Text('OpenStreetMap contributors'),
        ),
      ],
    );

    final label = alerts.isEmpty
        ? 'Mapa do território sem alertas'
        : 'Mapa com ${alerts.length} alertas marcados';
    final child = Semantics(label: label, child: map);
    return height == null
        ? child
        : SizedBox(
            height: height,
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
          );
  }
}

class _AlertPin extends StatelessWidget {
  const _AlertPin({required this.alert});

  final TerritoryAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.priority.color;
    return Semantics(
      button: true,
      label: '${alert.type.label}, ${alert.priority.fullLabel}',
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.alertDetail,
          arguments: alert,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(alert.type.icon, size: 17, color: Colors.black87),
        ),
      ),
    );
  }
}

/// Legenda das cores de prioridade.
class PriorityLegend extends StatelessWidget {
  const PriorityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return Wrap(
      spacing: 14,
      children: [
        for (final p in AlertPriority.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(p.fullLabel, style: style),
            ],
          ),
      ],
    );
  }
}
