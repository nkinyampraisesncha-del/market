import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/error_widget.dart';

class SellerDisputesScreen extends StatelessWidget {
  const SellerDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: const EmptyStateWidget(title: 'No disputes', message: 'Active disputes from buyers will appear here', icon: Icons.gavel_outlined),
    );
  }
}
