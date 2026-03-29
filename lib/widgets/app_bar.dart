import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../i18n/app_i18n.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class SamkiAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;

  const SamkiAppBar({
    super.key,
    this.title,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<SamkiAppBar> createState() => _SamkiAppBarState();
}

class _SamkiAppBarState extends ConsumerState<SamkiAppBar> {
  double _cartScale = 1.0;
  double _userScale = 1.0;

  void _cartPressDown() => setState(() => _cartScale = 0.76);
  void _cartPressUp() => setState(() => _cartScale = 1.0);
  void _userPressDown() => setState(() => _userScale = 0.76);
  void _userPressUp() => setState(() => _userScale = 1.0);

  Future<void> _openCart() async {
    _cartPressDown();
    await Future.delayed(const Duration(milliseconds: 110));
    if (!mounted) return;
    await context.push('/cart');
    if (!mounted) return;
    _cartPressUp();
  }

  Future<void> _openUser() async {
    _userPressDown();
    await Future.delayed(const Duration(milliseconds: 110));
    if (!mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      await context.push('/auth');
      if (!mounted) return;
      _userPressUp();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: const TextStyle(color: SamkiTheme.secondary),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(ref.t('myOrders')),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/orders');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: Text(ref.t('signOut')),
                onTap: () {
                  ref.read(authProvider.notifier).signOut();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    _userPressUp();
  }

  String _localizedTitle(WidgetRef ref, String? title) {
    if (title == null) return '';
    final map = <String, String>{
      'Account': ref.t('account'),
      'Checkout': ref.t('checkout'),
      'Bakong Payment': ref.t('bakongPayment'),
    };
    return map[title] ?? title;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final currency = ref.watch(currencyProvider);
    final language = ref.watch(languageProvider);
    final user = ref.watch(currentUserProvider);

    return AppBar(
      backgroundColor: SamkiTheme.surface,
      elevation: 0,

      /// ✅ BACK BUTTON
      leading: widget.showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home'); // fallback
                }
              },
            )
          : null,

      /// ✅ TITLE OR LOGO
      title: widget.title != null
          ? Text(
              _localizedTitle(ref, widget.title),
              style: Theme.of(context).textTheme.headlineMedium,
            )
          : GestureDetector(
              onTap: () => context.go('/home'),
              child: const Text(
                'SAMKI',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: SamkiTheme.primary,
                ),
              ),
            ),

      /// ✅ RIGHT SIDE ACTIONS
      actions: [
        /// 🌐 Language toggle
        GestureDetector(
          onTap: () {
            ref.read(languageProvider.notifier).state =
                language == AppLanguage.en ? AppLanguage.kh : AppLanguage.en;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: SamkiTheme.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              language == AppLanguage.en ? 'EN' : 'KH',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        /// 💱 Currency toggle
        GestureDetector(
          onTap: () {
            ref.read(currencyProvider.notifier).state =
                currency == Currency.usd ? Currency.khr : Currency.usd;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: SamkiTheme.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              currency == Currency.usd ? '\$' : '៛',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        /// 🛒 Cart with badge
        AnimatedScale(
          scale: _cartScale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _cartPressDown(),
            onTapCancel: _cartPressUp,
            onTapUp: (_) => _cartPressUp(),
            onTap: _openCart,
            child: SizedBox(
              width: 40,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.shopping_bag_outlined, size: 22),
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: SamkiTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              cartCount > 9 ? '9+' : '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        /// 👤 Account
        AnimatedScale(
          scale: _userScale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _userPressDown(),
            onTapCancel: _userPressUp,
            onTapUp: (_) => _userPressUp(),
            onTap: _openUser,
            child: SizedBox(
              width: 40,
              child: Icon(
                user == null ? Icons.person_outline : Icons.person,
                size: 22,
              ),
            ),
          ),
        ),

        const SizedBox(width: 4),
      ],

      /// 🔽 Bottom border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: SamkiTheme.border,
        ),
      ),
    );
  }
}
