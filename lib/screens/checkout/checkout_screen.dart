import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Màn hình thanh toán'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final cartProvider = context.read<CartProvider>();
                final orderProvider = context.read<OrderProvider>();

                final selectedItems = cartProvider.items
                    .where((item) => item.isSelected)
                    .toList();

                final order = Order(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  items: selectedItems,
                  totalPrice: cartProvider.totalPrice,
                  date: DateTime.now(),
                  status: 'pending',
                );

                orderProvider.addOrder(order);
                Navigator.pushNamed(context, '/orders');
              },
              child: const Text('Đặt hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
