import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/payment_service.dart';
import '../../catalog/providers/cart_provider.dart';
//import '../../../data/services/firestore_service.dart';
//import '../../../data/models/order.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../catalog/providers/products_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/mini_profile_bar.dart';

/// Pantalla de “pago” DEMO (no cobra).
/// Abre un checkout simulado; si es OK, crea una orden y navega al mapa.
class PaymentDemoScreen extends ConsumerWidget {
  const PaymentDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total =
        (ModalRoute.of(context)?.settings.arguments as double?) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pago (demo)')),
      body: Center(
        child: Column(
          children: [
            const MiniProfileBar(),
            const SizedBox(height: 12),
            Icon(
              Icons.credit_card,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Total: \$${total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Este es un pago simulado, no se cobra nada.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Continuar con el pago'),
              onPressed: total <= 0
                  ? null
                  : () async {
                      // ✅ Abrimos nuestro checkout simulado
                      final ok = await PaymentService().openCheckout(
                        context: context,
                        amount: total,
                      );
                      if (!context.mounted) return;

                      if (ok) {
                        // Crear orden + limpiar carrito + navegar a Map
                        final cart = ref.read(cartProvider);
                        final user = ref.read(authServiceProvider).currentUser;
                        if (user == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Inicia sesión para completar el pago.',
                                ),
                              ),
                            );
                            Navigator.pushNamed(context, '/auth/login');
                          }
                          return;
                        }

                        final uid = user.uid;
                        final orderId = DateTime.now().millisecondsSinceEpoch
                            .toString();

                        // 🔹 Guardamos directamente en Firestore con estado "pagado"
                        // y fecha de creación del servidor (FieldValue.serverTimestamp)
                        await ref.read(firestoreProvider).create(
                          'orders',
                          orderId,
                          {
                            'id': orderId,
                            'userId': uid,
                            'items': cart.items.map((e) => e.toMap()).toList(),
                            'deliveryFee': 9000,
                            'total': total,
                            'status': 'pagado', // 👈 ya no "pendiente"
                            'createdAt':
                                FieldValue.serverTimestamp(), // 👈 fecha del servidor
                          },
                        );

                        // Limpiamos el carrito
                        ref.read(cartProvider.notifier).clear();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pago OK. Orden creada'),
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.deliveryMap,
                            arguments:
                                orderId, // lo mandamos por si luego lo usas
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pago cancelado')),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
