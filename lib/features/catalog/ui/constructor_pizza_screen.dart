import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ingredients_provider.dart';
import '../providers/cart_provider.dart';
import '../../../data/models/cart_item.dart';

class ConstructorPizzaScreen extends ConsumerStatefulWidget {
  const ConstructorPizzaScreen({super.key});
  @override
  ConsumerState<ConstructorPizzaScreen> createState() =>
      _ConstructorPizzaScreenState();
}

class _ConstructorPizzaScreenState
    extends ConsumerState<ConstructorPizzaScreen> {
  final _selected = <String>{};
  final _nameCtrl = TextEditingController(text: 'Mi Pizza');
  static const double _base = 20000;

  @override
  Widget build(BuildContext context) {
    final ingrs = ref.watch(ingredientsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arma tu pizza')),
      body: ingrs.when(
        data: (list) {
          // total de ingredientes seleccionados
          final totalIng = list
              .where((i) => _selected.contains(i['id']))
              .fold<double>(0, (p, i) => p + (i['price'] as num).toDouble());
          final total = _base + totalIng;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de tu pizza',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingredientes (${_selected.length}/${list.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: list.map((i) {
                      final id = i['id'];
                      final selected = _selected.contains(id);
                      final label =
                          '${i['name']} (\$${(i['price'] as num).toDouble().toStringAsFixed(0)})';
                      return FilterChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selected.add(id);
                            } else {
                              _selected.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Base: \$${_base.toStringAsFixed(0)}'),
                          Text(
                            'Ingredientes: \$${totalIng.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: \$${total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Agregar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(cartProvider.notifier)
                            .add(
                              CartItem(
                                id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                                name: _nameCtrl.text.trim().isEmpty
                                    ? 'Mi Pizza'
                                    : _nameCtrl.text.trim(),
                                qty: 1,
                                unitPrice: total,
                                ingredientIds: _selected.toList(),
                              ),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pizza agregada')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
