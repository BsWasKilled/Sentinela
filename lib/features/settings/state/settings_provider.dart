import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/test_flags.dart';

/// Preferências do usuário (persistidas) e opções de teste (em memória).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({TestFlags? flags}) : flags = flags ?? TestFlags() {
    loaded = load();
  }

  /// Conclui quando as preferências salvas foram aplicadas.
  late final Future<void> loaded;

  static const minTextScale = 0.85;
  static const maxTextScale = 1.4;
  static const _themeKey = 'settings_theme_v2';
  static const _scaleKey = 'settings_text_scale_v1';
  static const _realWeatherKey = 'settings_real_weather_v1';
  static const _consentKey = 'consent_accepted_at_v1';

  final TestFlags flags;

  AppThemeChoice _theme = AppThemeChoice.dark;
  double _textScale = 1.0;
  DateTime? _consentAt;

  AppThemeChoice get theme => _theme;
  ThemeMode get themeMode => _theme.mode;
  bool get isHighContrast => _theme == AppThemeChoice.highContrast;
  double get textScale => _textScale;
  bool get useRealWeather => flags.useRealWeather;

  /// Quando o consentimento inicial foi aceito; nulo até o aceite.
  DateTime? get consentAt => _consentAt;
  bool get hasConsent => _consentAt != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _theme = AppThemeChoice.values.asNameMap()[prefs.getString(_themeKey)] ??
          AppThemeChoice.dark;
      _textScale = (prefs.getDouble(_scaleKey) ?? 1.0)
          .clamp(minTextScale, maxTextScale)
          .toDouble();
      flags.useRealWeather = prefs.getBool(_realWeatherKey) ?? true;
      final consent = prefs.getString(_consentKey);
      _consentAt = consent == null ? null : DateTime.tryParse(consent);
      notifyListeners();
    } catch (_) {
      // Sem preferências salvas: mantém os padrões.
    }
  }

  Future<void> setTheme(AppThemeChoice choice) async {
    _theme = choice;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, choice.name);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_scaleKey, value);
  }

  Future<void> acceptConsent() async {
    _consentAt = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consentKey, _consentAt!.toIso8601String());
  }

  /// Revoga o consentimento: o app volta à tela inicial de consentimento.
  Future<void> revokeConsent() async {
    _consentAt = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
  }

  Future<void> setRealWeather(bool value) async {
    flags.useRealWeather = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_realWeatherKey, value);
  }

  void setNetworkFailure(bool value) {
    flags.simulateNetworkFailure = value;
    notifyListeners();
  }

  void setSlowNetwork(bool value) {
    flags.simulateSlowNetwork = value;
    notifyListeners();
  }

  void setStorageError(bool value) {
    flags.simulateStorageError = value;
    notifyListeners();
  }

  void setScenario(DataScenario value) {
    flags.scenario = value;
    notifyListeners();
  }
}
