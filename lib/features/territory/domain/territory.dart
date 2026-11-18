import 'geo.dart';

/// Dados estáticos do território monitorado.
class Region {
  const Region(
    this.name, {
    required this.population,
    required this.point,
    this.slopeRisk = 0.2,
  });

  final String name;
  final int population;

  /// Centro aproximado da região.
  final GeoPoint point;

  /// Suscetibilidade a deslizamento (0 a 1).
  final double slopeRisk;
}

class NearestRegion {
  const NearestRegion(this.region, this.distanceKm);

  final Region region;
  final double distanceKm;
}

abstract final class Territory {
  static const name = 'Vale Verde';
  static const description =
      'Território fictício ancorado nas coordenadas de São Paulo para '
      'consumir dados reais de clima';

  /// Centro do território (usado para buscar o clima real).
  static const center = GeoPoint(-23.5505, -46.6333);

  /// Raio dentro do qual uma localização é considerada "no território".
  static const radiusKm = 30.0;

  static const regions = [
    Region('Centro', population: 18400, point: GeoPoint(-23.5505, -46.6333)),
    Region('Vila Esperança', population: 22100, point: GeoPoint(-23.5200, -46.6000)),
    Region('Jardim das Encostas',
        population: 9600, point: GeoPoint(-23.6000, -46.7000), slopeRisk: 0.8),
    Region('Alto da Serra',
        population: 7300, point: GeoPoint(-23.4900, -46.6900), slopeRisk: 0.6),
    Region('Beira-Rio', population: 14900, point: GeoPoint(-23.5300, -46.5700)),
    Region('Zona Rural', population: 5200, point: GeoPoint(-23.6600, -46.5600)),
  ];

  static List<String> get regionNames => [for (final r in regions) r.name];

  static int get population =>
      regions.fold(0, (sum, r) => sum + r.population);

  static List<Region> get slopeRegions =>
      regions.where((r) => r.slopeRisk >= 0.5).toList();

  static double get maxSlopeRisk =>
      regions.map((r) => r.slopeRisk).reduce((a, b) => a > b ? a : b);

  static Region? byName(String name) {
    for (final r in regions) {
      if (r.name == name) return r;
    }
    return null;
  }

  static NearestRegion nearest(GeoPoint point) {
    var best = regions.first;
    var bestKm = point.distanceKmTo(best.point);
    for (final r in regions.skip(1)) {
      final km = point.distanceKmTo(r.point);
      if (km < bestKm) {
        best = r;
        bestKm = km;
      }
    }
    return NearestRegion(best, bestKm);
  }

  static bool contains(GeoPoint point) =>
      point.distanceKmTo(center) <= radiusKm;
}
