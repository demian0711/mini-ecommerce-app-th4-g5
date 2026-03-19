import 'package:flutter/foundation.dart';

import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  List<Order> ordersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
