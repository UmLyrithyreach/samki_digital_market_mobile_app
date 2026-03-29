import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../i18n/app_i18n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/auth_required_view.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Cambodia');
  final _formKey = GlobalKey<FormState>();
  int _step = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  ShippingAddress _buildAddress() {
    return ShippingAddress(
      name: _nameController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      postcode: _postcodeController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? 'Cambodia'
          : _countryController.text.trim(),
    );
  }

  void _placeOrder() {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    final order = ref
        .read(ordersProvider.notifier)
        .placeOrder(
          userId: ref.read(currentUserProvider)!.id,
          items: cartItems,
          address: _buildAddress(),
        );
    ref.read(cartProvider.notifier).clear();
    if (mounted) context.go('/checkout/payment/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final currency = ref.watch(currencyProvider);

    if (user == null) {
      return Scaffold(
        appBar: SamkiAppBar(title: ref.t('checkout'), showBack: true),
        body: AuthRequiredView(
          title: ref.t('signInRequired'),
          message:
              'Please sign in or register first. Checkout is protected by account authentication.',
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: const SamkiAppBar(title: 'Checkout', showBack: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 64, color: SamkiTheme.border),
              const SizedBox(height: 12),
              const Text('Your cart is empty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: SamkiTheme.primary,
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const SamkiAppBar(title: 'Checkout', showBack: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: SamkiTheme.surface,
              border: Border(bottom: BorderSide(color: SamkiTheme.border)),
            ),
            child: Row(
              children: [
                _StepChip(number: 1, label: 'Address', active: _step == 1),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(height: 1, color: SamkiTheme.border),
                ),
                const SizedBox(width: 8),
                _StepChip(number: 2, label: 'Review', active: _step == 2),
              ],
            ),
          ),
          Expanded(
            child: _step == 1
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _field(
                            controller: _nameController,
                            label: 'Full Name',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _line1Controller,
                            label: 'Address Line 1',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _line2Controller,
                            label: 'Address Line 2 (Optional)',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _cityController,
                                  label: 'City',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Required'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _field(
                                  controller: _postcodeController,
                                  label: 'Postcode',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _countryController,
                            label: 'Country',
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  setState(() => _step = 2);
                                }
                              },
                              child: const Text('Continue to Review'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ...cartItems.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SamkiTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SamkiTheme.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} × ${item.quantity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currency.format(item.subtotal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SamkiTheme.accentLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(currency.format(total),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => setState(() => _step = 1),
                        child: const Text('Back to Address'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _placeOrder,
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _StepChip extends StatelessWidget {
  final int number;
  final String label;
  final bool active;

  const _StepChip({
    required this.number,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: active ? SamkiTheme.primary : SamkiTheme.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? SamkiTheme.primary : SamkiTheme.secondary,
          ),
        ),
      ],
    );
  }
}
