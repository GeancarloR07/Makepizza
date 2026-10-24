import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

class MapsService {
  Future<Position?> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return null;
    }
    return Geolocator.getCurrentPosition();
  }

  Future<geo.Location?> forwardGeocode(String address) async {
    final results = await geo.locationFromAddress(address);
    if (results.isEmpty) return null;
    return results.first;
  }

  /// 🔹 Nuevo: Reverse geocode (lat/lng → dirección simple)
  Future<String?> reverseGeocode(double lat, double lng) async {
    final places = await geo.placemarkFromCoordinates(lat, lng);
    if (places.isEmpty) return null;
    final p = places.first;
    final parts = [
      if (p.street?.isNotEmpty == true) p.street,
      if (p.locality?.isNotEmpty == true) p.locality,
      if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea,
    ];
    return parts.whereType<String>().join(', ');
  }

  double deliveryFeeKm(double distanceKm) => 5000; // fija por ahora
}
