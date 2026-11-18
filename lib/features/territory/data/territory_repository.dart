import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../alerts/domain/weather_snapshot.dart';
import '../../settings/domain/test_flags.dart';
import '../domain/daily_reading.dart';
import '../domain/synthetic_history.dart';
import '../domain/territory.dart';
import '../domain/territory_dataset.dart';
import 'open_meteo_client.dart';

/// Fonte de dados do território: clima real (Open-Meteo) ou cenários
/// sintéticos. Água e energia são sempre sintéticos, por falta de uma
/// API pública com consumo diário por município.
class TerritoryRepository {
  TerritoryRepository([TestFlags? flags, OpenMeteoClient? openMeteo])
      : _flags = flags ?? TestFlags(),
        _openMeteo = openMeteo ?? OpenMeteoClient();

  static const _cacheKey = 'territory_dataset_v2';

  final TestFlags _flags;
  final OpenMeteoClient _openMeteo;

  Future<TerritoryDataset> fetch() async {
    if (_flags.simulateSlowNetwork) {
      await Future<void>.delayed(const Duration(seconds: 4));
    }
    if (_flags.simulateNetworkFailure) {
      throw Exception('Falha de rede simulada');
    }
    return _flags.useRealWeather ? _fetchReal() : _fetchSynthetic();
  }

  Future<TerritoryDataset> _fetchReal() async {
    final now = DateTime.now();
    final forecast = await _openMeteo.forecast(Territory.center);
    if (forecast.days.isEmpty) throw Exception('Open-Meteo sem dados diários');

    // Consumo sintético estável, alinhado dia a dia ao clima real.
    final synthetic = SyntheticHistory.generate(DataScenario.calm, now);
    final history = <DailyReading>[];
    for (var i = 0; i < forecast.days.length; i++) {
      final s = synthetic[(synthetic.length - forecast.days.length + i).clamp(0, synthetic.length - 1)];
      history.add(forecast.days[i].withResources(
        waterM3: s.waterM3,
        energyMWh: s.energyMWh,
      ));
    }
    final today = history.last;
    return TerritoryDataset(
      current: WeatherSnapshot(
        collectedAt: now,
        rain24hMm: today.rainMm,
        forecastRain6hMm: forecast.forecastRain6hMm,
        windGustKmh: today.windGustKmh,
        humidityPct: today.humidityPct,
        tempC: today.tempMaxC,
        soilMoisturePct: forecast.soilMoisturePct,
        daysWithoutRain: _dryDays(history),
        slopeRisk: Territory.maxSlopeRisk,
      ),
      history: history,
      fetchedAt: now,
      source: OpenMeteoClient.sourceName,
    );
  }

  Future<TerritoryDataset> _fetchSynthetic() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    final history = SyntheticHistory.generate(_flags.scenario, now);
    final today = history.last;
    final (forecast, soil) = switch (_flags.scenario) {
      DataScenario.storm => (25.0, 86.0),
      DataScenario.calm => (0.0, 40.0),
      DataScenario.drought => (0.0, 15.0),
    };
    return TerritoryDataset(
      current: WeatherSnapshot(
        collectedAt: now,
        rain24hMm: today.rainMm,
        forecastRain6hMm: forecast,
        windGustKmh: today.windGustKmh,
        humidityPct: today.humidityPct,
        tempC: today.tempMaxC,
        soilMoisturePct: soil,
        daysWithoutRain: _dryDays(history),
        slopeRisk: Territory.maxSlopeRisk,
      ),
      history: history,
      fetchedAt: now,
      source: '${TerritoryDataset.syntheticSource} (${_flags.scenario.label})',
    );
  }

  static int _dryDays(List<DailyReading> history) {
    var dryDays = 0;
    for (final r in history.reversed) {
      if (r.rainMm > 0.5) break;
      dryDays++;
    }
    return dryDays;
  }

  Future<TerritoryDataset?> readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    return TerritoryDataset.fromJson(jsonDecode(raw) as Map<String, dynamic>)
        .asStale();
  }

  Future<void> saveCache(TerritoryDataset dataset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(dataset.toJson()));
  }
}
