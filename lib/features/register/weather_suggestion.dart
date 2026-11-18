import '../alerts/domain/alert_type.dart';
import '../territory/data/open_meteo_client.dart';

/// Sugere um tipo de relato a partir das condições do momento.
/// É só uma sugestão: a pessoa escolhe o tipo final.
abstract final class WeatherSuggestion {
  static AlertType? suggestType(OpenMeteoCurrent c) {
    if (c.precipitationMmH >= 10) return AlertType.flooding;
    if (c.precipitationMmH >= 4) return AlertType.heavyRain;
    if (c.windGustKmh >= 50) return AlertType.strongWind;
    if (c.tempC >= 32 && c.humidityPct <= 30) return AlertType.wildfire;
    if (c.tempC >= 35) return AlertType.heatWave;
    return null;
  }
}
