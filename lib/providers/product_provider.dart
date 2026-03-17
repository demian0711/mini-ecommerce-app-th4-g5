import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/fake_store_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  static const int _pageSize = 8;
  bool _hasMore = true;
  final FakeStoreService _service = FakeStoreService();

  List<Product> get products => _products;
  List<Product> get allProducts => _allProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  void setProducts(List<Product> products) {
    _allProducts = products;
    _categories = _extractUniqueCategories(products);
    _currentPage = 1;
    final end = (_currentPage * _pageSize).clamp(0, _allProducts.length);
    _products = _allProducts.sublist(0, end);
    _hasMore = _products.length < _allProducts.length;
    notifyListeners();
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_allProducts.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final categories = await _service.fetchCategoriesLimited(limit: 20);
      final catalog = <Product>[];
      final selectedCategories = <String>[];

      for (final category in categories) {
        final items = await _service.fetchProductsByCategory(
          category,
          limit: 6,
        );

        if (items.isEmpty) {
          continue;
        }

        final fixedItems = _ensureSixItems(items, category);
        catalog.addAll(fixedItems);
        selectedCategories.add(category);
      }

      _allProducts = catalog;
      _categories = selectedCategories;
      _currentPage = 1;
      final end = (_currentPage * _pageSize).clamp(0, _allProducts.length);
      _products = _allProducts.sublist(0, end);
      _hasMore = _products.length < _allProducts.length;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts(forceRefresh: true);
  }

  Future<void> loadMoreProducts() async {
    if (_isLoading || _isLoadingMore || !hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final end = (nextPage * _pageSize).clamp(0, _allProducts.length);

      if (end <= _products.length) {
        _hasMore = false;
      } else {
        _products = _allProducts.sublist(0, end);
        _currentPage = nextPage;
        _hasMore = _products.length < _allProducts.length;
      }
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  List<Product> _ensureSixItems(List<Product> items, String category) {
    if (items.length >= 6) {
      return items.take(6).toList();
    }

    final normalized = List<Product>.from(items);
    var cloneIndex = 0;

    while (normalized.length < 6) {
      final source = items[cloneIndex % items.length];
      normalized.add(
        Product(
          id: source.id * 100 + normalized.length,
          title: source.title,
          image: source.image,
          price: source.price,
          description: source.description,
          category: category,
        ),
      );
      cloneIndex += 1;
    }

    return normalized;
  }

  List<String> _extractUniqueCategories(List<Product> products) {
    final categories = products.map((item) => item.category).toSet().toList();
    categories.sort((first, second) => first.compareTo(second));
    return categories;
  }
}
