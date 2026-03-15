import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isSelected;
  final String? size;
  final String? color;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
    this.size,
    this.color,
  });
}
