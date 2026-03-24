import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const ProductsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  bool _filtersVisible = true;
  final _searchController = TextEditingController();

  static const _categories = [
    'all',
    'Cleansers',
    'Masks',
    'Moisturizers',
    'Serums',
    'Sunscreens',
    'Toners',
  ];
  static const _sortOptions = [
    ('featured', 'Featured'),
    ('price_asc', 'Price: Low to High'),
    ('price_desc', 'Price: High to Low'),
    ('name_asc', 'Name A–Z'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      Future.microtask(() {
        ref.read(selectedCategoryProvider.notifier).state =
            widget.initialCategory!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final inStockOnly = ref.watch(inStockOnlyProvider);
    final sortBy = ref.watch(sortByProvider);
    final filteredAsync = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: const SamkiAppBar(showBack: true),
      body: CustomScrollView(
        slivers: [
          // ── Header with Categories ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: SamkiTheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shop All Products',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 4),
                  const Text('Premium skincare from trusted sellers',
                      style:
                          TextStyle(fontSize: 13, color: SamkiTheme.secondary)),
                  const SizedBox(height: 16),
                  // Category chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == selectedCategory ||
                            (cat == 'all' && selectedCategory == 'all');
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state =
                                cat;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? SamkiTheme.primary
                                  : SamkiTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? SamkiTheme.primary
                                    : SamkiTheme.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat == 'all' ? 'All' : cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : SamkiTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky Search Bar (pinned) ────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              searchController: _searchController,
              onSearchChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
            ),
          ),

          // ── Filter bar + Collapsible Filters ──────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(
                    color: SamkiTheme.surface,
                    border: Border(
                      top: BorderSide(color: SamkiTheme.border),
                      bottom: BorderSide(color: SamkiTheme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      filteredAsync.when(
                        data: (p) => Text(
                          '${p.length} products found',
                          style: const TextStyle(
                            fontSize: 12,
                            color: SamkiTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _filtersVisible = !_filtersVisible),
                        child: Row(
                          children: [
                            Icon(
                              _filtersVisible ? Icons.tune : Icons.tune,
                              size: 16,
                              color: SamkiTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _filtersVisible ? 'Hide Filters' : 'Show Filters',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: SamkiTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _filtersVisible
                      ? _FilterOptionsPanel(
                          inStockOnly: inStockOnly,
                          sortBy: sortBy,
                          sortOptions: _sortOptions,
                          onInStockChanged: (val) => ref
                              .read(inStockOnlyProvider.notifier)
                              .state = val,
                          onSortChanged: (val) => ref
                              .read(sortByProvider.notifier)
                              .state = val ?? 'featured',
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // ── Products Grid (SliverGrid) ─────────────────────────────────────
          filteredAsync.when(
            data: (products) => products.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: SamkiTheme.secondary),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCard(product: products[index]),
                        childCount: products.length,
                      ),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptionsPanel extends StatelessWidget {
  final bool inStockOnly;
  final String sortBy;
  final List<(String, String)> sortOptions;
  final ValueChanged<bool> onInStockChanged;
  final ValueChanged<String?> onSortChanged;

  const _FilterOptionsPanel({
    required this.inStockOnly,
    required this.sortBy,
    required this.sortOptions,
    required this.onInStockChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F5),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // In-stock toggle
          Expanded(
            child: Row(
              children: [
                Switch(
                  value: inStockOnly,
                  onChanged: onInStockChanged,
                  activeThumbColor: SamkiTheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                const Text(
                  'In stock only',
                  style: TextStyle(fontSize: 13, color: SamkiTheme.secondary),
                ),
              ],
            ),
          ),
          // Sort
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: sortBy,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                isDense: true,
              ),
              items: sortOptions
                  .map((o) => DropdownMenuItem(
                        value: o.$1,
                        child: Text(o.$2, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              onChanged: onSortChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  _SearchBarDelegate({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF8F7F5),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search, size: 18, color: SamkiTheme.secondary),
          isDense: true,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return searchController != oldDelegate.searchController;
  }
}
