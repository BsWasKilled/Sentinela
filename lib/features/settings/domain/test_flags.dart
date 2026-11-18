enum DataScenario {
  storm('Tempestade'),
  calm('Calmo'),
  drought('Seca');

  const DataScenario(this.label);
  final String label;
}

/// Opções de teste (não persistidas): simulam falhas e cenários de dados.
class TestFlags {
  /// Preferência persistida pelo SettingsProvider; false usa os cenários.
  bool useRealWeather = true;
  bool simulateNetworkFailure = false;
  bool simulateSlowNetwork = false;
  bool simulateStorageError = false;
  DataScenario scenario = DataScenario.storm;
}
