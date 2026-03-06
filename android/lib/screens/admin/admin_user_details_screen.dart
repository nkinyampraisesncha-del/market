import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailsScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  final _service = SupabaseService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _user = await _service.client.from('profiles').select().eq('id', widget.userId).maybeSingle()
          .then((data) => data != null ? UserModel.fromJson(data) : null);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingWidget());
    if (_error != null || _user == null) return Scaffold(appBar: AppBar(), body: AppErrorWidget(message: _error ?? 'User not found', onRetry: _load));

    final user = _user!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'suspend', child: Text('Suspend User')),
              const PopupMenuItem(value: 'verify', child: Text('Verify User')),
            ],
            onSelected: (v) {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 48, child: Text(Helpers.getInitials(user.name), style: const TextStyle(fontSize: 24))),
            const SizedBox(height: 12),
            Text(user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(label: Text(user.role)),
                const SizedBox(width: 8),
                if (user.isVerified) const Chip(label: Text('Verified'), avatar: Icon(Icons.verified, size: 16, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            Card(child: Column(children: [
              ListTile(leading: const Icon(Icons.calendar_today_outlined), title: const Text('Joined'), subtitle: Text(Helpers.formatDate(user.createdAt))),
              ListTile(leading: const Icon(Icons.school_outlined), title: const Text('University'), subtitle: Text(user.universityName ?? 'Not specified')),
              ListTile(leading: const Icon(Icons.toggle_on_outlined), title: const Text('Account Status'), trailing: Text(user.isActive ? 'Active' : 'Suspended', style: TextStyle(color: user.isActive ? Colors.green : Colors.red))),
            ])),
          ],
        ),
      ),
    );
  }
}
