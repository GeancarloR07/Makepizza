// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/ui/splash_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
import 'features/home/ui/home_screen.dart';
import 'features/catalog/ui/catalog_pizzas_screen.dart';
import 'features/catalog/ui/catalog_bebidas_screen.dart';
import 'features/catalog/ui/constructor_pizza_screen.dart';
import 'features/catalog/ui/cart_screen.dart';
import 'features/orders/ui/payment_demo_screen.dart';
import 'features/orders/ui/delivery_map_screen.dart';
import 'features/orders/ui/orders_history_screen.dart';
import 'features/profile/ui/profile_screen.dart';

class MakePizzaApp extends ConsumerWidget {
  const MakePizzaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.register: (_) => const RegisterScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.catalogPizzas: (_) => const CatalogPizzasScreen(),
        Routes.catalogBebidas: (_) => const CatalogBebidasScreen(),
        Routes.constructorPizza: (_) => const ConstructorPizzaScreen(),
        Routes.cart: (_) => const CartScreen(),
        Routes.paymentDemo: (_) => const PaymentDemoScreen(),
        Routes.deliveryMap: (_) => const DeliveryMapScreen(),
        Routes.ordersHistory: (_) => const OrdersHistoryScreen(),
        Routes.profile: (_) => const ProfileScreen(),
      },
      // Opcional: muestra errores en rojo en tiempo de ejecución
      builder: (context, child) {
        ErrorWidget.builder = (details) => Material(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error de UI:\n${details.exceptionAsString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
        return child!;
      },
    );
  }
}
