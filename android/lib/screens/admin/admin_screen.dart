import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _AdminNavCard(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/admin/dashboard'),
          _AdminNavCard(icon: Icons.analytics_outlined, label: 'Analytics', route: '/admin/analytics'),
          _AdminNavCard(icon: Icons.pending_actions_outlined, label: 'Approvals', route: '/admin/approvals'),
          _AdminNavCard(icon: Icons.people_outlined, label: 'Users', route: '/admin/users'),
          _AdminNavCard(icon: Icons.category_outlined, label: 'Categories', route: '/admin/categories'),
          _AdminNavCard(icon: Icons.inbox_outlined, label: 'Inbox', route: '/admin/inbox'),
          _AdminNavCard(icon: Icons.notifications_outlined, label: 'Notifications', route: '/admin/notifications'),
          _AdminNavCard(icon: Icons.payment_outlined, label: 'Payouts', route: '/admin/payouts'),
          _AdminNavCard(icon: Icons.star_outlined, label: 'Reviews', route: '/admin/reviews'),
          _AdminNavCard(icon: Icons.school_outlined, label: 'Universities', route: '/admin/universities'),
          _AdminNavCard(icon: Icons.settings_outlined, label: 'Settings', route: '/admin/settings'),
        ],
      ),
    );
  }
}

class _AdminNavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _AdminNavCard({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
