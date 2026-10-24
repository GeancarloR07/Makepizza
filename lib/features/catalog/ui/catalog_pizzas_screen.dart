import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../../../data/models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../shared/widgets/cart_icon_button.dart';
import '../../../shared/widgets/mini_profile_bar.dart';

class CatalogPizzasScreen extends ConsumerWidget {
  const CatalogPizzasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsStreamProvider);

    Widget card(Map<String, dynamic> p) {
      final name = p['name'] ?? 'Pizza';
      final price = (p['basePrice'] as num?)?.toDouble() ?? 0.0;
      final img = (p['imageUrl'] as String?) ?? '';

      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // podrías abrir detalle si quieres
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: img.isNotEmpty
                        ? Image.network(img, fit: BoxFit.cover)
                        : Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Icon(Icons.local_pizza, size: 48),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .add(
                          CartItem(
                            id: p['id'],
                            name: name,
                            qty: 1,
                            unitPrice: price,
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizzas'),
        actions: const [CartIconButton()],
      ),
      body: products.when(
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
                _EmptyState(text: 'No hay pizzas. Carga las semillas.'),
              ],
            );
          }

          // Mini perfil + grid de pizzas
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: MiniProfileBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .72,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => card(list[index]),
                    childCount: list.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/catalog/constructor'),
        label: const Text('Armar mi pizza'),
        icon: const Icon(Icons.build),
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
