import 'package:flutter/material.dart';

/// ListTile genérico para listas simples (bebidas, ingredientes, etc.)
class ItemTile extends StatelessWidget {
  final String title;
  final String trailingText;
  final VoidCallback? onTap;
  final IconData icon;

  const ItemTile({
    super.key,
    required this.title,
    required this.trailingText,
    this.onTap,
    this.icon = Icons.local_drink,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(trailingText),
      onTap: onTap,
    );
  }
}
