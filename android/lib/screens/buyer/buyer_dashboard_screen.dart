import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final _service = SupabaseService();
  List<OrderModel> _recentOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final orders = await _service.getBuyerOrders(user.id);
        setState(() { _recentOrders = orders.take(5).toList(); });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                'Welcome, ${user?.name.split(' ').first ?? 'Buyer'}!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your purchases and rentals',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Stats
              _StatsSummary(orders: _recentOrders),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _ActionTile(
                    icon: Icons.store_outlined,
                    label: 'Browse Market',
                    color: colorScheme.primary,
                    onTap: () => context.go('/marketplace'),
                  ),
                  _ActionTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Orders',
                    color: colorScheme.secondary,
                    onTap: () => context.push('/buyer/orders'),
                  ),
                  _ActionTile(
                    icon: Icons.loop_outlined,
                    label: 'My Rentals',
                    color: colorScheme.tertiary,
                    onTap: () => context.push('/buyer/rentals'),
                  ),
                  _ActionTile(
                    icon: Icons.payment_outlined,
                    label: 'Payments',
                    color: Colors.green,
                    onTap: () => context.push('/buyer/payments'),
                  ),
                  _ActionTile(
                    icon: Icons.favorite_outline,
                    label: 'Favorites',
                    color: Colors.red,
                    onTap: () => context.push('/favorites'),
                  ),
                  _ActionTile(
                    icon: Icons.gavel_outlined,
                    label: 'Disputes',
                    color: Colors.orange,
                    onTap: () => context.push('/buyer/disputes'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/buyer/orders'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const LoadingWidget()
              else if (_error != null)
                AppErrorWidget(message: _error!, onRetry: _loadData)
              else if (_recentOrders.isEmpty)
                const EmptyStateWidget(
                  title: 'No orders yet',
                  message: 'Start shopping to see your orders here',
                  icon: Icons.shopping_bag_outlined,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentOrders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) => _OrderListTile(order: _recentOrders[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSummary extends StatelessWidget {
  final List<OrderModel> orders;

  const _StatsSummary({required this.orders});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pending = orders.where((o) => o.isPending).length;
    final delivered = orders.where((o) => o.isDelivered).length;
    final total = orders.fold<double>(0, (sum, o) => sum + o.amount);

    return Row(
      children: [
        _StatCard(
          label: 'Pending',
          value: '$pending',
          icon: Icons.pending_outlined,
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Delivered',
          value: '$delivered',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Total Spent',
          value: Helpers.formatCurrency(total),
          icon: Icons.account_balance_wallet_outlined,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final OrderModel order;

  const _OrderListTile({required this.order});

  Color _statusColor(BuildContext context) {
    switch (order.status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        order.productTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(Helpers.formatDate(order.createdAt)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Helpers.formatCurrency(order.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              Helpers.statusBadgeLabel(order.status),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      onTap: () => context.push('/buyer/receipt/${order.id}'),
    );
  }
}
