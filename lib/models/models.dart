// Product model
class Product {
  final String id;
  final String name;
  final String slug;
  final String category;
  final double price;
  final String sellerName;
  final List<String> imageUrls;
  final bool inStock;
  final int? stockCount;
  final String? skinType;
  final String? concern;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.price,
    required this.sellerName,
    required this.imageUrls,
    required this.inStock,
    this.stockCount,
    this.skinType,
    this.concern,
    this.description,
  });

  factory Product.fromSanity(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      for (var img in json['images']) {
        if (img['asset'] != null && img['asset']['url'] != null) {
          images.add(img['asset']['url']);
        }
      }
    }
    if (images.isEmpty &&
        json['image'] != null &&
        json['image']['asset'] != null) {
      final asset = json['image']['asset'];
      if (asset['url'] != null) images.add(asset['url']);
    }

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug']?['current'] ?? '',
      category: json['category']?['name'] ?? json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      sellerName: json['seller']?['name'] ?? json['sellerName'] ?? '',
      imageUrls: images,
      inStock: json['inStock'] ?? true,
      stockCount: json['stockCount'],
      skinType: json['skinType'],
      concern: json['concern'],
      description: json['description'] ?? json['shortDescription'],
    );
  }

  String get firstImage => imageUrls.isNotEmpty ? imageUrls.first : '';
  bool get isLowStock => stockCount != null && stockCount! <= 5 && inStock;
}

// Category model
class ProductCategory {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
  });

  factory ProductCategory.fromSanity(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug']?['current'] ?? '',
      imageUrl: json['image']?['asset']?['url'],
    );
  }
}

// Cart item model
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

// Order model
class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String status;
  final ShippingAddress address;
  final String? paymentReference;
  final String? paymentProofImageUrl;
  final DateTime? paymentSubmittedAt;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.status,
    required this.address,
    this.paymentReference,
    this.paymentProofImageUrl,
    this.paymentSubmittedAt,
  });
}

class ShippingAddress {
  final String name;
  final String line1;
  final String line2;
  final String city;
  final String postcode;
  final String country;

  const ShippingAddress({
    required this.name,
    required this.line1,
    this.line2 = '',
    required this.city,
    this.postcode = '',
    this.country = 'Cambodia',
  });
}
