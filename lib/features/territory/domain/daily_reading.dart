/// Leitura diária consolidada do território.
class DailyReading {
  const DailyReading({
    required this.date,
    required this.rainMm,
    required this.tempMaxC,
    required this.humidityPct,
    required this.windGustKmh,
    required this.waterM3,
    required this.energyMWh,
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) => DailyReading(
        date: DateTime.parse(json['date'] as String),
        rainMm: (json['rainMm'] as num).toDouble(),
        tempMaxC: (json['tempMaxC'] as num).toDouble(),
        humidityPct: (json['humidityPct'] as num).toDouble(),
        windGustKmh: (json['windGustKmh'] as num).toDouble(),
        waterM3: (json['waterM3'] as num).toDouble(),
        energyMWh: (json['energyMWh'] as num).toDouble(),
      );

  final DateTime date;
  final double rainMm;
  final double tempMaxC;
  final double humidityPct;
  final double windGustKmh;

  /// Consumo diário de água do território.
  final double waterM3;

  /// Consumo diário de energia do território.
  final double energyMWh;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'rainMm': rainMm,
        'tempMaxC': tempMaxC,
        'humidityPct': humidityPct,
        'windGustKmh': windGustKmh,
        'waterM3': waterM3,
        'energyMWh': energyMWh,
      };
}
