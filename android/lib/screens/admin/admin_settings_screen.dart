import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/error_widget.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: const EmptyStateWidget(title: 'No data yet', message: 'Admin Settings data will appear here', icon: Icons.settings_outlined),
    );
  }
}
