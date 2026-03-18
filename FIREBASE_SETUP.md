# Hướng dẫn cấu hình Firebase cho giỏ hàng

## 📋 Các bước cài đặt Firebase

### 1. Tạo project trên Firebase Console
- Truy cập https://console.firebase.google.com
- Tạo project mới hoặc chọn project có sẵn
- Ghi nhớ **Project ID** của bạn

### 2. Cài đặt Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 3. Khởi tạo Firebase cho Flutter project
```bash
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
```

**Lựa chọn khi chạy `flutterfire configure`:**
- Chọn project Firebase của bạn
- Chọn các platform: Android, iOS, Web (tuỳ nhu cầu)
- Hệ thống sẽ tự tạo file `firebase_options.dart` và `google-services.json`, `GoogleService-Info.plist`

### 4. Cập nhật main.dart (nếu firebase_options.dart đã được tạo)
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MiniECommerceApp());
}
```

### 5. Cấu hình Cloud Firestore Security Rules
Trên Firebase Console:
1. Vào **Cloud Firestore** → **Rules**
2. Thay thế Rules bằng code dưới đây:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cho phép người dùng đọc/ghi giỏ hàng của chính họ
    match /users/{userId}/cart/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Cho phép mọi người đọc danh sách sản phẩm (nếu cần)
    match /products/{document=**} {
      allow read: if true;
    }
  }
}
```

### 6. Bật Anonymous Authentication (tuỳ chọn)
Nếu muốn người dùng có thể sử dụng ứng dụng mà không đăng nhập:
1. Vào **Authentication** → **Sign-in method**
2. Bật **Anonymous**

---

## 🔧 Cấu trúc dữ liệu trên Firestore

### Collections và Documents:
```
users/ (collection)
  └── {userId} (document - auto-generated)
      └── cart/ (subcollection)
          ├── item_0 (document)
          │   ├── product (object)
          │   │   ├── id: number
          │   │   ├── title: string
          │   │   ├── image: string
          │   │   ├── price: number
          │   │   ├── description: string
          │   │   └── category: string
          │   ├── quantity: number
          │   ├── isSelected: boolean
          │   ├── size: string (optional)
          │   └── color: string (optional)
          │
          └── item_1 (document)
              └── ...tương tự item_0
```

---

## 🚀 Cách sử dụng trong code

### Tự động lưu lên Firebase:
```dart
// CartProvider tự động lưu lên Firebase mỗi khi có thay đổi
final cartProvider = Provider.of<CartProvider>(context);

// Thêm sản phẩm → tự động lưu lên Firebase
cartProvider.addItem(product, quantity: 2);

// Xóa sản phẩm → tự động lưu lên Firebase
cartProvider.removeItem(cartItem);

// Tăng quantity → tự động lưu lên Firebase
cartProvider.increaseQuantity(cartItem);

// Xóa toàn bộ giỏ hàng (sau khi checkout)
await cartProvider.clearCart();
```

### Lắng nghe thay đổi real-time:
```dart
// File: lib/services/cart_firebase_service.dart
final firebaseService = CartFirebaseService();

// Stream giỏ hàng real-time
firebaseService.watchCart().listen((cartItems) {
  print('Cart updated: ${cartItems.length} items');
});
```

---

## ✅ Kiểm tra hoạt động

1. **Chạy app:**
   ```bash
   flutter run
   ```

2. **Thêm sản phẩm vào giỏ hàng**

3. **Kiểm tra Firestore:**
   - Mở Firebase Console → Cloud Firestore
   - Xem collection `users` → giỏ hàng của bạn được lưu ở `users/{userId}/cart/`

4. **Test persistent:**
   - Tắt app
   - Bật lại app
   - Giỏ hàng vẫn còn nguyên ✅

---

## ⚠️ Ghi chú quan trọng

1. **Cần kết nối Internet** để Firebase hoạt động
2. **Anonymous Authentication** cho phép mỗi device có user_id riêng
3. **Stored data** sẽ tồn tại trên Firebase Cloud - có thể xem trên Console
4. Nếu gặp lỗi **"User not authenticated"** → rebuild app hoặc xóa cache

---

## 🔗 Tài liệu tham khảo
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Cloud Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
