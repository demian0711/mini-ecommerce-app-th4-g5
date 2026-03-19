import 'cart_item.dart';

class OrderStatus {
  static const String pending = 'pending';
  static const String shipping = 'shipping';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';

  static const List<String> all = [pending, shipping, delivered, canceled];
}

class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime date;
  final String status;

  const Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
    required this.status,
  });
}
