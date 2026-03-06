import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SellerHelpScreen extends StatelessWidget {
  const SellerHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      ('How do I add a listing?', 'Go to your dashboard and tap "Add Listing". Fill in the details and submit for approval.'),
      ('How long does approval take?', 'Most listings are reviewed within 24 hours.'),
      ('How do I get paid?', 'Payments are processed after the buyer confirms receipt of the item.'),
      ('What if a buyer disputes my order?', 'You will be notified and have 48 hours to respond to the dispute.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...faqs.map((faq) => ExpansionTile(title: Text(faq.$1), children: [Padding(padding: const EdgeInsets.all(16), child: Text(faq.$2))])),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Contact Support'),
            subtitle: const Text('Send us a message'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/messages'),
          ),
        ],
      ),
    );
  }
}
