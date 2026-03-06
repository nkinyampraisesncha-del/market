import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/rental_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class BuyerRentalsScreen extends StatefulWidget {
  const BuyerRentalsScreen({super.key});

  @override
  State<BuyerRentalsScreen> createState() => _BuyerRentalsScreenState();
}

class _BuyerRentalsScreenState extends State<BuyerRentalsScreen> {
  final _service = SupabaseService();
  List<RentalModel> _rentals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _rentals = await _service.getBuyerRentals(user.id);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rentals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading rentals...')
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _loadRentals)
              : _rentals.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No rentals yet',
                      message: 'Browse items available for rent',
                      icon: Icons.loop_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRentals,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rentals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _RentalCard(rental: _rentals[i]),
                      ),
                    ),
    );
  }
}

class _RentalCard extends StatelessWidget {
  final RentalModel rental;

  const _RentalCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = rental.isOverdue;
    final statusColor = rental.isActive
        ? (isOverdue ? Colors.red : Colors.green)
        : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rental.productTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOverdue ? 'Overdue' : rental.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${Helpers.formatDate(rental.startDate)} - ${Helpers.formatDate(rental.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${rental.rentalDays} days • ${Helpers.formatCurrency(rental.dailyRate)}/day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Owner: ${rental.ownerName}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  Helpers.formatCurrency(rental.totalAmount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
