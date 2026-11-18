import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../territory/domain/geo.dart';

enum LocationFailure {
  serviceDisabled('Ative a localização do aparelho para usar este recurso.'),
  denied('Permissão de localização negada.'),
  deniedForever('Permissão negada permanentemente. Libere nas configurações do aparelho.'),
  timeout('Não foi possível obter a localização a tempo. Tente de novo.'),
  unknown('Não foi possível obter a localização.');

  const LocationFailure(this.message);
  final String message;
}

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => failure.message;
}

/// Obtém a posição atual uma única vez; nunca rastreia em segundo plano.
class LocationService {
  Future<GeoPoint> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationException(LocationFailure.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationException(LocationFailure.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(LocationFailure.deniedForever);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } on LocationException {
      rethrow;
    } on TimeoutException {
      throw const LocationException(LocationFailure.timeout);
    } catch (_) {
      throw const LocationException(LocationFailure.unknown);
    }
  }
}
