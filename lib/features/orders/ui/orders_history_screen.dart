import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/orders_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/widgets/mini_profile_bar.dart';

class OrdersHistoryScreen extends ConsumerWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado de autenticación
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pedidos')),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error de sesión: $e')),
        data: (user) {
          if (user == null) {
            // Si no hay usuario autenticado
            return const _NoUserView();
          }

          // 👇 Usamos un Consumer separado para evitar re-render excesivo
          return _OrdersList(uid: user.uid);
        },
      ),
    );
  }
}

/// Vista separada para mostrar el listado (evita reconstrucciones dobles)
class _OrdersList extends ConsumerWidget {
  final String uid;
  const _OrdersList({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider(uid));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (orders) {
        if (orders.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              MiniProfileBar(),
              SizedBox(height: 8),
              _EmptyHistory(),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (_, i) {
            if (i == 0) return const MiniProfileBar();
            final o = orders[i];
            final status = (o['status'] ?? 'pendiente') as String;
            final total = (o['total'] as num?)?.toDouble() ?? 0;
            final createdAt = o['createdAt'];
            DateTime? date;
            if (createdAt is Timestamp) date = createdAt.toDate();

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: const Icon(Icons.receipt_long),
                  ),
                  title: Text(
                    'Orden #${o['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _StatusChip(status: status),
                      const SizedBox(height: 4),
                      Text(
                        date != null ? _fmtDate(date) : 'Sin fecha',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _fmtDate(DateTime d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'pendiente':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;
      case 'pagado':
      case 'en camino':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        break;
      case 'entregado':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      case 'cancelado':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Aún no tienes pedidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando realices tu primera compra, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoUserView extends StatelessWidget {
  const _NoUserView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48),
          const SizedBox(height: 12),
          const Text('Inicia sesión para ver tus pedidos'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/auth/login'),
            child: const Text('Ir a iniciar sesión'),
          ),
        ],
      ),
    );
  }
}
