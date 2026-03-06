import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/listing_model.dart';
import '../../models/order_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final _service = SupabaseService();
  List<ListingModel> _listings = [];
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final results = await Future.wait([
          _service.getSellerListings(user.id),
          _service.getSellerOrders(user.id),
        ]);
        setState(() {
          _listings = results[0] as List<ListingModel>;
          _orders = results[1] as List<OrderModel>;
        });
      }
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalRevenue =>
      _orders.where((o) => o.isPaymentComplete).fold(0.0, (s, o) => s + o.amount);

  int get _activeListings => _listings.where((l) => l.isActive).length;

  int get _pendingOrders => _orders.where((o) => o.isPending).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/seller/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seller/listings/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.name.split(' ').first ?? 'Seller'}!',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s your business overview',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              // Stats
              Row(
                children: [
                  _StatTile(label: 'Revenue', value: Helpers.formatCurrency(_totalRevenue), icon: Icons.attach_money, color: Colors.green),
                  const SizedBox(width: 12),
                  _StatTile(label: 'Listings', value: '$_activeListings active', icon: Icons.list_alt_outlined, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  _StatTile(label: 'Orders', value: '$_pendingOrders pending', icon: Icons.pending_outlined, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 24),
              // Revenue chart
              Text('Revenue Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 30),
                              FlSpot(1, 45),
                              FlSpot(2, 28),
                              FlSpot(3, 80),
                              FlSpot(4, 55),
                              FlSpot(5, 90),
                              FlSpot(6, 70),
                            ],
                            isCurved: true,
                            color: colorScheme.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _ActionTile(icon: Icons.list_alt_outlined, label: 'Manage Listings', color: colorScheme.primary, onTap: () => context.push('/seller/listings')),
                  _ActionTile(icon: Icons.receipt_long_outlined, label: 'Orders', color: Colors.orange, onTap: () => context.push('/seller/orders')),
                  _ActionTile(icon: Icons.loop_outlined, label: 'Rentals', color: Colors.teal, onTap: () => context.push('/seller/rentals')),
                  _ActionTile(icon: Icons.bar_chart, label: 'Reports', color: Colors.purple, onTap: () => context.push('/seller/reports')),
                  _ActionTile(icon: Icons.message_outlined, label: 'Messages', color: Colors.blue, onTap: () => context.push('/messages')),
                  _ActionTile(icon: Icons.settings_outlined, label: 'Settings', color: Colors.grey, onTap: () => context.push('/seller/settings')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

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
            Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
