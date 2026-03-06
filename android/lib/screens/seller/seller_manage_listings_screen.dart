import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class SellerManageListingsScreen extends StatefulWidget {
  const SellerManageListingsScreen({super.key});

  @override
  State<SellerManageListingsScreen> createState() => _SellerManageListingsScreenState();
}

class _SellerManageListingsScreenState extends State<SellerManageListingsScreen> {
  final _service = SupabaseService();
  List<ListingModel> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _listings = await _service.getSellerListings(user.id);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteListing(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _service.deleteListing(id);
      _loadListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/seller/listings/add').then((_) => _loadListings()),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading listings...')
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _loadListings)
              : _listings.isEmpty
                  ? EmptyStateWidget(
                      title: 'No listings yet',
                      message: 'Start selling by adding your first listing',
                      icon: Icons.add_box_outlined,
                      actionLabel: 'Add Listing',
                      onAction: () => context.push('/seller/listings/add'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadListings,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _listings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ListingCard(
                          listing: _listings[i],
                          onEdit: () => context.push('/seller/listings/edit/${_listings[i].id}').then((_) => _loadListings()),
                          onDelete: () => _deleteListing(_listings[i].id),
                        ),
                      ),
                    ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListingCard({required this.listing, required this.onEdit, required this.onDelete});

  Color _statusColor(BuildContext context) {
    switch (listing.status) {
      case 'active': return Colors.green;
      case 'pending_approval': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'sold': return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: listing.thumbnailUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(listing.thumbnailUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined)),
                    )
                  : const Icon(Icons.image_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(listing.status.replaceAll('_', ' '),
                            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(Helpers.formatCurrency(listing.price),
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${listing.viewCount} views',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite_outline, size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${listing.favoriteCount} saves',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, iconSize: 20),
                IconButton(icon: Icon(Icons.delete_outline, color: theme.colorScheme.error), onPressed: onDelete, iconSize: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
