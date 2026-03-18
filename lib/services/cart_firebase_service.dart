import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class CartFirebaseService {
  static const String _cartCollection = 'users';
  static const String _cartSubcollection = 'cart';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy user ID hiện tại
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Lưu giỏ hàng lên Firebase
  Future<void> saveCart(List<CartItem> cartItems) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('❌ [CartFirebase] User not authenticated');
        return;
      }

      print('✅ [CartFirebase] Saving cart for user: $userId');
      print('📦 [CartFirebase] Items count: ${cartItems.length}');

      // Xóa toàn bộ cart cũ
      final cartRef = _firestore
          .collection(_cartCollection)
          .doc(userId)
          .collection(_cartSubcollection);

      final existingDocs = await cartRef.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      // Lưu cart mới
      for (int i = 0; i < cartItems.length; i++) {
        await cartRef.doc('item_$i').set(cartItems[i].toJson());
      }

      print('✅ [CartFirebase] Cart saved successfully');
    } catch (e) {
      print('❌ [CartFirebase] Error saving cart: $e');
      rethrow;
    }
  }

  /// Tải giỏ hàng từ Firebase
  Future<List<CartItem>> loadCart() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('❌ [CartFirebase] User not authenticated');
        return [];
      }

      print('✅ [CartFirebase] Loading cart for user: $userId');

      final querySnapshot = await _firestore
          .collection(_cartCollection)
          .doc(userId)
          .collection(_cartSubcollection)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('📭 [CartFirebase] Cart is empty');
        return [];
      }

      print('📦 [CartFirebase] Loaded ${querySnapshot.docs.length} items');
      return querySnapshot.docs
          .map((doc) => CartItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ [CartFirebase] Error loading cart: $e');
      return [];
    }
  }

  /// Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      final cartRef = _firestore
          .collection(_cartCollection)
          .doc(userId)
          .collection(_cartSubcollection);

      final existingDocs = await cartRef.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart from Firebase: $e');
      rethrow;
    }
  }

  /// Kiểm tra xem có giỏ hàng không
  Future<bool> hasCart() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        return false;
      }

      final querySnapshot = await _firestore
          .collection(_cartCollection)
          .doc(userId)
          .collection(_cartSubcollection)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking cart: $e');
      return false;
    }
  }

  /// Lắng nghe thay đổi giỏ hàng real-time
  Stream<List<CartItem>> watchCart() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_cartCollection)
        .doc(userId)
        .collection(_cartSubcollection)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => CartItem.fromJson(doc.data()))
              .toList();
        });
  }

  /// Đăng nhập ẩn danh (nếu chưa có user)
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }
}
