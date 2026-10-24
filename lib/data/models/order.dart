import 'cart_item.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double deliveryFee;
  final double total;
  final String status; // pendiente | confirmado | entregado
  final DateTime createdAt;
  final double? destLat;
  final double? destLng;
  final String? destAddress;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.destLat,
    this.destLng,
    this.destAddress,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'items': items.map((e) => e.toMap()).toList(),
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'destLat': destLat,
    'destLng': destLng,
    'destAddress': destAddress,
  };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    items: (map['items'] as List? ?? [])
        .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
    total: (map['total'] ?? 0).toDouble(),
    status: map['status'] ?? 'pendiente',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    destLat: (map['destLat'] as num?)?.toDouble(),
    destLng: (map['destLng'] as num?)?.toDouble(),
    destAddress: map['destAddress'],
  );
}
