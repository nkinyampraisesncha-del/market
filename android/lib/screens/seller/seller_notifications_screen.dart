import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/error_widget.dart';

class SellerNotificationsScreen extends StatelessWidget {
  const SellerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          actions: [TextButton(onPressed: () {}, child: const Text('Mark All Read'))]),
      body: const EmptyStateWidget(title: 'No notifications', message: 'Order updates and messages will appear here', icon: Icons.notifications_outlined),
    );
  }
}
