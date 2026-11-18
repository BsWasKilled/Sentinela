import 'dart:math';

import '../../settings/domain/test_flags.dart';
import 'daily_reading.dart';

/// Gera 30 dias de leituras sintéticas e determinísticas por cenário.
/// Substituir por uma API real mantendo o formato de [DailyReading].
abstract final class SyntheticHistory {
  static const days = 30;
  static const baseWaterM3 = 4200.0;
  static const baseEnergyMWh = 58.0;

  static List<DailyReading> generate(DataScenario scenario, DateTime endDate) {
    final random = Random(42);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final readings = <DailyReading>[];

    for (var i = 0; i < days; i++) {
      final date = end.subtract(Duration(days: days - 1 - i));
      final last7 = days - 1 - i; // 0 = hoje, 6 = há 6 dias
      final noise = random.nextDouble();

      double rain;
      double temp;
      double humidity;
      double wind;
      double water = baseWaterM3 + (noise - 0.5) * 300;
      double energy = baseEnergyMWh + (random.nextDouble() - 0.5) * 6;

      switch (scenario) {
        case DataScenario.storm:
          if (last7 <= 6) {
            const ramp = [15.0, 22.0, 30.0, 41.0, 55.0, 66.0, 78.0];
            rain = ramp[6 - last7];
            humidity = 70 + (6 - last7) * 3;
            wind = 28 + (6 - last7) * 4;
            temp = 25 - (6 - last7) * 0.4;
          } else {
            rain = noise < 0.4 ? 0 : noise * 14;
            humidity = 60 + random.nextDouble() * 12;
            wind = 10 + random.nextDouble() * 18;
            temp = 23 + random.nextDouble() * 5;
          }
        case DataScenario.calm:
          rain = noise < 0.5 ? 0 : noise * 7;
          humidity = 55 + random.nextDouble() * 12;
          wind = 8 + random.nextDouble() * 9;
          temp = 22 + random.nextDouble() * 5;
        case DataScenario.drought:
          rain = i < days - 21 ? (noise < 0.6 ? 0 : noise * 6) : 0;
          final progress = i / (days - 1);
          temp = 28 + progress * 9 + (random.nextDouble() - 0.5);
          humidity = 40 - progress * 22 + (random.nextDouble() - 0.5) * 3;
          wind = 20 + random.nextDouble() * 15;
          if (last7 <= 6) water = baseWaterM3 * 1.25 + (noise - 0.5) * 150;
          if (last7 == 0) energy = baseEnergyMWh * 1.3;
      }

      readings.add(DailyReading(
        date: date,
        rainMm: _round(rain),
        tempMaxC: _round(temp),
        humidityPct: _round(humidity),
        windGustKmh: _round(wind),
        waterM3: _round(water),
        energyMWh: _round(energy),
      ));
    }
    return readings;
  }

  static double _round(double v) => (v * 10).round() / 10;
}
