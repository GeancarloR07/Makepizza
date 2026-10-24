import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drinks_provider.dart';
import '../providers/cart_provider.dart';
import '../../../data/models/cart_item.dart';
import '../../../shared/widgets/cart_icon_button.dart';
import '../../../shared/widgets/mini_profile_bar.dart';

class CatalogBebidasScreen extends ConsumerWidget {
  const CatalogBebidasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinks = ref.watch(drinksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebidas'),
        actions: const [CartIconButton()],
      ),
      body: drinks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            // Mini perfil + empty state
            return ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                MiniProfileBar(),
                SizedBox(height: 8),
                _EmptyState(text: 'No hay bebidas. Carga las semillas.'),
              ],
            );
          }

          // Mini perfil + lista separada
          return Column(
            children: [
              const MiniProfileBar(),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = list[i];
                    final name = d['name'] ?? 'Bebida';
                    final price = (d['price'] as num?)?.toDouble() ?? 0.0;
                    final img = (d['imageUrl'] as String?) ?? '';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: img.isNotEmpty
                              ? Image.network(
                                  img,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  child: const Icon(Icons.local_drink),
                                ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('\$${price.toStringAsFixed(0)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .add(
                                  CartItem(
                                    id: d['id'],
                                    name: name,
                                    qty: 1,
                                    unitPrice: price,
                                  ),
                                );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}
