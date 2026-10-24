class Drink {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  const Drink({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
  };
  factory Drink.fromMap(Map<String, dynamic> map) => Drink(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    imageUrl: map['imageUrl'] ?? '',
  );
}
