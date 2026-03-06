import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/listing_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
  final _service = SupabaseService();
  List<ListingModel> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try { _listings = await _service.getPendingApprovals(); }
    catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _isLoading = false); }
  }

  Future<void> _approve(String id) async {
    await _service.approveListing(id);
    _load();
  }

  Future<void> _reject(String id) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Listing'),
        content: TextFormField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason for rejection')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()), child: const Text('Reject')),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      await _service.rejectListing(id, reason);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approvals (${_listings.length})'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: _isLoading ? const LoadingWidget() : _error != null ? AppErrorWidget(message: _error!, onRetry: _load) :
        _listings.isEmpty ? const EmptyStateWidget(title: 'No pending approvals', icon: Icons.pending_actions_outlined) :
        RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final l = _listings[i];
              return Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(Helpers.formatCurrency(l.price), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  Text(l.category),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _reject(l.id), icon: const Icon(Icons.close, size: 16), label: const Text('Reject'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(onPressed: () => _approve(l.id), icon: const Icon(Icons.check, size: 16), label: const Text('Approve'))),
                  ]),
                ]),
              ));
            },
          ),
        ),
    );
  }
}
