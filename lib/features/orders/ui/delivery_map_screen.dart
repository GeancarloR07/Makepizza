import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart';
import '../../../core/env/env.dart';
import '../../../data/services/maps_service.dart';
import '../../../core/constants/app_constants.dart'; // 👈 agrega esto

/// Mapa de entrega:
/// - Muestra pizzería fija en Bogotá.
/// - Permite tocar el mapa para elegir destino.
/// - Permite buscar dirección por texto.
/// - Botón "Usar mi ubicación".
class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({super.key});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final _maps = MapsService();
  GoogleMapController? _ctrl;

  // Pizzería fija (Bogotá)
  late final LatLng _origin = LatLng(Env.pizzeriaLat, Env.pizzeriaLng);

  // Destino elegido por el usuario (tap / búsqueda / mi ubicación)
  LatLng? _dest;
  String? _destAddress;

  final _addrCtrl = TextEditingController();
  bool _moving = false;

  Future<void> _animateTo(LatLng target, {double zoom = 15}) async {
    if (_ctrl == null) return;
    setState(() => _moving = true);
    await _ctrl!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
    setState(() => _moving = false);
  }

  Future<void> _setDestination(LatLng dest, {String? addr}) async {
    _dest = dest;
    _destAddress =
        addr ??
        await _maps.reverseGeocode(dest.latitude, dest.longitude) ??
        'Destino elegido';
    setState(() {});
  }

  Future<void> _useMyLocation() async {
    final pos = await _maps.getCurrentPosition();
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa GPS y permisos de ubicación.')),
      );
      return;
    }
    final me = LatLng(pos.latitude, pos.longitude);
    await _setDestination(me);
    await _animateTo(me);
  }

  Future<void> _searchAddress() async {
    final q = _addrCtrl.text.trim();
    if (q.isEmpty) return;
    final loc = await _maps.forwardGeocode(q);
    if (loc == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró esa dirección')),
      );
      return;
    }
    final point = LatLng(loc.latitude, loc.longitude);
    await _setDestination(point, addr: q);
    await _animateTo(point);
  }

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Marcadores: pizzería siempre + destino si existe
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pizzeria'),
        position: _origin,
        infoWindow: const InfoWindow(title: 'Pizzería (Bogotá)'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      if (_dest != null)
        Marker(
          markerId: const MarkerId('destino'),
          position: _dest!,
          infoWindow: InfoWindow(title: _destAddress ?? 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          draggable: false,
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de entrega')),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(target: _origin, zoom: 13.5),
            onMapCreated: (c) => setState(() => _ctrl = c),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            onTap: (latLng) async {
              // Tocar el mapa define el destino
              await _setDestination(latLng);
            },
          ),

          // Barra de búsqueda y "mi ubicación"
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addrCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchAddress(),
                      decoration: const InputDecoration(
                        hintText: 'Buscar dirección…',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchAddress,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Usar mi ubicación',
                    icon: const Icon(Icons.my_location),
                    onPressed: _useMyLocation,
                  ),
                ],
              ),
            ),
          ),

          if (_moving)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),

      // Confirmar
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text('Confirmar dirección'),
        onPressed: () {
          if (_dest == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Elige una dirección (tap, buscar o mi ubicación)',
                ),
              ),
            );
            return;
          }
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.ordersHistory,
            (route) => route.isFirst,
          ); // en el demo solo volvemos
        },
      ),
    );
  }
}
