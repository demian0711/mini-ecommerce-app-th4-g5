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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      isSelected: json['isSelected'] as bool? ?? true,
      size: json['size'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'isSelected': isSelected,
      'size': size,
      'color': color,
    };
  }
}
