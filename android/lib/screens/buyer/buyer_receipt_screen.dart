import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class BuyerReceiptScreen extends StatefulWidget {
  final String orderId;

  const BuyerReceiptScreen({super.key, required this.orderId});

  @override
  State<BuyerReceiptScreen> createState() => _BuyerReceiptScreenState();
}

class _BuyerReceiptScreenState extends State<BuyerReceiptScreen> {
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    // Simulating order load - in a real app, fetch by ID
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) return const Scaffold(body: LoadingWidget());
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: AppErrorWidget(message: _error!, onRetry: _loadOrder),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Order Confirmed',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Receipt card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReceiptRow(label: 'Order ID', value: widget.orderId.substring(0, 8).toUpperCase()),
                    const Divider(height: 24),
                    _ReceiptRow(label: 'Status', value: 'Confirmed'),
                    _ReceiptRow(label: 'Payment', value: 'Completed'),
                    const Divider(height: 24),
                    _ReceiptRow(label: 'Subtotal', value: '\$0.00'),
                    _ReceiptRow(label: 'Tax (8%)', value: '\$0.00'),
                    const Divider(height: 24),
                    _ReceiptRow(
                      label: 'Total',
                      value: '\$0.00',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/buyer/orders'),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View All Orders'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/marketplace'),
                icon: const Icon(Icons.store_outlined),
                label: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _ReceiptRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
