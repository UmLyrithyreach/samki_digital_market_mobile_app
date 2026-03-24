import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import '../models/models.dart';

class SanityService {
  static const String _projectId = 'brfi2cco';
  static const String _dataset = 'production';
  static const String _apiVersion = 'v2023-05-03';

  final Dio _dio = Dio(BaseOptions(
    baseUrl:
        'https://$_projectId.api.sanity.io/$_apiVersion/data/query/$_dataset',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Product>> fetchProducts({String? category}) async {
    String categoryFilter = category != null && category != 'all'
        ? '&& category->slug.current == "$category"'
        : '';

    final query = '''
      *[_type == "product" $categoryFilter] | order(_createdAt desc) {
        _id,
        name,
        "slug": slug.current,
        "category": category->name,
        price,
        "sellerName": seller->name,
        "images": images[]{
          "url": asset->url
        },
        "image": image{
          "url": asset->url
        },
        inStock,
        stockCount,
        skinType,
        concern,
        description
      }
    ''';

    try {
      final response = await _dio.get('', queryParameters: {'query': query});
      final result = response.data['result'] as List? ?? [];
      return result.map((json) => Product.fromSanity(json)).toList();
    } on DioException catch (e) {
      developer.log(
        'Sanity API Error: ${e.message} - Status: ${e.response?.statusCode}',
        name: 'SanityService.fetchProducts',
        error: e,
      );
      // Return mock data as fallback
      return _getMockProducts(category: category);
    } catch (e) {
      developer.log(
        'Unexpected error fetching products',
        name: 'SanityService.fetchProducts',
        error: e,
      );
      // Return mock data as fallback
      return _getMockProducts(category: category);
    }
  }

  Future<List<ProductCategory>> fetchCategories() async {
    const query = '''
      *[_type == "category"] | order(name asc) {
        _id,
        name,
        "slug": slug.current,
        "imageUrl": image.asset->url
      }
    ''';

    try {
      final response = await _dio.get('', queryParameters: {'query': query});
      final result = response.data['result'] as List? ?? [];
      return result.map((json) => ProductCategory.fromSanity(json)).toList();
    } on DioException catch (e) {
      developer.log(
        'Sanity API Error: ${e.message} - Status: ${e.response?.statusCode}',
        name: 'SanityService.fetchCategories',
        error: e,
      );
      return _getMockCategories();
    } catch (e) {
      developer.log(
        'Unexpected error fetching categories',
        name: 'SanityService.fetchCategories',
        error: e,
      );
      return _getMockCategories();
    }
  }

  Future<Product?> fetchProductBySlug(String slug) async {
    final query = '''
      *[_type == "product" && slug.current == "$slug"][0] {
        _id,
        name,
        "slug": slug.current,
        "category": category->name,
        price,
        "sellerName": seller->name,
        "images": images[]{
          "url": asset->url
        },
        inStock,
        stockCount,
        description
      }
    ''';

    try {
      final response = await _dio.get('', queryParameters: {'query': query});
      final result = response.data['result'];
      if (result == null) {
        developer.log(
          'Product not found with slug: $slug',
          name: 'SanityService.fetchProductBySlug',
        );
        return null;
      }
      return Product.fromSanity(result);
    } on DioException catch (e) {
      developer.log(
        'Sanity API Error: ${e.message} - Status: ${e.response?.statusCode}',
        name: 'SanityService.fetchProductBySlug',
        error: e,
      );
      return null;
    } catch (e) {
      developer.log(
        'Unexpected error fetching product by slug: $slug',
        name: 'SanityService.fetchProductBySlug',
        error: e,
      );
      return null;
    }
  }

  // ── Mock data fallback ──────────────────────────────────────────────────────

  List<Product> _getMockProducts({String? category}) {
    final all = [
      Product(
        id: '1',
        name: 'AHA Exfoliating Cleanser',
        slug: 'aha-exfoliating-cleanser',
        category: 'Cleansers',
        price: 28.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/f85e07e2eae894a6136d6cbd1fa62a7d0ce7599b-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '2',
        name: 'AHA/BHA Clarifying Toner',
        slug: 'aha-bha-toner',
        category: 'Toners',
        price: 32.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/ae6576eca99a1ecacf86ae7a367daa42f386bf00-1200x1805.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '3',
        name: 'Barrier Repair Cream',
        slug: 'barrier-repair-cream',
        category: 'Moisturizers',
        price: 38.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/063c4513408b6e137385fa96933165938c8ce090-1200x924.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '4',
        name: 'Hyaluronic Acid Hydrating Serum',
        slug: 'hyaluronic-acid-serum',
        category: 'Serums',
        price: 36.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/ed33aff9999f2a54a64b135f63e3cf8cb59372c4-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '5',
        name: 'Hydrating Day Cream SPF 15',
        slug: 'hydrating-day-cream',
        category: 'Moisturizers',
        price: 34.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/547cdbdea91c9ef8f8f23453242f8bf8616f8e16-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '6',
        name: 'Hydrating Honey Sheet Mask (5-Pack)',
        slug: 'hydrating-sheet-mask',
        category: 'Masks',
        price: 14.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/c23054445c40b89a25259a1884d5131087047b7e-1200x798.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '7',
        name: 'Kaolin Clay Purifying Mask',
        slug: 'clay-purifying-mask',
        category: 'Masks',
        price: 24.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/7251516939da94ce9499352d4021c1657c727feb-1200x1798.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '8',
        name: 'Lightweight UV Protection Fluid',
        slug: 'lightweight-uv-fluid',
        category: 'Sunscreens',
        price: 27.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/08c4522a55a0e0b5e8fd964104c9536d2436a6c1-1200x800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '9',
        name: 'Niacinamide 10% Pore Serum',
        slug: 'niacinamide-serum',
        category: 'Serums',
        price: 24.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/f80fb5a3114aa228f0a57eac531098cb77211bdc-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '10',
        name: 'Oil-Free Gel Cleanser',
        slug: 'oil-free-gel-cleanser',
        category: 'Cleansers',
        price: 22.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/063c4513408b6e137385fa96933165938c8ce090-1200x924.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '11',
        name: 'Retinol Night Serum 0.5%',
        slug: 'retinol-night-serum',
        category: 'Serums',
        price: 54.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/1f5d8eb13edae4e225cf5e9614527001f350dcc4-1200x1800.jpg'
        ],
        inStock: false,
      ),
      Product(
        id: '12',
        name: 'Rich Night Repair Cream',
        slug: 'rich-night-cream',
        category: 'Moisturizers',
        price: 45.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/547cdbdea91c9ef8f8f23453242f8bf8616f8e16-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '13',
        name: 'Rose Water Balancing Toner',
        slug: 'rose-water-toner',
        category: 'Toners',
        price: 18.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/6f717795ada4ac7b4a8e4a86945ad20091d576f7-1200x1600.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '14',
        name: 'SPF 50 Daily Shield',
        slug: 'spf50-daily-shield',
        category: 'Sunscreens',
        price: 29.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/08c4522a55a0e0b5e8fd964104c9536d2436a6c1-1200x800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '15',
        name: 'Vitamin C Brightening Serum',
        slug: 'vitamin-c-serum',
        category: 'Serums',
        price: 42.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/5aa422faaafd4e75bdc92928b7cd40727480504d-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '16',
        name: 'Green Tea Calming Toner',
        slug: 'green-tea-toner',
        category: 'Toners',
        price: 22.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/6f717795ada4ac7b4a8e4a86945ad20091d576f7-1200x1600.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '17',
        name: 'Gentle Foaming Cleanser',
        slug: 'gentle-foaming-cleanser',
        category: 'Cleansers',
        price: 18.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/f85e07e2eae894a6136d6cbd1fa62a7d0ce7599b-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '18',
        name: 'Micellar Cleansing Water',
        slug: 'micellar-cleansing-water',
        category: 'Cleansers',
        price: 15.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/f85e07e2eae894a6136d6cbd1fa62a7d0ce7599b-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '19',
        name: 'Overnight Sleeping Mask',
        slug: 'overnight-sleeping-mask',
        category: 'Masks',
        price: 39.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/c23054445c40b89a25259a1884d5131087047b7e-1200x798.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '20',
        name: 'Sunscreen Mist SPF 30',
        slug: 'sunscreen-mist',
        category: 'Sunscreens',
        price: 19.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/3929987675c1092f3e326888a6f30aeb3636c195-1200x1800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '21',
        name: 'Tinted Mineral Sunscreen',
        slug: 'tinted-mineral-sunscreen',
        category: 'Sunscreens',
        price: 34.99,
        sellerName: 'DermaLuxe',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/ece97f85ee4e2f670282f24351cf9c18bc4dddb6-1200x1797.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '22',
        name: 'Vitamin C Brightening Mask',
        slug: 'vitamin-c-glow-mask',
        category: 'Masks',
        price: 29.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/c23054445c40b89a25259a1884d5131087047b7e-1200x798.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '23',
        name: 'Oil-Free Gel Moisturizer',
        slug: 'oil-free-gel-moisturizer',
        category: 'Moisturizers',
        price: 26.99,
        sellerName: 'GlowLab Skincare',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/4f71c421d16b87b190cbda76027d94cc92f923bf-1200x800.jpg'
        ],
        inStock: true,
      ),
      Product(
        id: '24',
        name: 'Hydrating Essence Toner',
        slug: 'hydrating-essence-toner',
        category: 'Toners',
        price: 28.99,
        sellerName: 'PureSkin Co.',
        imageUrls: [
          'https://cdn.sanity.io/images/brfi2cco/production/e108b7e7232686b95c285033c2e021747651e894-1200x1738.jpg'
        ],
        inStock: true,
      ),
    ];

    if (category == null || category == 'all') return all;
    return all
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<ProductCategory> _getMockCategories() {
    return [
      ProductCategory(
          id: 'c1',
          name: 'Cleansers',
          slug: 'cleansers',
          imageUrl:
              'https://cdn.sanity.io/images/brfi2cco/production/01d5c27f13a391056bd2013f4c6bff493934f7ef-800x1200.jpg'),
      ProductCategory(
          id: 'c2',
          name: 'Masks',
          slug: 'masks',
          imageUrl:
              'https://cdn.sanity.io/images/brfi2cco/production/e4fd7de54fa0b0dc0b157850db2cb0058def89ab-800x532.jpg'),
      ProductCategory(
          id: 'c3',
          name: 'Moisturizers',
          slug: 'moisturizers',
          imageUrl:
              'https://cdn.sanity.io/images/brfi2cco/production/3490bc614eb462ec8398cdc94e0bc994170f3ef8-800x1200.jpg'),
      ProductCategory(
          id: 'c4',
          name: 'Serums',
          slug: 'serums',
          imageUrl:
              'https://cdn.sanity.io/images/brfi2cco/production/1d5c56fee1c5a69973fc1ef5e6b2e39306e3630e-800x1200.jpg'),
      ProductCategory(
          id: 'c5',
          name: 'Sunscreens',
          slug: 'sunscreens',
          imageUrl:
              'https://cdn.sanity.io/images/brfi2cco/production/e524ffc25f2618a82ff42d7330f28c7753030983-800x533.jpg'),
      ProductCategory(
          id: 'c6',
          name: 'Toners',
          slug: 'toners',
          imageUrl:
              'https://cdn.sanity.io/images/brfi2cco/production/45f55e8a37639eafcc02f6d94dfbd9125b128b26-800x1067.jpg'),
    ];
  }
}
