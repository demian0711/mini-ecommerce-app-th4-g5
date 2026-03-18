import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  }) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          size: size,
          color: color,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  void increaseQuantity(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    _items[index].quantity += 1;
    notifyListeners();
  }

  void decreaseQuantity(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity -= 1;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void toggleSelection(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    _items[index].isSelected = !_items[index].isSelected;
    notifyListeners();
  }

  void toggleSelectAll(bool isSelected) {
    for (final item in _items) {
      item.isSelected = isSelected;
    }
    notifyListeners();
  }

  int get totalItems => _items.length;

  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool get areAllSelected {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }

  int get totalSelectedQuantity {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}
