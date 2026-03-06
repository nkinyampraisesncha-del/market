import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;

  const CheckoutScreen({super.key, required this.productId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _service = SupabaseService();
  String _paymentMethod = 'card';
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPlacingOrder = true);

    try {
      final user = context.read<AuthProvider>().currentUser;
      final cartProvider = context.read<CartProvider>();
      if (user == null) return;

      for (final item in cartProvider.items) {
        await _service.createOrder({
          'product_id': item.product.id,
          'product_title': item.product.title,
          'buyer_id': user.id,
          'buyer_name': user.name,
          'seller_id': item.product.sellerId,
          'seller_name': item.product.sellerName,
          'amount': item.subtotal,
          'status': 'pending',
          'payment_status': 'pending',
          'payment_method': _paymentMethod,
          'shipping_address': _addressCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      cartProvider.clear();
      if (mounted) {
        context.go('/buyer/orders');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/marketplace'),
                    child: const Text('Browse Marketplace'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cart items
                  Text('Order Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...cartProvider.items.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: Text(Helpers.formatCurrency(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      Text(Helpers.formatCurrency(cartProvider.subtotal)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax (8%)', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      Text(Helpers.formatCurrency(cartProvider.tax)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(cartProvider.formattedTotal, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Shipping
                  Text('Shipping Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Shipping Address',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) => Validators.required(v, 'Address'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            prefixIcon: Icon(Icons.note_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment method
                  Text('Payment Method', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...['card', 'mobile_money', 'cash'].map((method) {
                    final labels = {'card': 'Credit/Debit Card', 'mobile_money': 'Mobile Money', 'cash': 'Cash on Delivery'};
                    final icons = {'card': Icons.credit_card, 'mobile_money': Icons.phone_android, 'cash': Icons.money};
                    return RadioListTile<String>(
                      value: method,
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                      title: Text(labels[method]!),
                      secondary: Icon(icons[method]),
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isPlacingOrder ? null : _placeOrder,
                      child: _isPlacingOrder
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Place Order • ${cartProvider.formattedTotal}'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
