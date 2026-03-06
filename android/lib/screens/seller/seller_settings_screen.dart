import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SellerSettingsScreen extends StatelessWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Dark Mode'),
              trailing: Switch(value: themeProvider.isDarkMode, onChanged: (_) => themeProvider.toggleTheme())),
          ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/seller/notifications')),
          ListTile(leading: const Icon(Icons.security_outlined), title: const Text('Privacy & Security'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Sign Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}
