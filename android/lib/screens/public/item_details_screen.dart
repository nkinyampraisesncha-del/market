import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String productId;

  const ItemDetailsScreen({super.key, required this.productId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final _supabaseService = SupabaseService();
  ProductModel? _product;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;
  final _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final product = await _supabaseService.getProductById(widget.productId);
      setState(() { _product = product; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading item...'));
    }
    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: AppErrorWidget(message: _error ?? 'Item not found', onRetry: _loadProduct),
      );
    }

    final product = _product!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final user = authProvider.currentUser;
    final isFav = productProvider.isFavorited(product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (user != null)
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_outline,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () =>
                      productProvider.toggleFavorite(user.id, product.id),
                ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: product.images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: product.images.length,
                          onPageChanged: (i) =>
                              setState(() => _currentImageIndex = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: product.images[i],
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image, size: 64),
                            ),
                          ),
                        ),
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == _currentImageIndex ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _currentImageIndex
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                          child: Icon(Icons.image, size: 80)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price & Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        Helpers.formatCurrency(product.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(product.category),
                        avatar: const Icon(Icons.category, size: 16),
                      ),
                      Chip(
                        label: Text(product.condition),
                        avatar: const Icon(Icons.star_outline, size: 16),
                      ),
                      if (product.isRentable)
                        Chip(
                          label: Text(
                              'Rent: ${Helpers.formatCurrency(product.rentalPricePerDay!)}/day'),
                          avatar: const Icon(Icons.loop, size: 16),
                          backgroundColor: colorScheme.tertiaryContainer,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Helpers.timeAgo(product.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Divider(height: 32),
                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.description, style: theme.textTheme.bodyMedium),
                  const Divider(height: 32),
                  // Seller Info
                  Text(
                    'Seller',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: product.sellerImageUrl != null
                          ? CachedNetworkImageProvider(product.sellerImageUrl!)
                          : null,
                      child: product.sellerImageUrl == null
                          ? Text(Helpers.getInitials(product.sellerName))
                          : null,
                    ),
                    title: Text(
                      product.sellerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(product.universityName ?? ''),
                    trailing: OutlinedButton.icon(
                      onPressed: user != null
                          ? () => context.push('/messages')
                          : null,
                      icon: const Icon(Icons.message_outlined, size: 18),
                      label: const Text('Message'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${product.viewCount} views',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: user != null && !cartProvider.contains(product.id)
                    ? () {
                        cartProvider.addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Added to cart'),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () =>
                                  context.push('/checkout/${product.id}'),
                            ),
                          ),
                        );
                      }
                    : null,
                icon: Icon(cartProvider.contains(product.id)
                    ? Icons.check
                    : Icons.shopping_cart_outlined),
                label: Text(cartProvider.contains(product.id)
                    ? 'In Cart'
                    : 'Add to Cart'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: user != null
                    ? () => context.push('/checkout/${product.id}')
                    : () => context.push('/login'),
                icon: const Icon(Icons.flash_on),
                label: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
