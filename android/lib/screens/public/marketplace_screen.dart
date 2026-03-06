import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../utils/constants.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(refresh: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final provider = context.read<ProductProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  border: InputBorder.none,
                ),
                onSubmitted: (q) => productProvider.searchProducts(q),
              )
            : const Text('Marketplace'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                productProvider.searchProducts('');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, productProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: AppConstants.categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('All'),
                    selected: productProvider.selectedCategory.isEmpty,
                    onSelected: (_) => productProvider.setCategory(''),
                  );
                }
                final cat = AppConstants.categories[index - 1];
                return FilterChip(
                  label: Text(cat),
                  selected: productProvider.selectedCategory == cat,
                  onSelected: (_) => productProvider.setCategory(cat),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Products grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<ProductProvider>().loadProducts(refresh: true),
              child: Builder(
                builder: (context) {
                  final products = _showSearch && _searchCtrl.text.isNotEmpty
                      ? productProvider.searchResults
                      : productProvider.products;

                  if (productProvider.isLoading && products.isEmpty) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: 6,
                      itemBuilder: (_, __) => const ShimmerCard(),
                    );
                  }

                  if (productProvider.errorMessage != null && products.isEmpty) {
                    return AppErrorWidget(
                      message: productProvider.errorMessage!,
                      onRetry: () =>
                          productProvider.loadProducts(refresh: true),
                    );
                  }

                  if (products.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No items found',
                      message: 'Try different filters or search terms',
                      icon: Icons.search_off,
                    );
                  }

                  return GridView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount:
                        products.length + (productProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        isFavorited: productProvider.isFavorited(product.id),
                        onFavoriteTap: user != null
                            ? () => productProvider.toggleFavorite(
                                user.id, product.id)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 16),
              Text('Condition',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                children: AppConstants.conditions
                    .map((c) => FilterChip(
                          label: Text(c),
                          selected: false,
                          onSelected: (_) {},
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text('Sort By',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                children: ['Newest', 'Price: Low to High', 'Price: High to Low']
                    .map((s) => FilterChip(
                          label: Text(s),
                          selected: false,
                          onSelected: (_) {},
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
