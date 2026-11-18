import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/daily_reading.dart';
import '../domain/geo.dart';

/// Um dia de clima vindo da Open-Meteo (sem água e energia).
class OpenMeteoDay {
  const OpenMeteoDay({
    required this.date,
    required this.rainMm,
    required this.tempMaxC,
    required this.humidityPct,
    required this.windGustKmh,
  });

  final DateTime date;
  final double rainMm;
  final double tempMaxC;
  final double humidityPct;
  final double windGustKmh;
}

class OpenMeteoForecast {
  const OpenMeteoForecast({
    required this.days,
    required this.forecastRain6hMm,
    required this.soilMoisturePct,
  });

  /// Do mais antigo até hoje.
  final List<OpenMeteoDay> days;
  final double forecastRain6hMm;
  final double soilMoisturePct;
}

/// Condições atuais num ponto (usadas no registro de relato).
class OpenMeteoCurrent {
  const OpenMeteoCurrent({
    required this.tempC,
    required this.humidityPct,
    required this.precipitationMmH,
    required this.windGustKmh,
  });

  final double tempC;
  final double humidityPct;
  final double precipitationMmH;
  final double windGustKmh;

  String get summary =>
      '${tempC.toStringAsFixed(0)} °C, umidade ${humidityPct.toStringAsFixed(0)}%, '
      'chuva ${precipitationMmH.toStringAsFixed(1)} mm/h, rajadas ${windGustKmh.toStringAsFixed(0)} km/h';
}

/// Cliente da API pública Open-Meteo (sem chave, licença CC BY 4.0).
class OpenMeteoClient {
  OpenMeteoClient({http.Client? client, DateTime Function()? now})
      : _client = client ?? http.Client(),
        _now = now ?? DateTime.now;

  static const sourceName = 'Open-Meteo';
  static const _base = 'https://api.open-meteo.com/v1/forecast';
  static const _timeout = Duration(seconds: 12);

  /// Umidade volumétrica considerada solo saturado (m³/m³).
  static const _saturatedSoil = 0.45;

  final http.Client _client;
  final DateTime Function() _now;

  Future<OpenMeteoForecast> forecast(GeoPoint point, {int pastDays = 30}) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'latitude': point.latitude.toString(),
      'longitude': point.longitude.toString(),
      'daily': 'precipitation_sum,temperature_2m_max,wind_gusts_10m_max',
      'hourly': 'precipitation,relative_humidity_2m,soil_moisture_0_to_1cm',
      'past_days': '$pastDays',
      'forecast_days': '2',
      'timezone': 'auto',
    });
    return parseForecast(await _getJson(uri), _now());
  }

  Future<OpenMeteoCurrent> current(GeoPoint point) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'latitude': point.latitude.toString(),
      'longitude': point.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,precipitation,wind_gusts_10m',
      'timezone': 'auto',
    });
    return parseCurrent(await _getJson(uri));
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('Open-Meteo respondeu ${response.statusCode}', uri);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static OpenMeteoCurrent parseCurrent(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    return OpenMeteoCurrent(
      tempC: _num(c['temperature_2m']),
      humidityPct: _num(c['relative_humidity_2m']),
      precipitationMmH: _num(c['precipitation']),
      windGustKmh: _num(c['wind_gusts_10m']),
    );
  }

  static OpenMeteoForecast parseForecast(Map<String, dynamic> json, DateTime now) {
    final daily = json['daily'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final today = DateTime(now.year, now.month, now.day);

    // Umidade média diária a partir das horas.
    final hourTimes = (hourly['time'] as List<dynamic>).cast<String>();
    final humidity = (hourly['relative_humidity_2m'] as List<dynamic>);
    final precipitation = (hourly['precipitation'] as List<dynamic>);
    final soil = (hourly['soil_moisture_0_to_1cm'] as List<dynamic>?) ?? const [];
    final humidityByDay = <String, List<double>>{};
    for (var i = 0; i < hourTimes.length; i++) {
      final value = humidity[i];
      if (value == null) continue;
      humidityByDay.putIfAbsent(hourTimes[i].substring(0, 10), () => []).add(_num(value));
    }

    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final rain = daily['precipitation_sum'] as List<dynamic>;
    final temp = daily['temperature_2m_max'] as List<dynamic>;
    final gust = daily['wind_gusts_10m_max'] as List<dynamic>;
    final days = <OpenMeteoDay>[];
    for (var i = 0; i < dates.length; i++) {
      final date = DateTime.parse(dates[i]);
      if (date.isAfter(today)) continue;
      final h = humidityByDay[dates[i]] ?? const [];
      days.add(OpenMeteoDay(
        date: date,
        rainMm: _num(rain[i]),
        tempMaxC: _num(temp[i]),
        humidityPct: h.isEmpty ? 0 : h.reduce((a, b) => a + b) / h.length,
        windGustKmh: _num(gust[i]),
      ));
    }

    // Próximas 6 horas a partir da hora atual.
    final nowHour = DateTime(now.year, now.month, now.day, now.hour);
    var start = hourTimes.indexWhere((t) => !DateTime.parse(t).isBefore(nowHour));
    if (start < 0) start = hourTimes.length - 6;
    var next6 = 0.0;
    for (var i = start; i < start + 6 && i < precipitation.length; i++) {
      next6 += _num(precipitation[i]);
    }

    final soilValue = start < soil.length ? soil[start] : null;
    final soilPct = soilValue == null
        ? 50.0
        : (_num(soilValue) / _saturatedSoil * 100).clamp(0.0, 100.0);

    return OpenMeteoForecast(
      days: days,
      forecastRain6hMm: (next6 * 10).round() / 10,
      soilMoisturePct: soilPct.toDouble(),
    );
  }

  static double _num(Object? v) => v == null ? 0 : (v as num).toDouble();
}

extension OpenMeteoDayToReading on OpenMeteoDay {
  /// Junta o clima real com consumo sintético de água e energia.
  DailyReading withResources({required double waterM3, required double energyMWh}) =>
      DailyReading(
        date: date,
        rainMm: rainMm,
        tempMaxC: tempMaxC,
        humidityPct: humidityPct,
        windGustKmh: windGustKmh,
        waterM3: waterM3,
        energyMWh: energyMWh,
      );
}
