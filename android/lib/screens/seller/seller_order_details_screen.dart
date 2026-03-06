import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/loading_widget.dart';

class SellerOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const SellerOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<SellerOrderDetailsScreen> createState() => _SellerOrderDetailsScreenState();
}

class _SellerOrderDetailsScreenState extends State<SellerOrderDetailsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingWidget());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId.substring(0, 8).toUpperCase()}'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.pending_outlined), title: const Text('Status'), trailing: Chip(label: const Text('Pending'))),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.payment_outlined), title: const Text('Payment'), trailing: const Text('Pending')),
              ]),
            )),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.local_shipping_outlined), label: const Text('Mark Shipped'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.check), label: const Text('Confirm Delivery'))),
            ]),
          ],
        ),
      ),
    );
  }
}
