import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  const CartState(this.items);

  double get subtotal => items.fold(0, (p, e) => p + e.lineTotal);

  /// cantidad total de unidades (para badge)
  int get totalUnits => items.fold(0, (p, e) => p + e.qty);
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState([]);

  void add(CartItem item) {
    final list = [...state.items];
    final idx = list.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      final old = list[idx];
      list[idx] = CartItem(
        id: old.id,
        name: old.name,
        qty: old.qty + item.qty,
        unitPrice: old.unitPrice,
        ingredientIds: old.ingredientIds,
      );
    } else {
      list.add(item);
    }
    state = CartState(list);
  }

  void updateQty(String id, int newQty) {
    if (newQty <= 0) {
      remove(id);
      return;
    }
    final list = [...state.items];
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final old = list[idx];
    list[idx] = CartItem(
      id: old.id,
      name: old.name,
      qty: newQty,
      unitPrice: old.unitPrice,
      ingredientIds: old.ingredientIds,
    );
    state = CartState(list);
  }

  void increment(String id) {
    final item = state.items.firstWhere(
      (e) => e.id == id,
      orElse: () => CartItem(id: '', name: '', qty: 0, unitPrice: 0),
    );
    if (item.id.isEmpty) return;
    updateQty(id, item.qty + 1);
  }

  void decrement(String id) {
    final item = state.items.firstWhere(
      (e) => e.id == id,
      orElse: () => CartItem(id: '', name: '', qty: 0, unitPrice: 0),
    );
    if (item.id.isEmpty) return;
    updateQty(id, item.qty - 1);
  }

  void remove(String id) {
    state = CartState(state.items.where((e) => e.id != id).toList());
  }

  void clear() {
    state = const CartState([]);
  }
}

// Provider con Notifier (Riverpod 3)
final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
