import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.person_outline, size: 80),
                const SizedBox(height: 16),
                const Text('Sign in to view your profile'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.push('/login'), child: const Text('Sign In')),
              ]),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profileImageUrl != null ? CachedNetworkImageProvider(user.profileImageUrl!) : null,
                          child: user.profileImageUrl == null ? Text(Helpers.getInitials(user.name), style: const TextStyle(fontSize: 28, color: Colors.white)) : null,
                        ),
                        const SizedBox(height: 12),
                        Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.8))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                          child: Text(Helpers.capitalize(user.role), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (user.universityName != null)
                          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.school_outlined), title: const Text('University'), subtitle: Text(user.universityName!)),
                        if (user.phone != null)
                          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.phone_outlined), title: const Text('Phone'), subtitle: Text(user.phone!)),
                        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: const Text('Member since'), subtitle: Text(Helpers.formatDate(user.createdAt))),
                        const Divider(),
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_outlined),
                          title: const Text('Dark Mode'),
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings')),
                        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.card_membership_outlined), title: const Text('Subscription'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/subscription')),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.logout, color: colorScheme.error),
                          title: Text('Sign Out', style: TextStyle(color: colorScheme.error)),
                          onTap: () async {
                            await authProvider.signOut();
                            if (context.mounted) context.go('/home');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
