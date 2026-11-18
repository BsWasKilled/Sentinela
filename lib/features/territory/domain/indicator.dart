import 'package:flutter/material.dart';

import '../../alerts/domain/alert_type.dart';
import 'daily_reading.dart';

enum DashboardKind {
  climate('Clima', Icons.cloud_outlined),
  resources('Recursos', Icons.water_drop_outlined),
  services('Serviços', Icons.campaign_outlined);

  const DashboardKind(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Indicador do território com série histórica e alertas relacionados.
enum Indicator {
  rain(
    'Chuva',
    'mm',
    Icons.grain,
    DashboardKind.climate,
    [AlertType.heavyRain, AlertType.flooding, AlertType.landslide],
    'Estação meteorológica distante do bairro ou chuva convectiva muito localizada.',
  ),
  temperature(
    'Temperatura máxima',
    '°C',
    Icons.thermostat,
    DashboardKind.climate,
    [AlertType.heatWave, AlertType.wildfire],
    'Ilhas de calor urbanas e sensação térmica não são medidas.',
  ),
  humidity(
    'Umidade do ar',
    '%',
    Icons.water_outlined,
    DashboardKind.climate,
    [AlertType.wildfire],
    'Medida única para todo o território; varia muito entre vale e serra.',
  ),
  wind(
    'Rajada de vento',
    'km/h',
    Icons.air,
    DashboardKind.climate,
    [AlertType.strongWind, AlertType.wildfire],
    'Rajadas são pontuais; a média diária esconde picos curtos.',
  ),
  water(
    'Consumo de água',
    'm³/dia',
    Icons.water_drop,
    DashboardKind.resources,
    [AlertType.waterWaste],
    'Feriados, obras e eventos elevam o consumo sem indicar vazamento.',
  ),
  energy(
    'Consumo de energia',
    'MWh/dia',
    Icons.bolt,
    DashboardKind.resources,
    [AlertType.energyPeak],
    'Ondas de calor e dias úteis elevam a demanda de forma esperada.',
  );

  const Indicator(
    this.label,
    this.unit,
    this.icon,
    this.dashboard,
    this.relatedTypes,
    this.reliabilityNote,
  );

  final String label;
  final String unit;
  final IconData icon;
  final DashboardKind dashboard;
  final List<AlertType> relatedTypes;

  /// Quando a leitura deste indicador deixa de ser confiável.
  final String reliabilityNote;

  List<double> series(List<DailyReading> history) => [
        for (final r in history)
          switch (this) {
            Indicator.rain => r.rainMm,
            Indicator.temperature => r.tempMaxC,
            Indicator.humidity => r.humidityPct,
            Indicator.wind => r.windGustKmh,
            Indicator.water => r.waterM3,
            Indicator.energy => r.energyMWh,
          },
      ];

  /// Chuva é soma; os demais são média.
  bool get isCumulative => this == Indicator.rain;

  String format(double value) => switch (this) {
        Indicator.water => value.round().toString(),
        _ => value.toStringAsFixed(value >= 100 ? 0 : 1),
      };
}
