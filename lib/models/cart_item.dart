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

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': product.id,
        'title': product.title,
        'image': product.image,
        'price': product.price,
        'description': product.description,
        'category': product.category,
      },
      'quantity': quantity,
      'isSelected': isSelected,
      'size': size,
      'color': color,
    };
  }

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['product']['id'] as int,
        title: json['product']['title'] as String,
        image: json['product']['image'] as String,
        price: (json['product']['price'] as num).toDouble(),
        description: json['product']['description'] as String,
        category: json['product']['category'] as String,
      ),
      quantity: json['quantity'] as int,
      isSelected: json['isSelected'] as bool? ?? true,
      size: json['size'] as String?,
      color: json['color'] as String?,
    );
  }
}
