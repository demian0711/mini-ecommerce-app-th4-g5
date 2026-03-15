import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class FakeStoreService {
  FakeStoreService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('https://fakestoreapi.com/products');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách sản phẩm.');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw Exception('Dữ liệu sản phẩm không hợp lệ.');
    }

    return data
        .map<Product>(
          (item) => Product(
            id: item['id'] as int,
            title: item['title']?.toString() ?? '',
            image: item['image']?.toString() ?? '',
            price: (item['price'] as num?)?.toDouble() ?? 0,
            description: item['description']?.toString() ?? '',
            category: item['category']?.toString() ?? '',
          ),
        )
        .toList();
  }
}
