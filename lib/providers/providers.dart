import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/sanity_service.dart';

// ── Sanity service ────────────────────────────────────────────────────────────
final sanityServiceProvider = Provider<SanityService>((ref) => SanityService());

// ── Currency ──────────────────────────────────────────────────────────────────
enum Currency { usd, khr }

final currencyProvider = StateProvider<Currency>((ref) => Currency.usd);

extension CurrencyX on Currency {
  String get symbol => this == Currency.usd ? '\$' : '៛';
  String format(double usdPrice) {
    if (this == Currency.usd) {
      return '\$${usdPrice.toStringAsFixed(2)}';
    } else {
      final khr = (usdPrice * 4100).round();
      return '${khr.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}៛';
    }
  }
}

// ── Language ──────────────────────────────────────────────────────────────────
enum AppLanguage { en, kh }

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.en);

// ── Products ──────────────────────────────────────────────────────────────────
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');
final inStockOnlyProvider = StateProvider<bool>((ref) => false);
final priceRangeProvider =
    StateProvider<RangeValues>((ref) => const RangeValues(0, 5000));
final sortByProvider = StateProvider<String>((ref) => 'featured');

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(sanityServiceProvider);
  return service.fetchProducts();
});

final categoriesProvider = FutureProvider<List<ProductCategory>>((ref) async {
  final service = ref.watch(sanityServiceProvider);
  return service.fetchCategories();
});

final productBySlugProvider =
    FutureProvider.family<Product?, String>((ref, slug) async {
  final service = ref.watch(sanityServiceProvider);
  return service.fetchProductBySlug(slug);
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final inStockOnly = ref.watch(inStockOnlyProvider);
  final priceRange = ref.watch(priceRangeProvider);
  final sortBy = ref.watch(sortByProvider);

  return productsAsync.whenData((products) {
    var filtered = products.where((p) {
      if (selectedCategory != 'all' &&
          p.category.toLowerCase() != selectedCategory.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(searchQuery) &&
          !p.sellerName.toLowerCase().contains(searchQuery)) {
        return false;
      }
      if (inStockOnly && !p.inStock) {
        return false;
      }
      if (p.price < priceRange.start || p.price > priceRange.end) {
        return false;
      }
      return true;
    }).toList();

    switch (sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name_asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        break;
    }
    return filtered;
  });
});

// ── Cart ──────────────────────────────────────────────────────────────────────
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            CartItem(product: state[i].product, quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          CartItem(product: item.product, quantity: quantity)
        else
          item,
    ];
  }

  void clear() => state = [];

  int get totalCount => state.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => state.fold(0, (sum, item) => sum + item.subtotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
});

// ── Range values (needed for price range slider) ──────────────────────────────
class RangeValues {
  final double start;
  final double end;
  const RangeValues(this.start, this.end);
}
