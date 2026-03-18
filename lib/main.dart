import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/product_detail/product_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  try {
    print('🔥 [Main] Initializing Firebase...');
    await Firebase.initializeApp();
    print('✅ [Main] Firebase initialized successfully');
  } catch (e) {
    print('❌ [Main] Firebase initialization error: $e');
  }

  runApp(const MiniECommerceApp());
}

class MiniECommerceApp extends StatelessWidget {
  const MiniECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini E-Commerce App',
        theme: ThemeData(useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (_) => const _InitializeCartWrapper(child: HomeScreen()),
          '/cart': (_) => const CartScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/orders': (_) => const OrdersScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/detail' && settings.arguments != null) {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Widget để khởi tạo CartProvider khi app start
class _InitializeCartWrapper extends StatelessWidget {
  final Widget child;

  const _InitializeCartWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCart(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
  }

  Future<void> _initializeCart(BuildContext context) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.initialize();
  }
}
