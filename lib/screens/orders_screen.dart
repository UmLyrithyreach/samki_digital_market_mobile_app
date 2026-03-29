import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../i18n/app_i18n.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/auth_required_view.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final orders = ref
        .watch(ordersProvider)
        .where((order) => order.userId == user?.id)
        .toList();
    final currency = ref.watch(currencyProvider);

    if (user == null) {
      return Scaffold(
        appBar: SamkiAppBar(title: ref.t('myOrders'), showBack: true),
        body: AuthRequiredView(
          title: ref.t('signInRequired'),
          message: 'Please sign in to view your orders.',
        ),
      );
    }

    return Scaffold(
      appBar: const SamkiAppBar(title: 'My Orders', showBack: true),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: SamkiTheme.border),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: SamkiTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your order history will appear here',
                    style: TextStyle(color: SamkiTheme.secondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/products'),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return GestureDetector(
                  onTap: () => context.push('/orders/${order.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SamkiTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SamkiTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: SamkiTheme.accentLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.replaceAll('_', ' '),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: SamkiTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM d, y • h:mm a')
                              .format(order.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: SamkiTheme.secondary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${order.items.length} items',
                              style: const TextStyle(
                                  fontSize: 12, color: SamkiTheme.secondary),
                            ),
                            const Spacer(),
                            Text(
                              currency.format(order.total),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
