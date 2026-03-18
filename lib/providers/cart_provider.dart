import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_firebase_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = true;
  final CartFirebaseService _firebaseService = CartFirebaseService();

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  /// Khởi tạo CartProvider và tải dữ liệu từ Firebase
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 [CartProvider] Initializing...');

      // Đăng nhập ẩn danh nếu chưa có user
      if (_firebaseService.getCurrentUserId() == null) {
        print('🔑 [CartProvider] Signing in anonymously...');
        await _firebaseService.signInAnonymously();
        print('✅ [CartProvider] Anonymous sign-in successful');
      } else {
        print(
          '✅ [CartProvider] User already authenticated: ${_firebaseService.getCurrentUserId()}',
        );
      }

      // Tải giỏ hàng từ Firebase
      final savedItems = await _firebaseService.loadCart();
      _items.clear();
      _items.addAll(savedItems);

      print(
        '✅ [CartProvider] Initialization complete. Items: ${_items.length}',
      );
    } catch (e) {
      print('❌ [CartProvider] Error initializing: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    _saveCart();
    notifyListeners();
  }

  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    _saveCart();
    notifyListeners();
  }

  void increaseQuantity(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    _items[index].quantity += 1;
    _saveCart();
    notifyListeners();
  }

  void decreaseQuantity(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity -= 1;
    }

    _saveCart();
    notifyListeners();
  }

  void toggleSelection(CartItem cartItem) {
    final index = _items.indexOf(cartItem);
    if (index == -1) return;

    _items[index].isSelected = !_items[index].isSelected;
    _saveCart();
    notifyListeners();
  }

  void toggleSelectAll(bool isSelected) {
    for (final item in _items) {
      item.isSelected = isSelected;
    }
    _saveCart();
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

  bool get areAllSelected {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }

  int get totalSelectedQuantity {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /// Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    _items.clear();
    await _firebaseService.clearCart();
    notifyListeners();
  }

  /// Lưu giỏ hàng lên Firebase
  void _saveCart() {
    _firebaseService.saveCart(_items).catchError((e) {
      print('Error saving cart: $e');
    });
  }
}
