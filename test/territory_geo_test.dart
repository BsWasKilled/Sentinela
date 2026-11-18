import 'package:sentinela/features/alerts/domain/alert_geo.dart';
import 'package:sentinela/features/alerts/domain/alert_type.dart';
import 'package:sentinela/features/alerts/domain/territory_alert.dart';
import 'package:sentinela/features/territory/domain/geo.dart';
import 'package:sentinela/features/territory/domain/territory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('distância entre pontos conhecidos', () {
    // Centro de São Paulo até ~11 km a oeste.
    const a = GeoPoint(-23.5505, -46.6333);
    const b = GeoPoint(-23.5505, -46.7400);
    expect(a.distanceKmTo(b), closeTo(10.9, 0.3));
    expect(a.distanceKmTo(a), 0);
  });

  test('arredondamento deixa a localização aproximada', () {
    const p = GeoPoint(-23.55123, -46.63987);
    final r = p.rounded();
    expect(r.latitude, -23.55);
    expect(r.longitude, -46.64);
  });

  test('região mais próxima e limite do território', () {
    final near = Territory.nearest(const GeoPoint(-23.601, -46.699));
    expect(near.region.name, 'Jardim das Encostas');
    expect(near.distanceKm, lessThan(0.5));
    expect(Territory.contains(const GeoPoint(-23.55, -46.63)), isTrue);
    expect(Territory.contains(const GeoPoint(37.42, -122.08)), isFalse);
  });

  test('pontos do alerta: coordenada própria, regiões ou centro', () {
    final withCoords = TerritoryAlert.citizenReport(
      type: AlertType.flooding,
      priority: AlertPriority.high,
      location: 'Centro',
      description: 'Rua alagada perto da praça',
      now: DateTime(2026, 11, 13),
      latitude: -23.55,
      longitude: -46.63,
    );
    expect(AlertGeo.pointsFor(withCoords).single.latitude, -23.55);

    TerritoryAlert auto(String? location) => TerritoryAlert(
          type: AlertType.landslide,
          priority: AlertPriority.high,
          confidence: 0.8,
          evidence: const ['x'],
          limitations: const ['y'],
          suggestedAction: 'z',
          generatedAt: DateTime(2026, 11, 13),
          location: location,
        );
    expect(AlertGeo.pointsFor(auto('Jardim das Encostas, Alto da Serra')).length, 2);
    expect(AlertGeo.pointsFor(auto(null)).single, Territory.center);
  });
}
