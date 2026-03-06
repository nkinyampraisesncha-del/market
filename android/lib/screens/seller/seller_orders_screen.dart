import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});
  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final _service = SupabaseService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadOrders(); }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) _orders = await _service.getSellerOrders(user.id);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: _isLoading ? const LoadingWidget() : _error != null ? AppErrorWidget(message: _error!, onRetry: _loadOrders) :
        _orders.isEmpty ? const EmptyStateWidget(title: 'No orders', message: 'Orders from buyers will appear here', icon: Icons.receipt_long_outlined) :
        RefreshIndicator(
          onRefresh: _loadOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = _orders[i];
              return Card(
                child: ListTile(
                  title: Text(o.productTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Buyer: ${o.buyerName} • ${Helpers.formatDate(o.createdAt)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Helpers.formatCurrency(o.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(o.status, style: TextStyle(fontSize: 11, color: o.status == 'delivered' ? Colors.green : Colors.orange)),
                    ],
                  ),
                  onTap: () => context.push('/seller/orders/${o.id}'),
                ),
              );
            },
          ),
        ),
    );
  }
}
