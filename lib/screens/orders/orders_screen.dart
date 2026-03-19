import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const List<(String, String)> _tabs = [
    ('Chờ xác nhận', OrderStatus.pending),
    ('Đang giao', OrderStatus.shipping),
    ('Đã giao', OrderStatus.delivered),
    ('Đã hủy', OrderStatus.canceled),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmpty(String title) {
    return Center(
      child: Text(
        'Không có đơn $title',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, String status, String title) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final orders = orderProvider.ordersByStatus(status);
        if (orders.isEmpty) {
          return _buildEmpty(title.toLowerCase());
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mã đơn: #${order.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status).withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              color: _statusColor(order.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Sản phẩm: ${order.items.length}'),
                    const SizedBox(height: 4),
                    Text('Tổng tiền: \$${order.totalPrice.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày đặt: ${order.date.day.toString().padLeft(2, '0')}/${order.date.month.toString().padLeft(2, '0')}/${order.date.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((tab) => Tab(text: tab.$1)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs
              .map((tab) => _buildOrderList(context, tab.$2, tab.$1))
              .toList(),
        ),
      ),
    );
  }
}
