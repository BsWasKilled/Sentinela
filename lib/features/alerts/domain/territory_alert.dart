import 'alert_type.dart';

enum AlertPriority {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const AlertPriority(this.label);
  final String label;

  /// Ex.: "Prioridade alta".
  String get fullLabel => 'Prioridade ${label.toLowerCase()}';
}

enum AlertSource {
  automatic('Gerado pelo sistema'),
  citizen('Relato registrado');

  const AlertSource(this.label);
  final String label;
}

class TerritoryAlert {
  TerritoryAlert({
    String? id,
    required this.type,
    required this.priority,
    required this.confidence,
    required this.evidence,
    required this.limitations,
    required this.suggestedAction,
    required this.generatedAt,
    this.source = AlertSource.automatic,
    this.location,
    this.latitude,
    this.longitude,
  }) : id = id ?? _autoId(type, generatedAt);

  /// Relato manual: confiança baixa por não ter verificação por sensores.
  factory TerritoryAlert.citizenReport({
    required AlertType type,
    required AlertPriority priority,
    required String location,
    required String description,
    required DateTime now,
    String? conditions,
    double? latitude,
    double? longitude,
  }) {
    final hasConditions = conditions != null && conditions.isNotEmpty;
    return TerritoryAlert(
      id: 'report-${now.microsecondsSinceEpoch}',
      type: type,
      priority: priority,
      // Relato com clima do momento anexado ganha um pouco de confiança.
      confidence: hasConditions ? 0.5 : 0.4,
      evidence: [
        'Relato: $description',
        if (hasConditions) 'Condições no momento (Open-Meteo): $conditions',
      ],
      limitations: [
        'Relato manual, sem verificação por sensores ou equipe técnica.',
        'A prioridade foi informada por quem registrou.',
        if (latitude != null) 'Localização aproximada (arredondada a cerca de 1 km).',
      ],
      suggestedAction: 'Verificar o relato no local antes de qualquer ação.',
      generatedAt: now,
      source: AlertSource.citizen,
      location: location,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory TerritoryAlert.fromJson(Map<String, dynamic> json) {
    return TerritoryAlert(
      id: json['id'] as String,
      type: AlertType.values.byName(json['type'] as String),
      priority: AlertPriority.values.byName(json['priority'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      evidence: List<String>.from(json['evidence'] as List),
      limitations: List<String>.from(json['limitations'] as List),
      suggestedAction: json['suggestedAction'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      source: AlertSource.values.byName(json['source'] as String),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  final String id;
  final AlertType type;
  final AlertPriority priority;

  /// 0 a 1. Reflete quantos sinais concordam e a qualidade dos dados.
  final double confidence;

  /// Evidências que justificam o alerta.
  final List<String> evidence;
  final List<String> limitations;
  final String suggestedAction;
  final DateTime generatedAt;
  final AlertSource source;
  final String? location;

  /// Coordenada aproximada do relato (opcional, arredondada por privacidade).
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority.name,
        'confidence': confidence,
        'evidence': evidence,
        'limitations': limitations,
        'suggestedAction': suggestedAction,
        'generatedAt': generatedAt.toIso8601String(),
        'source': source.name,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// O app apoia a decisão, nunca decide sozinho.
  static const humanDecisionNotice =
      'Este alerta apoia, mas não substitui, a decisão do gestor responsável.';

  static String _autoId(AlertType t, DateTime d) =>
      'auto-${t.name}-${d.year}${d.month}${d.day}';
}
