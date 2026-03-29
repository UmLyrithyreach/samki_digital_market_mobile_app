import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../i18n/app_i18n.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/auth_required_view.dart';

class BakongPaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  const BakongPaymentScreen({super.key, required this.orderId});

  @override
  ConsumerState<BakongPaymentScreen> createState() =>
      _BakongPaymentScreenState();
}

class _BakongPaymentScreenState extends ConsumerState<BakongPaymentScreen> {
  final _referenceController = TextEditingController();
  final _proofImageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;

  @override
  void dispose() {
    _referenceController.dispose();
    _proofImageController.dispose();
    super.dispose();
  }

  void _submitProof() {
    if (_formKey.currentState?.validate() != true) return;

    final proof = _pickedImage?.path.trim().isNotEmpty == true
        ? _pickedImage!.path
        : _proofImageController.text.trim();

    ref.read(ordersProvider.notifier).submitPaymentProof(
          orderId: widget.orderId,
          paymentReference: _referenceController.text.trim(),
          paymentProofImageUrl: proof,
        );

    context.go('/checkout/success/${widget.orderId}');
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => _pickedImage = picked);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final order = ref.watch(orderByIdProvider(widget.orderId));
    final currency = ref.watch(currencyProvider);

    if (user == null) {
      return Scaffold(
        appBar: SamkiAppBar(title: ref.t('bakongPayment'), showBack: true),
        body: AuthRequiredView(
          title: ref.t('signInRequired'),
          message: 'Please sign in to complete Bakong payment.',
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
      appBar: SamkiAppBar(title: ref.t('bakongPayment'), showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SamkiTheme.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        size: 86, color: SamkiTheme.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan with Bakong app',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SamkiTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Amount: ${currency.format(order.total)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: SamkiTheme.secondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order: ${order.orderNumber}',
                      style: const TextStyle(
                          fontSize: 12, color: SamkiTheme.secondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ref.t('paymentMethodBakong'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: SamkiTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Submit Payment Proof',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SamkiTheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Transaction Reference',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proofImageController,
                decoration: const InputDecoration(
                  labelText: 'Payment Screenshot URL',
                ),
                validator: (v) {
                  if (_pickedImage != null) return null;
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final value = v.trim().toLowerCase();
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Must be a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose Screenshot from Gallery'),
                ),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_pickedImage!.path),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProof,
                  child: Text(ref.t('submitProof')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
