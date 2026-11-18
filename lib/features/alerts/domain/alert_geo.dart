import '../../territory/domain/geo.dart';
import '../../territory/domain/territory.dart';
import 'territory_alert.dart';

/// Pontos no mapa para um alerta: coordenada própria, centro das regiões
/// citadas ou, para alertas de todo o território, o centro do território.
abstract final class AlertGeo {
  static List<GeoPoint> pointsFor(TerritoryAlert alert) {
    final lat = alert.latitude;
    final lon = alert.longitude;
    if (lat != null && lon != null) return [GeoPoint(lat, lon)];
    final location = alert.location;
    if (location != null) {
      final points = [
        for (final part in location.split(','))
          if (Territory.byName(part.trim()) case final r?) r.point,
      ];
      if (points.isNotEmpty) return points;
    }
    return const [Territory.center];
  }
}
