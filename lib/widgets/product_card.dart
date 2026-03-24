import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final bool compact;

  const ProductCard({super.key, required this.product, this.compact = false});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  bool _addedToCart = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleController.forward();
  void _onTapUp(_) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  Future<void> _addToCart() async {
    ref.read(cartProvider.notifier).addToCart(widget.product);
    setState(() => _addedToCart = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _addedToCart = false);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final product = widget.product;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () => context.push('/products/${product.slug}'),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: SamkiTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SamkiTheme.border),
            boxShadow: const [
              BoxShadow(
                color: SamkiTheme.cardShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SizedBox(
                        width: double.infinity,
                        child: product.firstImage.isNotEmpty
                            ? Hero(
                                tag: 'product_${product.id}',
                                child: CachedNetworkImage(
                                  imageUrl: product.firstImage,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: SamkiTheme.accentLight,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: SamkiTheme.accent,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: SamkiTheme.accentLight,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: SamkiTheme.accent,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: SamkiTheme.accentLight,
                                child: const Center(
                                  child: Icon(Icons.image_outlined,
                                      color: SamkiTheme.accent),
                                ),
                              ),
                      ),
                    ),
                    // Out of stock overlay
                    if (!product.inStock)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: Text(
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
                      ),
                    // Low stock badge
                    if (product.isLowStock)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: SamkiTheme.warning,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Only ${product.stockCount} left',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tag
                      Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: SamkiTheme.accent,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SamkiTheme.primary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Seller
                      Text(
                        product.sellerName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: SamkiTheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Price + Add to cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              currency.format(product.price),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: SamkiTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (product.inStock)
                            GestureDetector(
                              onTap: _addToCart,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _addedToCart
                                      ? SamkiTheme.success
                                      : SamkiTheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _addedToCart ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
