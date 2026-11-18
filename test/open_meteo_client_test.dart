import 'dart:convert';

import 'package:sentinela/features/territory/data/open_meteo_client.dart';
import 'package:sentinela/features/territory/domain/geo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> sampleForecast() {
  // 3 dias (2 passados + hoje) + 1 dia futuro, 24 horas cada.
  final days = ['2026-11-11', '2026-11-12', '2026-11-13', '2026-11-14'];
  final hours = <String>[];
  final humidity = <double>[];
  final precipitation = <double>[];
  final soil = <double?>[];
  for (final d in days) {
    for (var h = 0; h < 24; h++) {
      hours.add('${d}T${h.toString().padLeft(2, '0')}:00');
      humidity.add(d == '2026-11-13' ? 80 : 60);
      // No dia 13, chove 2 mm/h das 14h às 19h.
      precipitation.add(d == '2026-11-13' && h >= 14 && h < 20 ? 2 : 0);
      soil.add(0.45 * 0.9);
    }
  }
  return {
    'daily': {
      'time': days,
      'precipitation_sum': [0, 5.5, 12, 30],
      'temperature_2m_max': [25, 26, 27.5, 30],
      'wind_gusts_10m_max': [20, 33, 41, 60],
    },
    'hourly': {
      'time': hours,
      'precipitation': precipitation,
      'relative_humidity_2m': humidity,
      'soil_moisture_0_to_1cm': soil,
    },
  };
}

void main() {
  final now = DateTime(2026, 11, 13, 14, 20);

  test('parseForecast ignora o futuro, soma 6h e calcula umidade média', () {
    final f = OpenMeteoClient.parseForecast(sampleForecast(), now);
    expect(f.days.length, 3);
    expect(f.days.last.date, DateTime(2026, 11, 13));
    expect(f.days.last.rainMm, 12);
    expect(f.days.last.humidityPct, 80);
    expect(f.days.first.humidityPct, 60);
    expect(f.forecastRain6hMm, 12); // 14h..19h = 6 horas de 2 mm
    expect(f.soilMoisturePct, closeTo(90, 0.01));
  });

  test('parseCurrent monta o resumo', () {
    final c = OpenMeteoClient.parseCurrent({
      'current': {
        'temperature_2m': 24.3,
        'relative_humidity_2m': 71,
        'precipitation': 0.4,
        'wind_gusts_10m': 18,
      },
    });
    expect(c.summary, contains('24 °C'));
    expect(c.summary, contains('0.4 mm/h'));
  });

  test('forecast chama a API com as coordenadas e trata erro HTTP', () async {
    late Uri called;
    final ok = OpenMeteoClient(
      now: () => now,
      client: MockClient((req) async {
        called = req.url;
        return http.Response(jsonEncode(sampleForecast()), 200);
      }),
    );
    final f = await ok.forecast(const GeoPoint(-23.55, -46.63));
    expect(f.days, isNotEmpty);
    expect(called.queryParameters['latitude'], '-23.55');
    expect(called.queryParameters['past_days'], '30');

    final failing = OpenMeteoClient(
      client: MockClient((_) async => http.Response('erro', 500)),
    );
    await expectLater(
      failing.forecast(const GeoPoint(0, 0)),
      throwsA(isA<http.ClientException>()),
    );
  });
}
