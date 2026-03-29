import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';

class CheckoutSuccessScreen extends ConsumerWidget {
  final String orderId;
  const CheckoutSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));
    final currency = ref.watch(currencyProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        appBar: SamkiAppBar(showBack: true),
        body: Center(child: Text('Sign in required')),
      );
    }

    if (order == null || order.userId != user.id) {
      return const Scaffold(
        appBar: SamkiAppBar(showBack: true),
        body: Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: const SamkiAppBar(title: 'Payment', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: SamkiTheme.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_2_rounded,
                  size: 36, color: SamkiTheme.accent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Reserved',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: SamkiTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reference: ${order.paymentReference}',
              style: const TextStyle(color: SamkiTheme.secondary),
            ),
            const SizedBox(height: 6),
            Text(
              order.status == 'payment_submitted'
                  ? 'Payment proof submitted for review'
                  : 'Awaiting payment proof submission',
              style: TextStyle(
                color: order.status == 'payment_submitted'
                    ? SamkiTheme.success
                    : SamkiTheme.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SamkiTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SamkiTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Instructions',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('1. Transfer ${currency.format(order.total)} to seller'),
                  const SizedBox(height: 4),
                  Text('2. Use order number ${order.orderNumber} as reference'),
                  const SizedBox(height: 4),
                  const Text('3. Wait for payment verification'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SamkiTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SamkiTheme.border),
              ),
              child: Column(
                children: [
                  const Text('Total',
                      style: TextStyle(color: SamkiTheme.secondary)),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(order.total),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: SamkiTheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/orders/${order.id}'),
                child: const Text('View Order'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
