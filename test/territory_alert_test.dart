import 'package:sentinela/features/alerts/domain/alert_type.dart';
import 'package:sentinela/features/alerts/domain/territory_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('relato do cidadão sobrevive ao ciclo JSON', () {
    final original = TerritoryAlert.citizenReport(
      type: AlertType.flooding,
      priority: AlertPriority.high,
      location: 'Centro',
      description: 'Rua alagada perto da praça',
      now: DateTime(2026, 11, 9, 10),
    );
    final copy = TerritoryAlert.fromJson(original.toJson());
    expect(copy.id, original.id);
    expect(copy.type, AlertType.flooding);
    expect(copy.source, AlertSource.citizen);
    expect(copy.location, 'Centro');
    expect(copy.confidence, original.confidence);
  });

  test('alerta automático tem id estável por tipo e dia', () {
    TerritoryAlert make(DateTime d) => TerritoryAlert(
          type: AlertType.heavyRain,
          priority: AlertPriority.low,
          confidence: 0.7,
          evidence: const ['x'],
          limitations: const ['y'],
          suggestedAction: 'z',
          generatedAt: d,
        );
    expect(make(DateTime(2026, 11, 9, 8)).id, make(DateTime(2026, 11, 9, 20)).id);
  });
}
