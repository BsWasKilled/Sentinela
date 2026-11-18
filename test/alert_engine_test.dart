import 'package:sentinela/features/alerts/domain/alert_engine.dart';
import 'package:sentinela/features/alerts/domain/alert_type.dart';
import 'package:sentinela/features/alerts/domain/territory_alert.dart';
import 'package:sentinela/features/alerts/domain/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

WeatherSnapshot snap({
  double rain24h = 0,
  double forecast6h = 0,
  double gust = 10,
  double humidity = 60,
  double temp = 25,
  double soil = 40,
  int dryDays = 0,
  double slope = 0.2,
  bool stale = false,
}) =>
    WeatherSnapshot(
      collectedAt: DateTime(2026, 11, 9),
      rain24hMm: rain24h,
      forecastRain6hMm: forecast6h,
      windGustKmh: gust,
      humidityPct: humidity,
      tempC: temp,
      soilMoisturePct: soil,
      daysWithoutRain: dryDays,
      slopeRisk: slope,
      isStale: stale,
    );

void main() {
  const engine = AlertEngine();

  test('condições calmas não geram alertas', () {
    expect(engine.evaluate(snap()), isEmpty);
  });

  test('chuva forte em encosta saturada gera deslizamento e alagamento', () {
    final types = engine
        .evaluate(snap(rain24h: 80, forecast6h: 25, soil: 90, slope: 0.8))
        .map((a) => a.type);
    expect(types, containsAll([AlertType.heavyRain, AlertType.flooding, AlertType.landslide]));
  });

  test('prioridade cresce com a intensidade da chuva', () {
    AlertPriority rainPriority(double mm) => engine
        .evaluate(snap(rain24h: mm))
        .firstWhere((a) => a.type == AlertType.heavyRain)
        .priority;
    expect(rainPriority(55), AlertPriority.low);
    expect(rainPriority(62), AlertPriority.medium);
    expect(rainPriority(80), AlertPriority.high);
  });

  test('dados em cache reduzem a confiança', () {
    final fresh = engine.evaluate(snap(gust: 80)).first.confidence;
    final stale = engine.evaluate(snap(gust: 80, stale: true)).first.confidence;
    expect(stale, lessThan(fresh));
  });

  test('todo alerta traz evidência e limitações', () {
    for (final a in engine.evaluate(snap(rain24h: 80, gust: 80, temp: 38))) {
      expect(a.evidence, isNotEmpty);
      expect(a.limitations, isNotEmpty);
    }
  });
}
