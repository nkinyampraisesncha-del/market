import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/rental_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class SellerRentalsScreen extends StatefulWidget {
  const SellerRentalsScreen({super.key});
  @override
  State<SellerRentalsScreen> createState() => _SellerRentalsScreenState();
}

class _SellerRentalsScreenState extends State<SellerRentalsScreen> {
  final _service = SupabaseService();
  List<RentalModel> _rentals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadRentals(); }

  Future<void> _loadRentals() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) _rentals = await _service.getSellerRentals(user.id);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rentals'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: _isLoading ? const LoadingWidget() : _error != null ? AppErrorWidget(message: _error!, onRetry: _loadRentals) :
        _rentals.isEmpty ? const EmptyStateWidget(title: 'No rentals', message: 'Rental requests will appear here', icon: Icons.loop_outlined) :
        RefreshIndicator(
          onRefresh: _loadRentals,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _rentals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = _rentals[i];
              return Card(child: ListTile(
                title: Text(r.productTitle),
                subtitle: Text('${Helpers.formatDate(r.startDate)} - ${Helpers.formatDate(r.endDate)}'),
                trailing: Text(Helpers.formatCurrency(r.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ));
            },
          ),
        ),
    );
  }
}
