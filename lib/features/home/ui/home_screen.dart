import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
//import '../../auth/providers/auth_providers.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../../../shared/widgets/cart_icon_button.dart';
import '../../../shared/widgets/mini_profile_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Clima por ciudad (puede iniciar con .env y luego actualizarse)
    final weather = ref.watch(weatherProvider);

    // 2) Escuchamos la ciudad del dispositivo y, si llega, actualizamos cityProvider UNA vez.
    ref.listen(deviceCityProvider, (prev, next) {
      next.whenData((city) {
        if (city == null || city.isEmpty) return;
        final current = ref.read(cityProvider);
        if (current != city) {
          ref.read(cityProvider.notifier).setCity(city);
        }
      });
    });

    // 3) Tarjeta de clima estilizada
    Widget buildWeatherCard() {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: weather.when(
            data: (w) {
              if (w == null) {
                return const Text(
                  'Configura tu API key de OpenWeatherMap en .env',
                  style: TextStyle(fontSize: 14),
                );
              }
              final city = ref.read(cityProvider);
              return Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clima en $city',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${w.$1.toStringAsFixed(1)}°C, ${w.$2}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: () {
                      // Dispara un refresh del FutureProvider
                      ref.invalidate(weatherProvider);
                      ref.invalidate(deviceCityProvider);
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (e, _) => Text('Error clima: $e'),
          ),
        ),
      );
    }

    // 4) Botón bonito reutilizable
    Widget homeAction({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          const CartIconButton(), // 👈 NUEVO
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildWeatherCard(),
          const SizedBox(height: 8),
          MiniProfileBar(),
          const SizedBox(height: 4),
          homeAction(
            icon: Icons.local_pizza,
            label: 'Pizzas',
            onTap: () => Navigator.pushNamed(context, Routes.catalogPizzas),
          ),
          homeAction(
            icon: Icons.local_drink,
            label: 'Bebidas',
            onTap: () => Navigator.pushNamed(context, Routes.catalogBebidas),
          ),
          homeAction(
            icon: Icons.shopping_cart,
            label: 'Carrito',
            onTap: () => Navigator.pushNamed(context, Routes.cart),
          ),
          homeAction(
            icon: Icons.history,
            label: 'Historial de pedidos',
            onTap: () => Navigator.pushNamed(context, Routes.ordersHistory),
          ),
        ],
      ),
    );
  }
}
