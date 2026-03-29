import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: const SamkiAppBar(title: 'Cart', showBack: true),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 64, color: SamkiTheme.border),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: SamkiTheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(color: SamkiTheme.secondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SamkiTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SamkiTheme.border),
                        ),
                        child: Row(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 72,
                                height: 86,
                                child: item.product.firstImage.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: item.product.firstImage,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: SamkiTheme.accentLight,
                                        child: const Icon(Icons.image_outlined,
                                            color: SamkiTheme.accent),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.category.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: SamkiTheme.accent,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.product.sellerName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: SamkiTheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        currency.format(item.subtotal),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Quantity controls
                                      _QtyControl(
                                        qty: item.quantity,
                                        onDecrement: () => ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(item.product.id,
                                                item.quantity - 1),
                                        onIncrement: () => ref
                                            .read(cartProvider.notifier)
                                            .updateQuantity(item.product.id,
                                                item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Remove
                            GestureDetector(
                              onTap: () => ref
                                  .read(cartProvider.notifier)
                                  .removeFromCart(item.product.id),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.close,
                                    size: 18, color: SamkiTheme.secondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // ── Summary ────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: SamkiTheme.surface,
                    border: Border(top: BorderSide(color: SamkiTheme.border)),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Subtotal',
                                style: TextStyle(
                                    fontSize: 14, color: SamkiTheme.secondary)),
                            const Spacer(),
                            Text(
                              currency.format(cartTotal),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/checkout');
                            },
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text('Proceed to Checkout',
                                style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyControl({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _btn(Icons.remove, onDecrement),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        _btn(Icons.add, onIncrement),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: SamkiTheme.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: SamkiTheme.primary),
      ),
    );
  }
}
