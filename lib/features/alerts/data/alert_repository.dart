import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/domain/test_flags.dart';
import '../domain/territory_alert.dart';

/// Persistência local: mantém o histórico disponível sem conexão.
class AlertRepository {
  AlertRepository([TestFlags? flags]) : _flags = flags ?? TestFlags();

  // v2: as prioridades passaram a ser Baixa, Média e Alta.
  static const _key = 'alerts_v2';

  final TestFlags _flags;

  Future<List<TerritoryAlert>> readAll() async {
    if (_flags.simulateStorageError) {
      throw Exception('Erro de armazenamento simulado');
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TerritoryAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<TerritoryAlert> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(alerts.map((a) => a.toJson()).toList()),
    );
  }
}
