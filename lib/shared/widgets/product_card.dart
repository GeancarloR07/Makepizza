import 'package:flutter/material.dart';

/// Card simple para mostrar un producto con imagen opcional.
/// Para el MVP, acepta URL vacía y muestra un ícono por defecto.
class ProductCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String subtitle;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onAdd,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
            : const Icon(Icons.local_pizza, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: onAdd,
        ),
      ),
    );
  }
}
