import 'package:sentinela/features/alerts/domain/alert_engine.dart';
import 'package:sentinela/features/alerts/domain/alert_thresholds.dart';
import 'package:sentinela/features/alerts/domain/alert_type.dart';
import 'package:sentinela/features/alerts/domain/weather_snapshot.dart';
import 'package:sentinela/features/thresholds/threshold_validators.dart';
import 'package:sentinela/features/thresholds/thresholds_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThresholdValidators', () {
    test('rejeita vazio, texto e fora da faixa', () {
      expect(ThresholdValidators.inRange('', min: 10, max: 300), isNotNull);
      expect(ThresholdValidators.inRange('abc', min: 10, max: 300), isNotNull);
      expect(ThresholdValidators.inRange('5', min: 10, max: 300), isNotNull);
      expect(ThresholdValidators.inRange('301', min: 10, max: 300), isNotNull);
    });
    test('aceita vírgula decimal', () {
      expect(ThresholdValidators.inRange('45,5', min: 10, max: 300), isNull);
      expect(ThresholdValidators.parse('45,5'), 45.5);
    });
  });

  test('limiares sobrevivem ao ciclo JSON e à persistência', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = ThresholdsRepository();
    expect((await repo.read()).rain24hMm, 50);
    await repo.save(const AlertThresholds(rain24hMm: 80, fireDryDays: 10));
    final t = await repo.read();
    expect(t.rain24hMm, 80);
    expect(t.fireDryDays, 10);
    expect(t.windGustKmh, 60); // padrão mantido
    await repo.reset();
    expect((await repo.read()).rain24hMm, 50);
  });

  test('limiar mais alto deixa de gerar o alerta', () {
    final s = WeatherSnapshot(
      collectedAt: DateTime(2026, 11, 15),
      rain24hMm: 60,
      forecastRain6hMm: 0,
      windGustKmh: 10,
      humidityPct: 70,
      tempC: 24,
      soilMoisturePct: 40,
      daysWithoutRain: 0,
      slopeRisk: 0.2,
    );
    expect(
      const AlertEngine().evaluate(s).map((a) => a.type),
      contains(AlertType.heavyRain),
    );
    expect(
      const AlertEngine(thresholds: AlertThresholds(rain24hMm: 80)).evaluate(s),
      isEmpty,
    );
  });
}
