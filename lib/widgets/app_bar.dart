import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';

class SamkiAppBar extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final currency = ref.watch(currencyProvider);
    final language = ref.watch(languageProvider);

    return AppBar(
      backgroundColor: SamkiTheme.surface,
      elevation: 0,

      /// ✅ BACK BUTTON
      leading: showBack
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
      title: title != null
          ? Text(
              title!,
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
                language == AppLanguage.en
                    ? AppLanguage.kh
                    : AppLanguage.en;
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
                currency == Currency.usd
                    ? Currency.khr
                    : Currency.usd;
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 22),
              onPressed: () => context.push('/cart'),
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