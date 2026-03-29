import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../providers/providers.dart';
import '../widgets/auth_required_view.dart';

class BecomeSellerScreen extends ConsumerStatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  ConsumerState<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends ConsumerState<BecomeSellerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const SamkiAppBar(
        title: 'Become a Seller',
        showBack: true,
      ),
      body: user == null
          ? const AuthRequiredView(
              title: 'Sign in required',
              message: 'Please sign in to submit your seller application.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _submitted
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: SamkiTheme.accentLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: SamkiTheme.accent, size: 32),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Application Submitted!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: SamkiTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "We'll review your application and get back to you within 2–3 business days.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: SamkiTheme.secondary, height: 1.5),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: SamkiTheme.accentLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SELL WITH US',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: SamkiTheme.accent,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Reach thousands of skincare enthusiasts across Cambodia.',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Join our verified seller network and grow your skincare business with SAMKI.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: SamkiTheme.secondary,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Apply to Sell',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: SamkiTheme.primary),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Full Name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _businessController,
                          decoration:
                              const InputDecoration(labelText: 'Business Name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Tell us about your products',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Submit Application',
                                style: TextStyle(fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Benefits
                        const Text(
                          'Why sell on SAMKI?',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: SamkiTheme.primary),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          (
                            'Verified seller badge',
                            'Build customer trust instantly'
                          ),
                          (
                            'Reach & exposure',
                            'Access our growing Cambodian customer base'
                          ),
                          (
                            'Simple dashboard',
                            'Manage products and orders with ease'
                          ),
                          (
                            'Local delivery',
                            'We handle logistics across Cambodia'
                          ),
                        ].map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: const BoxDecoration(
                                      color: SamkiTheme.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.$1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          b.$2,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: SamkiTheme.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
            ),
    );
  }
}
