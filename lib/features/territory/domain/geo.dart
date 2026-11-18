import 'dart:math';

/// Coordenada geográfica simples, sem dependência de pacote de mapa.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Arredonda para 2 casas (cerca de 1 km): localização aproximada.
  GeoPoint rounded() => GeoPoint(
        (latitude * 100).round() / 100,
        (longitude * 100).round() / 100,
      );

  /// Distância em km pela fórmula de haversine.
  double distanceKmTo(GeoPoint other) {
    const r = 6371.0;
    final dLat = _rad(other.latitude - latitude);
    final dLon = _rad(other.longitude - longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(latitude)) * cos(_rad(other.latitude)) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;

  @override
  String toString() => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
