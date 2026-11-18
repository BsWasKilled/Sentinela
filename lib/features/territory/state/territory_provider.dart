import 'package:flutter/foundation.dart';

import '../../alerts/data/alert_repository.dart';
import '../../alerts/domain/alert_engine.dart';
import '../../alerts/domain/alert_thresholds.dart';
import '../../alerts/domain/alert_type.dart';
import '../../alerts/domain/territory_alert.dart';
import '../../settings/domain/test_flags.dart';
import '../../thresholds/thresholds_repository.dart';
import '../data/territory_repository.dart';
import '../domain/territory.dart';
import '../domain/territory_dataset.dart';

enum LoadStatus { loading, ready, error }

/// Indicadores de benefício social derivados dos dados.
class SocialImpact {
  const SocialImpact({
    required this.residentsReached,
    required this.reportCount,
    required this.regionsWithReports,
  });

  /// Moradores das regiões cobertas por alertas das últimas 24h.
  final int residentsReached;
  final int reportCount;
  final int regionsWithReports;
}

/// Estado global compartilhado por início, dashboards, histórico,
/// registro, perfil e configurações.
class TerritoryProvider extends ChangeNotifier {
  TerritoryProvider({
    TestFlags? flags,
    AlertRepository? alerts,
    TerritoryRepository? territory,
    ThresholdsRepository? thresholds,
  })  : _alerts = alerts ?? AlertRepository(flags),
        _territory = territory ?? TerritoryRepository(flags),
        _thresholdsRepo = thresholds ?? ThresholdsRepository();

  final AlertRepository _alerts;
  final TerritoryRepository _territory;
  final ThresholdsRepository _thresholdsRepo;
  AlertEngine _engine = const AlertEngine();

  AlertThresholds get thresholds => _engine.thresholds;

  List<TerritoryAlert> _items = [];
  TerritoryDataset? _dataset;
  LoadStatus _status = LoadStatus.loading;
  bool _offline = false;
  bool _refreshing = false;

  LoadStatus get status => _status;

  /// true quando a fonte externa falhou e o app mostra dados salvos.
  bool get isOffline => _offline;
  bool get isRefreshing => _refreshing;

  /// Dados do território (atual + 30 dias). Nulo até a primeira carga.
  TerritoryDataset? get dataset => _dataset;

  /// Todos os alertas, do mais recente para o mais antigo.
  List<TerritoryAlert> get all => List.unmodifiable(
        [..._items]..sort((a, b) => b.generatedAt.compareTo(a.generatedAt)),
      );

  List<TerritoryAlert> get recent => all.take(3).toList();

  /// Relatos registrados por cidadãos.
  List<TerritoryAlert> get reports =>
      all.where((a) => a.source == AlertSource.citizen).toList();

  int get citizenReportCount => reports.length;

  List<TerritoryAlert> reportsWhere({String? region, AlertType? type}) =>
      reports
          .where((a) => region == null || a.location == region)
          .where((a) => type == null || a.type == type)
          .toList();

  /// Alertas ligados a um grupo de tipos (usado no detalhe do indicador).
  List<TerritoryAlert> alertsOfTypes(List<AlertType> types) =>
      all.where((a) => types.contains(a.type)).toList();

  SocialImpact get socialImpact {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final active = _items.where((a) => a.generatedAt.isAfter(cutoff)).toList();
    final hasTerritoryWide = active.any(
      (a) => a.source == AlertSource.automatic && a.location == null,
    );
    final regions = <String>{};
    for (final a in active) {
      final loc = a.location;
      if (loc == null) continue;
      for (final part in loc.split(',')) {
        regions.add(part.trim());
      }
    }
    final reached = hasTerritoryWide
        ? Territory.population
        : Territory.regions
            .where((r) => regions.contains(r.name))
            .fold(0, (sum, r) => sum + r.population);
    final reportRegions = reports.map((a) => a.location).whereType<String>().toSet();
    return SocialImpact(
      residentsReached: reached,
      reportCount: reports.length,
      regionsWithReports: reportRegions.length,
    );
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _items = await _alerts.readAll();
      _dataset = await _territory.readCache();
      _engine = AlertEngine(thresholds: await _thresholdsRepo.read());
    } catch (_) {
      _status = LoadStatus.error;
      notifyListeners();
      return;
    }
    // Mostra o cache imediatamente e depois tenta atualizar.
    _status = LoadStatus.ready;
    notifyListeners();
    await _refreshFromSource();
  }

  Future<void> refresh() => _refreshFromSource();

  Future<void> _refreshFromSource() async {
    _refreshing = true;
    notifyListeners();
    try {
      final dataset = await _territory.fetch();
      final generated = _engine.evaluate(
        dataset.current,
        history: dataset.history,
      );
      final ids = generated.map((a) => a.id).toSet();
      _items = [..._items.where((a) => !ids.contains(a.id)), ...generated];
      _dataset = dataset;
      _offline = false;
      await _alerts.saveAll(_items);
      await _territory.saveCache(dataset);
    } catch (_) {
      _offline = true;
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<void> addCitizenReport({
    required AlertType type,
    required AlertPriority priority,
    required String location,
    required String description,
    String? conditions,
    double? latitude,
    double? longitude,
  }) async {
    final report = TerritoryAlert.citizenReport(
      type: type,
      priority: priority,
      location: location.trim(),
      description: description.trim(),
      now: DateTime.now(),
      conditions: conditions,
      latitude: latitude,
      longitude: longitude,
    );
    _items = [..._items, report];
    notifyListeners();
    await _alerts.saveAll(_items);
  }

  /// Troca os limiares e recalcula os alertas automáticos com os dados atuais.
  Future<void> setThresholds(AlertThresholds t) async {
    _engine = AlertEngine(thresholds: t);
    await _thresholdsRepo.save(t);
    _reevaluate();
  }

  Future<void> resetThresholds() async {
    await _thresholdsRepo.reset();
    _engine = const AlertEngine();
    _reevaluate();
  }

  void _reevaluate() {
    final d = _dataset;
    if (d != null) {
      final generated = _engine.evaluate(d.current, history: d.history);
      _items = [
        ..._items.where((a) => a.source == AlertSource.citizen),
        ...generated,
      ];
      _alerts.saveAll(_items);
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items = [];
    notifyListeners();
    await _alerts.saveAll(_items);
  }
}
