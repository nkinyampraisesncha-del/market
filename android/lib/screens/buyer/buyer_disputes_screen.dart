import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/error_widget.dart';

class BuyerDisputesScreen extends StatelessWidget {
  const BuyerDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Disputes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you have an issue with an order, you can open a dispute here. We aim to resolve disputes within 3-5 business days.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: EmptyStateWidget(
              title: 'No disputes',
              message: 'You have no active or past disputes',
              icon: Icons.gavel_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
