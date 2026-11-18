import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../alerts/domain/alert_thresholds.dart';

class ThresholdsRepository {
  static const _key = 'thresholds_v1';

  Future<AlertThresholds> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const AlertThresholds();
    return AlertThresholds.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AlertThresholds t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(t.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
