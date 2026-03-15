import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app/main.dart';

void main() {
  testWidgets('App shows Home placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniECommerceApp());

    expect(find.text('TH4 - Nhóm [Số nhóm]'), findsOneWidget);
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
