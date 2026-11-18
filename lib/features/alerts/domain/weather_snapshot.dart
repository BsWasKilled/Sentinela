/// Leitura consolidada do território (API real, simulada ou cache local).
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.collectedAt,
    required this.rain24hMm,
    required this.forecastRain6hMm,
    required this.windGustKmh,
    required this.humidityPct,
    required this.tempC,
    required this.soilMoisturePct,
    required this.daysWithoutRain,
    required this.slopeRisk,
    this.isStale = false,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) =>
      WeatherSnapshot(
        collectedAt: DateTime.parse(json['collectedAt'] as String),
        rain24hMm: (json['rain24hMm'] as num).toDouble(),
        forecastRain6hMm: (json['forecastRain6hMm'] as num).toDouble(),
        windGustKmh: (json['windGustKmh'] as num).toDouble(),
        humidityPct: (json['humidityPct'] as num).toDouble(),
        tempC: (json['tempC'] as num).toDouble(),
        soilMoisturePct: (json['soilMoisturePct'] as num).toDouble(),
        daysWithoutRain: json['daysWithoutRain'] as int,
        slopeRisk: (json['slopeRisk'] as num).toDouble(),
        isStale: json['isStale'] as bool? ?? false,
      );

  final DateTime collectedAt;
  final double rain24hMm;
  final double forecastRain6hMm;
  final double windGustKmh;
  final double humidityPct;
  final double tempC;
  final double soilMoisturePct;
  final int daysWithoutRain;

  /// Suscetibilidade do terreno (0 a 1), dado estático do território.
  final double slopeRisk;

  /// true quando os dados vêm do cache e podem estar desatualizados.
  final bool isStale;

  WeatherSnapshot copyWith({bool? isStale}) => WeatherSnapshot(
        collectedAt: collectedAt,
        rain24hMm: rain24hMm,
        forecastRain6hMm: forecastRain6hMm,
        windGustKmh: windGustKmh,
        humidityPct: humidityPct,
        tempC: tempC,
        soilMoisturePct: soilMoisturePct,
        daysWithoutRain: daysWithoutRain,
        slopeRisk: slopeRisk,
        isStale: isStale ?? this.isStale,
      );

  Map<String, dynamic> toJson() => {
        'collectedAt': collectedAt.toIso8601String(),
        'rain24hMm': rain24hMm,
        'forecastRain6hMm': forecastRain6hMm,
        'windGustKmh': windGustKmh,
        'humidityPct': humidityPct,
        'tempC': tempC,
        'soilMoisturePct': soilMoisturePct,
        'daysWithoutRain': daysWithoutRain,
        'slopeRisk': slopeRisk,
        'isStale': isStale,
      };
}
