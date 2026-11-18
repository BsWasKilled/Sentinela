import '../../territory/domain/daily_reading.dart';
import '../../territory/domain/territory.dart';
import '../../territory/domain/trend.dart';
import 'alert_thresholds.dart';
import 'alert_type.dart';
import 'territory_alert.dart';
import 'weather_snapshot.dart';

/// Motor de regras: transforma leituras e tendências em alertas explicáveis.
///
/// Método: limiares configuráveis sobre a leitura atual, reforçados pela
/// tendência dos últimos 7 dias. A confiança cresce com o número de sinais
/// que concordam e cai quando os dados vêm do cache.
class AlertEngine {
  const AlertEngine({this.thresholds = const AlertThresholds()});

  final AlertThresholds thresholds;

  List<TerritoryAlert> evaluate(
    WeatherSnapshot s, {
    List<DailyReading> history = const [],
  }) {
    final alerts = <TerritoryAlert?>[
      _heavyRain(s, history),
      _flooding(s, history),
      _landslide(s),
      _strongWind(s),
      _wildfire(s),
      _heatWave(s, history),
      _waterWaste(s, history),
      _energyPeak(s, history),
    ].whereType<TerritoryAlert>().toList();
    alerts.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return alerts;
  }

  AlertPriority? _priority(double ratio) {
    if (ratio >= 1.5) return AlertPriority.high;
    if (ratio >= 1.2) return AlertPriority.medium;
    if (ratio >= 1.0) return AlertPriority.low;
    return null;
  }

  double _confidence(WeatherSnapshot s, int confirmed, int total) {
    final base = 0.5 + 0.4 * (confirmed / total);
    return (s.isStale ? base - 0.15 : base).clamp(0.0, 0.95);
  }

  List<String> _baseLimits(WeatherSnapshot s, String extra) => [
        extra,
        if (s.isStale) 'Dados vindos do cache: podem estar desatualizados.',
        'Regra baseada em limiares; não considera microclima de cada rua.',
      ];

  String? _trendEvidence(String what, Trend? t) {
    if (t == null || t.direction == TrendDirection.stable) return null;
    return '$what ${t.direction.label}: ${t.summary}.';
  }

  TerritoryAlert? _heavyRain(WeatherSnapshot s, List<DailyReading> h) {
    final sev = _priority(s.rain24hMm / thresholds.rain24hMm);
    if (sev == null) return null;
    final trend = h.isEmpty ? null : Trend.of([for (final r in h) r.rainMm]);
    final trendUp = trend?.direction == TrendDirection.up;
    return TerritoryAlert(
      type: AlertType.heavyRain,
      priority: sev,
      confidence: _confidence(
        s,
        1 + (s.forecastRain6hMm > 0 ? 1 : 0) + (trendUp ? 1 : 0),
        3,
      ),
      evidence: [
        'Chuva acumulada em 24h: ${s.rain24hMm.toStringAsFixed(0)} mm '
            '(limiar ${thresholds.rain24hMm.toStringAsFixed(0)} mm).',
        'Previsão para as próximas 6h: ${s.forecastRain6hMm.toStringAsFixed(0)} mm.',
        ?_trendEvidence('Chuva diária', trend),
      ],
      limitations: _baseLimits(s, 'Previsão de curto prazo perde precisão em chuvas convectivas.'),
      suggestedAction: 'Avaliar mobilização de equipes e comunicar a população.',
      generatedAt: s.collectedAt,
    );
  }

  TerritoryAlert? _flooding(WeatherSnapshot s, List<DailyReading> h) {
    final signals = [
      s.rain24hMm >= thresholds.rain24hMm * 0.6,
      s.forecastRain6hMm >= 20,
      s.soilMoisturePct >= 80,
    ];
    final confirmed = signals.where((e) => e).length;
    final sev = _priority((s.rain24hMm + s.forecastRain6hMm) / thresholds.floodMm);
    if (confirmed < 2 || sev == null) return null;
    final trend = h.isEmpty ? null : Trend.of([for (final r in h) r.rainMm]);
    return TerritoryAlert(
      type: AlertType.flooding,
      priority: sev,
      confidence: _confidence(s, confirmed, signals.length),
      evidence: [
        'Chuva 24h + previsão 6h: ${(s.rain24hMm + s.forecastRain6hMm).toStringAsFixed(0)} mm '
            '(limiar ${thresholds.floodMm.toStringAsFixed(0)} mm).',
        'Umidade do solo: ${s.soilMoisturePct.toStringAsFixed(0)}% (solo saturado reduz infiltração).',
        ?_trendEvidence('Chuva diária', trend),
      ],
      limitations: _baseLimits(s, 'Sem dados de drenagem urbana nem nível de rios.'),
      suggestedAction: 'Checar pontos históricos de alagamento e a limpeza de bueiros.',
      generatedAt: s.collectedAt,
      location: 'Beira-Rio, Centro',
    );
  }

  TerritoryAlert? _landslide(WeatherSnapshot s) {
    final signals = [
      s.slopeRisk >= 0.5,
      s.soilMoisturePct >= 75,
      s.rain24hMm >= thresholds.landslideRainMm,
    ];
    if (signals.any((e) => !e)) return null;
    final sev = _priority(s.rain24hMm / thresholds.landslideRainMm * (0.8 + s.slopeRisk * 0.5)) ??
        AlertPriority.low;
    final regions = Territory.slopeRegions.map((r) => r.name).join(', ');
    return TerritoryAlert(
      type: AlertType.landslide,
      priority: sev,
      confidence: _confidence(s, 3, 3) - 0.1,
      evidence: [
        'Suscetibilidade do terreno: ${(s.slopeRisk * 100).toStringAsFixed(0)}% em $regions.',
        'Solo a ${s.soilMoisturePct.toStringAsFixed(0)}% de umidade com '
            '${s.rain24hMm.toStringAsFixed(0)} mm em 24h.',
      ],
      limitations: _baseLimits(s, 'Mapa de suscetibilidade é estático e pode estar defasado.'),
      suggestedAction: 'Priorizar vistoria em encostas e avaliar contato com a Defesa Civil.',
      generatedAt: s.collectedAt,
      location: regions,
    );
  }

  TerritoryAlert? _strongWind(WeatherSnapshot s) {
    final sev = _priority(s.windGustKmh / thresholds.windGustKmh);
    if (sev == null) return null;
    return TerritoryAlert(
      type: AlertType.strongWind,
      priority: sev,
      confidence: _confidence(s, 1, 2),
      evidence: [
        'Rajadas de ${s.windGustKmh.toStringAsFixed(0)} km/h '
            '(limiar ${thresholds.windGustKmh.toStringAsFixed(0)} km/h).',
      ],
      limitations: _baseLimits(s, 'Rajadas variam muito entre bairros e a estação pode estar distante.'),
      suggestedAction: 'Alertar sobre queda de árvores e galhos na rede elétrica.',
      generatedAt: s.collectedAt,
    );
  }

  TerritoryAlert? _wildfire(WeatherSnapshot s) {
    final signals = [
      s.humidityPct <= thresholds.fireHumidityPct,
      s.tempC >= thresholds.fireTempC,
      s.daysWithoutRain >= thresholds.fireDryDays,
      s.windGustKmh >= 30,
    ];
    final confirmed = signals.where((e) => e).length;
    if (confirmed < 3) return null;
    return TerritoryAlert(
      type: AlertType.wildfire,
      priority: confirmed == 4 ? AlertPriority.medium : AlertPriority.low,
      confidence: _confidence(s, confirmed, signals.length),
      evidence: [
        'Umidade do ar: ${s.humidityPct.toStringAsFixed(0)}%, temperatura: ${s.tempC.toStringAsFixed(0)} °C.',
        '${s.daysWithoutRain} dias sem chuva e rajadas de ${s.windGustKmh.toStringAsFixed(0)} km/h.',
      ],
      limitations: _baseLimits(s, 'Não considera o tipo de vegetação nem focos de calor por satélite.'),
      suggestedAction: 'Reforçar campanhas de prevenção e monitorar áreas de vegetação seca.',
      generatedAt: s.collectedAt,
      location: 'Zona Rural, Alto da Serra',
    );
  }

  TerritoryAlert? _heatWave(WeatherSnapshot s, List<DailyReading> h) {
    final sev = _priority(s.tempC / thresholds.heatTempC);
    if (sev == null) return null;
    final trend = h.isEmpty ? null : Trend.of([for (final r in h) r.tempMaxC]);
    return TerritoryAlert(
      type: AlertType.heatWave,
      priority: sev == AlertPriority.low ? sev : AlertPriority.medium,
      confidence: _confidence(s, trend?.direction == TrendDirection.up ? 2 : 1, 2),
      evidence: [
        'Temperatura de ${s.tempC.toStringAsFixed(0)} °C (limiar ${thresholds.heatTempC.toStringAsFixed(0)} °C).',
        ?_trendEvidence('Temperatura máxima', trend),
      ],
      limitations: _baseLimits(s, 'Sensação térmica depende de umidade e ilhas de calor locais.'),
      suggestedAction: 'Ampliar pontos de hidratação e atenção a idosos e crianças.',
      generatedAt: s.collectedAt,
    );
  }

  /// Consumo de água da última semana bem acima da semana anterior.
  TerritoryAlert? _waterWaste(WeatherSnapshot s, List<DailyReading> h) {
    if (h.length < 14) return null;
    final trend = Trend.of([for (final r in h) r.waterM3]);
    if (trend.changePct < thresholds.waterIncreasePct) return null;
    final sev = _priority(trend.changePct / thresholds.waterIncreasePct) ??
        AlertPriority.low;
    return TerritoryAlert(
      type: AlertType.waterWaste,
      priority: sev,
      confidence: _confidence(s, s.rain24hMm < 1 ? 2 : 1, 2),
      evidence: [
        'Consumo médio de ${trend.recentMean.round()} m³/dia nos últimos 7 dias, '
            'contra ${trend.previousMean.round()} m³/dia na semana anterior '
            '(${trend.summary}).',
        'Limiar de atenção: alta de ${thresholds.waterIncreasePct.toStringAsFixed(0)}%.',
      ],
      limitations: _baseLimits(s, 'Consumo total do território: não aponta o ponto do vazamento.'),
      suggestedAction: 'Pedir à concessionária a leitura por setor e verificar vazamentos.',
      generatedAt: s.collectedAt,
    );
  }

  /// Demanda de energia do dia muito acima da média do mês.
  TerritoryAlert? _energyPeak(WeatherSnapshot s, List<DailyReading> h) {
    if (h.length < 7) return null;
    final values = [for (final r in h) r.energyMWh];
    final mean = meanOf(values);
    final today = values.last;
    final ratio = today / (mean * thresholds.energyPeakFactor);
    final sev = _priority(ratio);
    if (sev == null) return null;
    return TerritoryAlert(
      type: AlertType.energyPeak,
      priority: sev,
      confidence: _confidence(s, s.tempC >= thresholds.fireTempC ? 2 : 1, 2),
      evidence: [
        'Consumo de hoje: ${today.toStringAsFixed(1)} MWh, '
            'contra média de ${mean.toStringAsFixed(1)} MWh nos últimos ${h.length} dias.',
        'Limiar: ${((thresholds.energyPeakFactor - 1) * 100).round()}% acima da média.',
      ],
      limitations: _baseLimits(s, 'Não distingue consumo residencial de industrial.'),
      suggestedAction: 'Avisar a distribuidora e orientar a população sobre o horário de pico.',
      generatedAt: s.collectedAt,
    );
  }
}
