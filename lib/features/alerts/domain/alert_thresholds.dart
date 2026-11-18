/// Limiares que disparam os alertas. Editáveis no app e persistidos.
class AlertThresholds {
  const AlertThresholds({
    this.rain24hMm = 50,
    this.floodMm = 70,
    this.landslideRainMm = 40,
    this.windGustKmh = 60,
    this.fireHumidityPct = 30,
    this.fireTempC = 32,
    this.fireDryDays = 7,
    this.heatTempC = 35,
    this.waterIncreasePct = 20,
    this.energyPeakFactor = 1.25,
  });

  factory AlertThresholds.fromJson(Map<String, dynamic> json) {
    const d = AlertThresholds();
    double n(String k, double fallback) => (json[k] as num?)?.toDouble() ?? fallback;
    return AlertThresholds(
      rain24hMm: n('rain24hMm', d.rain24hMm),
      floodMm: n('floodMm', d.floodMm),
      landslideRainMm: n('landslideRainMm', d.landslideRainMm),
      windGustKmh: n('windGustKmh', d.windGustKmh),
      fireHumidityPct: n('fireHumidityPct', d.fireHumidityPct),
      fireTempC: n('fireTempC', d.fireTempC),
      fireDryDays: (json['fireDryDays'] as num?)?.toInt() ?? d.fireDryDays,
      heatTempC: n('heatTempC', d.heatTempC),
      waterIncreasePct: n('waterIncreasePct', d.waterIncreasePct),
      energyPeakFactor: n('energyPeakFactor', d.energyPeakFactor),
    );
  }

  final double rain24hMm;
  final double floodMm;
  final double landslideRainMm;
  final double windGustKmh;
  final double fireHumidityPct;
  final double fireTempC;
  final int fireDryDays;
  final double heatTempC;

  /// Alta percentual do consumo de água semanal que gera alerta.
  final double waterIncreasePct;

  /// Fator sobre a média mensal de energia que gera alerta.
  final double energyPeakFactor;

  Map<String, dynamic> toJson() => {
        'rain24hMm': rain24hMm,
        'floodMm': floodMm,
        'landslideRainMm': landslideRainMm,
        'windGustKmh': windGustKmh,
        'fireHumidityPct': fireHumidityPct,
        'fireTempC': fireTempC,
        'fireDryDays': fireDryDays,
        'heatTempC': heatTempC,
        'waterIncreasePct': waterIncreasePct,
        'energyPeakFactor': energyPeakFactor,
      };
}
