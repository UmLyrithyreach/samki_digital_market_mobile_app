import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../i18n/app_i18n.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/auth_required_view.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final order = ref.watch(orderByIdProvider(orderId));
    final currency = ref.watch(currencyProvider);

    if (user == null) {
      return Scaffold(
        appBar: const SamkiAppBar(showBack: true),
        body: AuthRequiredView(
          title: ref.t('signInRequired'),
          message: 'Please sign in to view order details.',
        ),
      );
    }

    if (order == null || order.userId != user.id) {
      return const Scaffold(
        appBar: SamkiAppBar(showBack: true),
        body: Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: const SamkiAppBar(title: 'Order Details', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNumber,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(order.createdAt),
                      style: const TextStyle(color: SamkiTheme.secondary),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 18),
          _Card(
            title: 'Items (${order.items.length})',
            child: Column(
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} × ${item.quantity}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(currency.format(item.subtotal),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Shipping Address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.address.name),
                Text(order.address.line1),
                if (order.address.line2.isNotEmpty) Text(order.address.line2),
                Text(
                  '${order.address.city}${order.address.postcode.isNotEmpty ? ', ${order.address.postcode}' : ''}',
                ),
                Text(order.address.country),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            title: 'Payment',
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Reference',
                        style: TextStyle(color: SamkiTheme.secondary)),
                    const Spacer(),
                    Text(order.paymentReference ?? '-', maxLines: 1),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Proof URL',
                        style: TextStyle(color: SamkiTheme.secondary)),
                    const Spacer(),
                    Expanded(
                      child: Text(
                        order.paymentProofImageUrl ?? '-',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SamkiTheme.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(currency.format(order.total),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (order.status == 'pending_payment') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout/payment/${order.id}'),
                child: const Text('Pay with Bakong'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SamkiTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SamkiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ').toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SamkiTheme.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: SamkiTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
