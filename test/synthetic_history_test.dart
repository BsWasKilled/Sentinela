import 'package:sentinela/features/alerts/domain/alert_engine.dart';
import 'package:sentinela/features/alerts/domain/alert_type.dart';
import 'package:sentinela/features/settings/domain/test_flags.dart';
import 'package:sentinela/features/territory/data/territory_repository.dart';
import 'package:sentinela/features/territory/domain/synthetic_history.dart';
import 'package:sentinela/features/territory/domain/territory_dataset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final end = DateTime(2026, 11, 13);

  test('gera 30 dias em ordem e de forma determinística', () {
    final a = SyntheticHistory.generate(DataScenario.storm, end);
    final b = SyntheticHistory.generate(DataScenario.storm, end);
    expect(a.length, 30);
    expect(a.first.date, DateTime(2026, 10, 15));
    expect(a.last.date, end);
    expect([for (final r in a) r.rainMm], [for (final r in b) r.rainMm]);
  });

  test('cenário de tempestade termina com a chuva do snapshot (78 mm)', () {
    final h = SyntheticHistory.generate(DataScenario.storm, end);
    expect(h.last.rainMm, 78);
  });

  test('cenário de seca gera alertas de água e energia', () async {
    final repo = TerritoryRepository(TestFlags()
      ..useRealWeather = false
      ..scenario = DataScenario.drought);
    final data = await repo.fetch();
    final types = const AlertEngine()
        .evaluate(data.current, history: data.history)
        .map((a) => a.type)
        .toSet();
    expect(types, containsAll([AlertType.waterWaste, AlertType.energyPeak, AlertType.wildfire]));
    expect(types, isNot(contains(AlertType.flooding)));
  });

  test('cenário calmo não gera alertas', () async {
    final repo = TerritoryRepository(TestFlags()
      ..useRealWeather = false
      ..scenario = DataScenario.calm);
    final data = await repo.fetch();
    expect(const AlertEngine().evaluate(data.current, history: data.history), isEmpty);
  });

  test('dataset sobrevive ao ciclo JSON e vira cache obsoleto', () async {
    final repo = TerritoryRepository(TestFlags()..useRealWeather = false);
    final data = await repo.fetch();
    final copy = TerritoryDataset.fromJson(data.toJson()).asStale();
    expect(copy.history.length, data.history.length);
    expect(copy.current.rain24hMm, data.current.rain24hMm);
    expect(copy.isStale, isTrue);
  });
}
