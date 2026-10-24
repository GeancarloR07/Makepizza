class Ingredient {
  final String id;
  final String name;
  final double price;
  const Ingredient({required this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};
  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
  );
}
