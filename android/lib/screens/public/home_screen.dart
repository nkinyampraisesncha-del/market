import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadFeaturedProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.school, color: colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'UniMarket',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.person_outlined),
              onPressed: () => context.push('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign In'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().loadFeaturedProducts(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              if (user != null) ...[
                Text(
                  'Hello, ${user.name.split(' ').first}! 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What are you looking for today?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'University Marketplace',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buy, sell, and rent items within your campus community',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FilledButton.tonal(
                            onPressed: () => context.push('/register'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: colorScheme.primary,
                            ),
                            child: const Text('Get Started'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => context.push('/login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Search bar
              SearchBar(
                controller: _searchCtrl,
                hintText: 'Search items...',
                leading: const Icon(Icons.search),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    context.push('/marketplace?q=$query');
                  }
                },
              ),
              const SizedBox(height: 24),

              // Categories
              Text(
                'Browse Categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = AppConstants.categories[index];
                    return _CategoryItem(
                      label: category,
                      icon: _categoryIcon(category),
                      onTap: () =>
                          context.push('/marketplace?category=$category'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Featured Listings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Items',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/marketplace'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (productProvider.isLoading)
                SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, __) => const SizedBox(
                      width: 180,
                      child: ShimmerCard(),
                    ),
                  ),
                )
              else if (productProvider.featuredProducts.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.store_outlined, size: 64),
                      const SizedBox(height: 8),
                      Text(
                        'No items available yet',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: productProvider.featuredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final product = productProvider.featuredProducts[index];
                      return SizedBox(
                        width: 180,
                        child: ProductCard(
                          product: product,
                          isFavorited: productProvider.isFavorited(product.id),
                          onFavoriteTap: user != null
                              ? () => productProvider.toggleFavorite(
                                  user.id, product.id)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Quick Actions
              if (user != null) ...[
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (user.isBuyer || user.isSeller) ...[
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.receipt_long_outlined,
                          label: 'My Orders',
                          onTap: () => user.isBuyer
                              ? context.push('/buyer/orders')
                              : context.push('/seller/orders'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (user.isSeller)
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_circle_outline,
                          label: 'Add Listing',
                          onTap: () => context.push('/seller/listings/add'),
                        ),
                      ),
                    if (user.isBuyer)
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.favorite_outline,
                          label: 'Favorites',
                          onTap: () => context.push('/favorites'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Textbooks':
        return Icons.menu_book;
      case 'Electronics':
        return Icons.devices;
      case 'Clothing':
        return Icons.checkroom;
      case 'Furniture':
        return Icons.chair;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Stationery':
        return Icons.edit;
      case 'Housing':
        return Icons.house;
      case 'Services':
        return Icons.handyman;
      default:
        return Icons.category;
    }
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.secondaryContainer.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.secondary, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
