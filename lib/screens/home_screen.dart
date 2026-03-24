import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _heroController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: const SamkiAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Banner ──────────────────────────────────────────────
              _HeroBanner(fadeAnim: _heroFade, slideAnim: _heroSlide),

              // ── Trust Badges ─────────────────────────────────────────────
              const _TrustBadges(),

              // ── Featured Categories ──────────────────────────────────────
              const SizedBox(height: 32),
              _SectionHeader(
                label: 'Featured',
                title: 'Categories',
                onSeeAll: () => context.go('/products'),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) => _CategoriesRow(categories: categories),
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ── Featured Products ────────────────────────────────────────
              const SizedBox(height: 32),
              _SectionHeader(
                label: 'Hand-picked',
                title: 'Featured Products',
                onSeeAll: () => context.go('/products'),
              ),
              const SizedBox(height: 16),
              productsAsync.when(
                data: (products) => _ProductsCarousel(
                  products: products.take(8).toList(),
                ),
                loading: () => const SizedBox(
                  height: 280,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ── About Section ────────────────────────────────────────────
              const _AboutSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────
class _HeroBanner extends ConsumerWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _HeroBanner({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Stack(
          children: [
            // Background image
            SizedBox(
              height: 480,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800&q=80',
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: SamkiTheme.accentLight),
                errorWidget: (_, __, ___) =>
                    Container(color: SamkiTheme.accentLight),
              ),
            ),
            // Gradient overlay
            Container(
              height: 480,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: 24,
              bottom: 48,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium\nskincare,\ncurated.',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover trusted products from verified sellers across Cambodia.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonWidth = MediaQuery.of(context).size.width * 0.3;
                      return Row(
                        children: [
                          SizedBox(
                            width: buttonWidth,
                            child: _HeroButton(
                              label: 'Shop Now',
                              filled: false,
                              onTap: () => context.go('/products'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: buttonWidth,
                            child: _HeroButton(
                              label: 'Sell with Us',
                              filled: true,
                              onTap: () => context.go('/become-seller'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filled ? SamkiTheme.primary : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ── Trust Badges ──────────────────────────────────────────────────────────────
class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    const badges = [
      (Icons.verified_outlined, 'Verified sellers'),
      (Icons.inventory_2_outlined, 'Authentic products'),
      (Icons.local_shipping_outlined, 'Local delivery'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: SamkiTheme.surface,
        border: Border(
          top: BorderSide(color: SamkiTheme.border),
          bottom: BorderSide(color: SamkiTheme.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            badges.map((b) => _TrustBadge(icon: b.$1, label: b.$2)).toList(),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: SamkiTheme.accent),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: SamkiTheme.secondary,
          ),
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.label,
    required this.title,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SamkiTheme.accent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all →',
              style: TextStyle(
                fontSize: 13,
                color: SamkiTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Categories Row ────────────────────────────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  final List categories;
  const _CategoriesRow({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => context.go('/products?category=${cat.slug}'),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SamkiTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    if (cat.imageUrl != null)
                      SizedBox.expand(
                        child: CachedNetworkImage(
                          imageUrl: cat.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: SamkiTheme.accentLight),
                        ),
                      )
                    else
                      Container(color: SamkiTheme.accentLight),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Products Carousel ─────────────────────────────────────────────────────────
class _ProductsCarousel extends StatelessWidget {
  final List products;
  const _ProductsCarousel({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => SizedBox(
          width: 160,
          child: ProductCard(product: products[index]),
        ),
      ),
    );
  }
}

// ── About Section ─────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: SamkiTheme.accentLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ABOUT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: SamkiTheme.accent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Skincare marketplace\nwith verified sellers.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'SAMKI connects Cambodian skincare buyers with trusted, verified sellers offering authentic products with local delivery.',
            style: TextStyle(
              fontSize: 13,
              color: SamkiTheme.secondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
