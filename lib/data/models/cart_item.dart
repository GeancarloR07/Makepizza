class CartItem {
  final String id; // id de producto o pizza personalizada
  final String name; // nombre visible
  final int qty;
  final double unitPrice; // precio unitario
  final List<String> ingredientIds; // para pizzas personalizadas

  const CartItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.unitPrice,
    this.ingredientIds = const [],
  });

  double get lineTotal => unitPrice * qty;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'qty': qty,
    'unitPrice': unitPrice,
    'ingredientIds': ingredientIds,
  };
  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    qty: map['qty'] ?? 1,
    unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    ingredientIds: List<String>.from(map['ingredientIds'] ?? []),
  );
}
