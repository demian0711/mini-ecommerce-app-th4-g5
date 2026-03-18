import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app/main.dart';

void main() {
  testWidgets('App shows Home placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniECommerceApp());

    expect(find.textContaining('TH4 - Nhóm'), findsOneWidget);
    expect(find.text('Tìm kiếm sản phẩm'), findsOneWidget);
  });
}
