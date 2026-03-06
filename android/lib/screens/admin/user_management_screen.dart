import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _service = SupabaseService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try { _users = await _service.getAllUsers(); }
    catch (e) { setState(() => _error = e.toString()); }
    finally { setState(() => _isLoading = false); }
  }

  List<UserModel> get _filteredUsers {
    if (_filter == 'all') return _users;
    return _users.where((u) => u.role == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users (${_users.length})'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Search users...',
                    leading: const Icon(Icons.search),
                    onChanged: (q) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(label: const Text('All'), selected: _filter == 'all', onSelected: (_) => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Buyers'), selected: _filter == 'buyer', onSelected: (_) => setState(() => _filter = 'buyer')),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Sellers'), selected: _filter == 'seller', onSelected: (_) => setState(() => _filter = 'seller')),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Admins'), selected: _filter == 'admin', onSelected: (_) => setState(() => _filter = 'admin')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading ? const LoadingWidget() :
              _error != null ? AppErrorWidget(message: _error!, onRetry: _load) :
              _filteredUsers.isEmpty ? const EmptyStateWidget(title: 'No users found', icon: Icons.people_outline) :
              RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final u = _filteredUsers[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(Helpers.getInitials(u.name))),
                      title: Text(u.name),
                      subtitle: Text(u.email),
                      trailing: Chip(label: Text(u.role), padding: EdgeInsets.zero),
                      onTap: () => context.push('/admin/users/${u.id}'),
                    );
                  },
                ),
              ),
          ),
        ],
      ),
    );
  }
}
