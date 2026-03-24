import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _pageController = PageController();
  bool _addedToCart = false;
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      // Try to find product in cached list first
      final productsAsync = ref.read(productsProvider);

      // Properly handle the async data
      if (productsAsync is AsyncData<List<Product>>) {
        final found =
            productsAsync.value.where((p) => p.slug == widget.slug).firstOrNull;
        if (found != null && mounted) {
          setState(() {
            _product = found;
            _loading = false;
          });
          return;
        }
      }

      // If not found in cache, fetch directly
      final service = ref.read(sanityServiceProvider);
      final product = await service.fetchProductBySlug(widget.slug);
      if (mounted) {
        setState(() {
          _product = product;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;
    ref.read(cartProvider.notifier).addToCart(_product!);
    setState(() => _addedToCart = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _addedToCart = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    if (_loading) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SamkiAppBar(showBack: true),
        ),
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }

    if (_product == null) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SamkiAppBar(showBack: true),
        ),
        body: Center(child: Text('Product not found')),
      );
    }

    final product = _product!;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SamkiAppBar(showBack: true),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Gallery ──────────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  child: product.imageUrls.isEmpty
                      ? Container(
                          color: SamkiTheme.accentLight,
                          child: const Center(
                            child: Icon(Icons.image_outlined,
                                size: 48, color: SamkiTheme.accent),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: product.imageUrls.length,
                          onPageChanged: (i) {
                            // Page changed, but we don't need to store it
                            // as SmoothPageIndicator reads from controller
                          },
                          itemBuilder: (context, index) => Hero(
                            tag: 'product_${product.id}',
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: SamkiTheme.accentLight),
                            ),
                          ),
                        ),
                ),
                if (product.imageUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: product.imageUrls.length,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 6,
                          dotHeight: 6,
                          expansionFactor: 2.5,
                          activeDotColor: SamkiTheme.primary,
                          dotColor: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                // Out of stock
                if (!product.inStock)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Product Info ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SamkiTheme.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  // Seller
                  Text(
                    'by ${product.sellerName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: SamkiTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price row
                  Row(
                    children: [
                      Text(
                        currency.format(product.price),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: SamkiTheme.primary,
                        ),
                      ),
                      if (currency == Currency.usd) ...[
                        const SizedBox(width: 10),
                        Text(
                          Currency.khr.format(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            color: SamkiTheme.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Stock status
                  const SizedBox(height: 10),
                  _StockBadge(product: product),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Description
                  if (product.description != null) ...[
                    const Text(
                      'About this product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SamkiTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: SamkiTheme.secondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Add to cart
                  if (product.inStock)
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: _addedToCart ? null : _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _addedToCart
                                ? SamkiTheme.success
                                : SamkiTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _addedToCart
                                    ? Icons.check
                                    : Icons.shopping_bag_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _addedToCart ? 'Added to Cart!' : 'Add to Cart',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Out of Stock'),
                      ),
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

class _StockBadge extends StatelessWidget {
  final Product product;
  const _StockBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return _badge(Icons.cancel_outlined, 'Out of Stock', SamkiTheme.error);
    }
    if (product.isLowStock) {
      return _badge(Icons.warning_amber_outlined,
          'Only ${product.stockCount} left in stock', SamkiTheme.warning);
    }
    return _badge(Icons.check_circle_outline, 'In Stock', SamkiTheme.success);
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
