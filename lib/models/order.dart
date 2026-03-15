import 'cart_item.dart';

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
