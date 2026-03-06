import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/error_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ProductProvider>().loadFavorites(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: user == null
          ? EmptyStateWidget(
              title: 'Sign in to see favorites',
              message: 'Create an account to save your favorite items',
              icon: Icons.favorite_outline,
              actionLabel: 'Sign In',
              onAction: () => context.push('/login'),
            )
          : productProvider.favoriteIds.isEmpty
              ? const EmptyStateWidget(
                  title: 'No favorites yet',
                  message: 'Tap the heart icon on any item to save it here',
                  icon: Icons.favorite_outline,
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: productProvider.products
                      .where((p) => productProvider.favoriteIds.contains(p.id))
                      .length,
                  itemBuilder: (context, index) {
                    final favorites = productProvider.products
                        .where((p) => productProvider.favoriteIds.contains(p.id))
                        .toList();
                    if (index >= favorites.length) return const SizedBox();
                    final product = favorites[index];
                    return ProductCard(
                      product: product,
                      isFavorited: true,
                      onFavoriteTap: () =>
                          productProvider.toggleFavorite(user.id, product.id),
                    );
                  },
                ),
    );
  }
}
