import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/helpers.dart';

class PaymentReviewScreen extends StatelessWidget {
  final String orderId;
  const PaymentReviewScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Review'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.payment_outlined, size: 80, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('Review Payment', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Order #${orderId.substring(0, 8).toUpperCase()}', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _Row(label: 'Amount', value: '\$0.00'),
                const Divider(height: 24),
                _Row(label: 'Payment Method', value: 'Credit Card'),
                _Row(label: 'Status', value: 'Pending'),
                _Row(label: 'Date', value: Helpers.formatDate(DateTime.now())),
              ]),
            )),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => context.pop(), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
