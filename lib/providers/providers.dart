import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

// ── Auth (Clerk-style local session for mobile app) ─────────────────────────
class AuthUser {
  final String id;
  final String fullName;
  final String email;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
  });
}

class AuthState {
  final AuthUser? user;
  final List<StoredAuthUser> registeredUsers;

  const AuthState({
    required this.user,
    required this.registeredUsers,
  });

  bool get isSignedIn => user != null;
}

class StoredAuthUser {
  final AuthUser user;
  final String password;

  const StoredAuthUser({
    required this.user,
    required this.password,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(user: null, registeredUsers: []));
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? register({
    required String fullName,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty ||
        password.isEmpty ||
        fullName.trim().isEmpty) {
      return 'Please fill in all required fields.';
    }

    final exists = state.registeredUsers.any(
      (u) => u.user.email.toLowerCase() == normalizedEmail,
    );
    if (exists) {
      return 'An account with this email already exists.';
    }

    final newUser = AuthUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: fullName.trim(),
      email: normalizedEmail,
    );

    state = AuthState(
      user: newUser,
      registeredUsers: [
        ...state.registeredUsers,
        StoredAuthUser(user: newUser, password: password),
      ],
    );
    return null;
  }

  String? signIn({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final match = state.registeredUsers.where((u) {
      return u.user.email.toLowerCase() == normalizedEmail &&
          u.password == password;
    });

    if (match.isEmpty) {
      return 'Invalid email or password.';
    }

    state = AuthState(
      user: match.first.user,
      registeredUsers: state.registeredUsers,
    );
    return null;
  }

  void signOut() {
    _googleSignIn.signOut();
    state = AuthState(user: null, registeredUsers: state.registeredUsers);
  }

  Future<String?> signInWithGoogle() async {
    try {
      final isMobile = defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;
      if (!isMobile) return 'GOOGLE_UNSUPPORTED_PLATFORM';

      final account = await _googleSignIn.signIn();
      if (account == null) return 'GOOGLE_CANCELLED';

      final email = account.email.trim().toLowerCase();
      final existing = state.registeredUsers.where(
        (u) => u.user.email.toLowerCase() == email,
      );

      AuthUser user;
      if (existing.isNotEmpty) {
        user = existing.first.user;
      } else {
        user = AuthUser(
          id: account.id,
          fullName: (account.displayName ?? 'Google User').trim(),
          email: email,
        );
      }

      final isStored = state.registeredUsers.any(
        (u) => u.user.email.toLowerCase() == email,
      );

      state = AuthState(
        user: user,
        registeredUsers: isStored
            ? state.registeredUsers
            : [...state.registeredUsers, StoredAuthUser(user: user, password: '')],
      );
      return null;
    } catch (e) {
      return 'GOOGLE_FAILED::$e';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

// ── Orders ───────────────────────────────────────────────────────────────────
class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super([]);

  Order placeOrder({
    required String userId,
    required List<CartItem> items,
    required ShippingAddress address,
  }) {
    final timestamp = DateTime.now();
    final id = timestamp.microsecondsSinceEpoch.toString();
    final order = Order(
      id: id,
      userId: userId,
      orderNumber: '#${timestamp.millisecondsSinceEpoch % 1000000}',
      items: items
          .map((item) =>
              CartItem(product: item.product, quantity: item.quantity))
          .toList(),
      total: items.fold(0.0, (sum, item) => sum + item.subtotal),
      createdAt: timestamp,
      status: 'pending_payment',
      address: address,
      paymentReference: 'SAMKI-$id',
      paymentProofImageUrl: null,
      paymentSubmittedAt: null,
    );

    state = [order, ...state];
    return order;
  }

  void updateStatus(String orderId, String status) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          Order(
            id: order.id,
            userId: order.userId,
            orderNumber: order.orderNumber,
            items: order.items,
            total: order.total,
            createdAt: order.createdAt,
            status: status,
            address: order.address,
            paymentReference: order.paymentReference,
            paymentProofImageUrl: order.paymentProofImageUrl,
            paymentSubmittedAt: order.paymentSubmittedAt,
          )
        else
          order,
    ];
  }

  void submitPaymentProof({
    required String orderId,
    required String paymentReference,
    required String paymentProofImageUrl,
  }) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          Order(
            id: order.id,
            userId: order.userId,
            orderNumber: order.orderNumber,
            items: order.items,
            total: order.total,
            createdAt: order.createdAt,
            status: 'payment_submitted',
            address: order.address,
            paymentReference: paymentReference,
            paymentProofImageUrl: paymentProofImageUrl,
            paymentSubmittedAt: DateTime.now(),
          )
        else
          order,
    ];
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>(
  (ref) => OrdersNotifier(),
);

final orderByIdProvider = Provider.family<Order?, String>((ref, orderId) {
  final orders = ref.watch(ordersProvider);
  for (final order in orders) {
    if (order.id == orderId) return order;
  }
  return null;
});

// ── Range values (needed for price range slider) ──────────────────────────────
class RangeValues {
  final double start;
  final double end;
  const RangeValues(this.start, this.end);
}
