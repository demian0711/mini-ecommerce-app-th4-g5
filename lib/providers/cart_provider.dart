import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_local_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final CartLocalService _cartLocalService = CartLocalService();

  CartProvider() {
    _restoreCart();
  }

  List<CartItem> get items => _items;

  Future<void> _restoreCart() async {
    final restoredItems = await _cartLocalService.loadCart();
    _items
      ..clear()
      ..addAll(restoredItems);
    notifyListeners();
  }

  void _persistCart() {
    _cartLocalService.saveCart(_items);
  }

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
    _persistCart();
  }

  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
    _persistCart();
  }

  void increaseQuantity(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    _items[index].quantity += 1;
    notifyListeners();
    _persistCart();
  }

  void decreaseQuantity(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity -= 1;
      notifyListeners();
      _persistCart();
    }
  }

  void toggleSelection(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    _items[index].isSelected = !_items[index].isSelected;
    notifyListeners();
    _persistCart();
  }

  void toggleSelectAll(bool isSelected) {
    for (final item in _items) {
      item.isSelected = isSelected;
    }
    notifyListeners();
    _persistCart();
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
    _persistCart();
  }

  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
    _persistCart();
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
