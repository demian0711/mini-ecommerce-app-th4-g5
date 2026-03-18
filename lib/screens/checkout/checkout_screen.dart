import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  // Bắt buộc bạn làm Giỏ hàng phải truyền list sản phẩm sang đây
  final List<Map<String, dynamic>> selectedProducts;

  const CheckoutScreen({Key? key, required this.selectedProducts})
    : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'COD';

  // State lưu thông tin địa chỉ trên màn hình của bạn
  String userName = 'Trang';
  String userPhone = '0987123456';
  String userAddress = '123 Đường ABC, Hà Nội';

  // Tính tổng tiền dựa trên list bạn kia truyền sang
  double get _totalPrice {
    double total = 0;
    for (var item in widget.selectedProducts) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  // Mở form cập nhật địa chỉ
  Future<void> _updateAddress() async {
    TextEditingController nameCtrl = TextEditingController(text: userName);
    TextEditingController phoneCtrl = TextEditingController(text: userPhone);
    TextEditingController addressCtrl = TextEditingController(
      text: userAddress,
    );

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cập nhật địa chỉ nhận hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ chi tiết',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                      'address': addressCtrl.text,
                    });
                  },
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        userName = result['name']!;
        userPhone = result['phone']!;
        userAddress = result['address']!;
      });
    }
  }

  // Bấm đặt hàng
  void _handlePlaceOrder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Đặt hàng thành công!'),
            ],
          ),
          content: const Text('Cảm ơn bạn. Đơn hàng đang được xử lý.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context); // Tắt Dialog

                // LUỒNG QUAN TRỌNG: Quay về Giỏ hàng và gửi kèm tín hiệu "true" (Đã thanh toán thành công)
                Navigator.pop(context, true);
              },
              child: const Text(
                'Hoàn tất',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Phần Địa Chỉ ---
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: _updateAddress,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$userName - $userPhone',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- Phần Sản Phẩm ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sản phẩm đã chọn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Render danh sách sản phẩm từ mảng selectedProducts
                  widget.selectedProducts.isEmpty
                      ? const Text(
                          'Chưa có sản phẩm',
                          style: TextStyle(color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.selectedProducts.length,
                          itemBuilder: (context, index) {
                            var product = widget.selectedProducts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? '',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        // Có thể hiện thêm phân loại nếu bạn kia truyền sang
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'x${product['quantity']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${product['price']}đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- Phần Thanh Toán ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RadioListTile<String>(
                    activeColor: Colors.orange,
                    title: const Text('Thanh toán khi nhận hàng (COD)'),
                    value: 'COD',
                    groupValue: _paymentMethod,
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value!),
                  ),
                  RadioListTile<String>(
                    activeColor: Colors.orange,
                    title: const Text('Ví MoMo'),
                    value: 'MOMO',
                    groupValue: _paymentMethod,
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng thanh toán:', style: TextStyle(fontSize: 14)),
                Text(
                  '${_totalPrice.toStringAsFixed(0)}đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: widget.selectedProducts.isEmpty
                  ? null
                  : _handlePlaceOrder,
              child: const Text(
                'ĐẶT HÀNG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
