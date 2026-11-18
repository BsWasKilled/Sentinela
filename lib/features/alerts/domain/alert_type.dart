import 'package:flutter/material.dart';

enum AlertType {
  heavyRain('Chuva intensa', Icons.grain),
  flooding('Alagamento', Icons.flood),
  landslide('Deslizamento', Icons.landslide),
  strongWind('Vento forte', Icons.air),
  wildfire('Risco de incêndio', Icons.local_fire_department),
  heatWave('Onda de calor', Icons.thermostat),
  waterWaste('Desperdício de água', Icons.water_drop),
  energyPeak('Pico de energia', Icons.bolt);

  const AlertType(this.label, this.icon);
  final String label;
  final IconData icon;
}
