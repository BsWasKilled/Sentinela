import '../../alerts/domain/weather_snapshot.dart';
import 'daily_reading.dart';

/// Conjunto de dados do território: leitura atual + histórico diário.
class TerritoryDataset {
  const TerritoryDataset({
    required this.current,
    required this.history,
    required this.fetchedAt,
    this.source = syntheticSource,
  });

  static const syntheticSource = 'Dados sintéticos';

  factory TerritoryDataset.fromJson(Map<String, dynamic> json) =>
      TerritoryDataset(
        current: WeatherSnapshot.fromJson(
          json['current'] as Map<String, dynamic>,
        ),
        history: [
          for (final e in json['history'] as List<dynamic>)
            DailyReading.fromJson(e as Map<String, dynamic>),
        ],
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        source: json['source'] as String? ?? syntheticSource,
      );

  final WeatherSnapshot current;

  /// Do dia mais antigo para o mais recente.
  final List<DailyReading> history;
  final DateTime fetchedAt;

  /// De onde vieram os dados de clima (ex.: Open-Meteo ou sintéticos).
  final String source;

  bool get isReal => source != syntheticSource;

  bool get isStale => current.isStale;

  TerritoryDataset asStale() => TerritoryDataset(
        current: current.copyWith(isStale: true),
        history: history,
        fetchedAt: fetchedAt,
        source: source,
      );

  Map<String, dynamic> toJson() => {
        'current': current.toJson(),
        'history': [for (final r in history) r.toJson()],
        'fetchedAt': fetchedAt.toIso8601String(),
        'source': source,
      };
}
