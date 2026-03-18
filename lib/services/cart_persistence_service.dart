import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartPersistenceService {
  static const String _cartKey = 'cart_items';

  /// Lưu giỏ hàng vào SharedPreferences
  static Future<void> saveCart(List<CartItem> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        cartItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  /// Tải giỏ hàng từ SharedPreferences
  static Future<List<CartItem>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(cartJson);
      return decodedList
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  /// Xóa toàn bộ giỏ hàng từ SharedPreferences
  static Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  /// Kiểm tra xem có dữ liệu giỏ hàng đã lưu hay không
  static Future<bool> hasCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cartKey);
    } catch (e) {
      print('Error checking cart: $e');
      return false;
    }
  }
}
