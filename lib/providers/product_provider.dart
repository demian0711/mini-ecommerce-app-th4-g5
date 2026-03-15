import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/fake_store_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  final FakeStoreService _service = FakeStoreService();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _service.fetchProducts();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
