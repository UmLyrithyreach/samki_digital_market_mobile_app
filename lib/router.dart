import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/about_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/bakong_payment_screen.dart';
import 'screens/become_seller_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/checkout_success_screen.dart';
import 'screens/home_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_screen.dart';
import 'screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return ProductsScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/products/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'];
        if (slug == null || slug.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Invalid product URL'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/products'),
                    child: const Text('Back to Products'),
                  ),
                ],
              ),
            ),
          );
        }
        return ProductDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/checkout/success/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return CheckoutSuccessScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/checkout/payment/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return BakongPaymentScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/orders/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/become-seller',
      builder: (context, state) => const BecomeSellerScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
