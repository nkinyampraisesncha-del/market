import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(secondary: const Icon(Icons.dark_mode_outlined), title: const Text('Dark Mode'), subtitle: const Text('Toggle dark/light theme'), value: themeProvider.isDarkMode, onChanged: (_) => themeProvider.toggleTheme()),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(leading: const Icon(Icons.person_outlined), title: const Text('Edit Profile'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/profile')),
          ListTile(leading: const Icon(Icons.lock_outlined), title: const Text('Change Password'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.card_membership_outlined), title: const Text('Subscription'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/subscription')),
          const Divider(),
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(secondary: const Icon(Icons.notifications_outlined), title: const Text('Push Notifications'), value: true, onChanged: (v) {}),
          SwitchListTile(secondary: const Icon(Icons.email_outlined), title: const Text('Email Notifications'), value: false, onChanged: (v) {}),
          const Divider(),
          const _SectionHeader(title: 'About'),
          ListTile(leading: const Icon(Icons.info_outlined), title: const Text('App Version'), trailing: const Text('1.0.0')),
          ListTile(leading: const Icon(Icons.policy_outlined), title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Terms of Service'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          const Divider(),
          if (authProvider.isAuthenticated)
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Sign Out', style: TextStyle(color: colorScheme.error)),
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) context.go('/home');
              },
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
    );
  }
}
