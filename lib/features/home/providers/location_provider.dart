import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Obtiene la ciudad actual del dispositivo mediante geolocalización y geocodificación.
final deviceCityProvider = FutureProvider<String?>((ref) async {
  // 1️⃣ Verificar permisos
  LocationPermission perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.deniedForever ||
      perm == LocationPermission.denied) {
    // Usuario negó permisos → devolvemos null para mantener la app estable
    return null;
  }

  // 2️⃣ Obtener ubicación actual (rápida)
  final pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.low,
  );

  // 3️⃣ Reverse geocoding → obtener nombre de ciudad
  final placemarks = await placemarkFromCoordinates(
    pos.latitude,
    pos.longitude,
  );

  if (placemarks.isEmpty) return null;

  final p = placemarks.first;
  // Tomamos la ciudad o subregión como fallback
  final city = (p.locality != null && p.locality!.isNotEmpty)
      ? p.locality
      : p.subAdministrativeArea;

  return city;
});
