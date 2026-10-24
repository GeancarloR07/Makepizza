import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double basePrice;
  final List<String> ingredientIds; // IDs de ingredientes incluidos por defecto

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.basePrice,
    this.ingredientIds = const [],
  });

  Product copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? basePrice,
    List<String>? ingredientIds,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    basePrice: basePrice ?? this.basePrice,
    ingredientIds: ingredientIds ?? this.ingredientIds,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'basePrice': basePrice,
    'ingredientIds': ingredientIds,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    basePrice: (map['basePrice'] ?? 0).toDouble(),
    ingredientIds: List<String>.from(map['ingredientIds'] ?? []),
  );

  String toJson() => json.encode(toMap());
  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
