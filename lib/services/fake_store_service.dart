import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class FakeStoreService {
  FakeStoreService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Product>> fetchProducts({int? limit}) async {
    final fetchLimit = limit ?? 200;
    final uri = Uri.parse('https://dummyjson.com/products?limit=$fetchLimit');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách sản phẩm.');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['products'] is! List) {
      throw Exception('Dữ liệu sản phẩm không hợp lệ.');
    }

    final productList = data['products'] as List;

    return productList
        .map<Product>(
          (item) => Product(
            id: (item['id'] as num).toInt(),
            title: item['title']?.toString() ?? '',
            image:
                (item['thumbnail']?.toString() ??
                (item['images'] is List && (item['images'] as List).isNotEmpty
                    ? (item['images'] as List).first.toString()
                    : '')),
            price: (item['price'] as num?)?.toDouble() ?? 0,
            description: item['description']?.toString() ?? '',
            category: item['category']?.toString() ?? '',
          ),
        )
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('https://dummyjson.com/products/categories');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh mục sản phẩm.');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu danh mục không hợp lệ.');
    }

    return data
        .map((item) {
          if (item is String) {
            return item;
          }
          if (item is Map<String, dynamic>) {
            return item['slug']?.toString() ?? item['name']?.toString() ?? '';
          }
          return item.toString();
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<List<String>> fetchCategoriesLimited({int limit = 20}) async {
    final categories = await fetchCategories();
    if (categories.length <= limit) {
      return categories;
    }
    return categories.take(limit).toList();
  }

  Future<List<Product>> fetchProductsByCategory(
    String category, {
    int limit = 6,
  }) async {
    final encodedCategory = Uri.encodeComponent(category);
    final uri = Uri.parse(
      'https://dummyjson.com/products/category/$encodedCategory?limit=$limit',
    );
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể tải sản phẩm theo danh mục.');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['products'] is! List) {
      throw Exception('Dữ liệu sản phẩm danh mục không hợp lệ.');
    }

    final productList = data['products'] as List;
    return productList.map<Product>(_mapProduct).toList();
  }

  Product _mapProduct(dynamic item) {
    final product = item as Map<String, dynamic>;
    return Product(
      id: (product['id'] as num).toInt(),
      title: product['title']?.toString() ?? '',
      image:
          (product['thumbnail']?.toString() ??
          (product['images'] is List && (product['images'] as List).isNotEmpty
              ? (product['images'] as List).first.toString()
              : '')),
      price: (product['price'] as num?)?.toDouble() ?? 0,
      description: product['description']?.toString() ?? '',
      category: product['category']?.toString() ?? '',
    );
  }
}
