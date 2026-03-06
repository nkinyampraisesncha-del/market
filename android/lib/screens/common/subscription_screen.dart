import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1;

  final _plans = [
    {'name': 'Free', 'price': '\$0', 'period': '/month', 'features': ['5 active listings', 'Basic analytics', 'Standard support'], 'color': Colors.grey},
    {'name': 'Pro', 'price': '\$9.99', 'period': '/month', 'features': ['Unlimited listings', 'Advanced analytics', 'Priority support', 'Featured listings'], 'color': Colors.blue},
    {'name': 'Business', 'price': '\$24.99', 'period': '/month', 'features': ['Everything in Pro', 'Custom storefront', 'Dedicated support', 'Bulk upload', 'API access'], 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Choose Your Plan', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Upgrade to unlock more features', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            ...List.generate(_plans.length, (i) {
              final plan = _plans[i];
              final isSelected = _selectedPlan == i;
              final planColor = plan['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? planColor : colorScheme.outlineVariant, width: isSelected ? 2 : 1),
                    color: isSelected ? planColor.withOpacity(0.05) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(plan['name'] as String, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? planColor : null)),
                            Row(children: [
                              Text(plan['price'] as String, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? planColor : null)),
                              Text(plan['period'] as String, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ]),
                          ]),
                          if (isSelected) Icon(Icons.check_circle, color: planColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(plan['features'] as List<String>).map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          Icon(Icons.check, size: 16, color: isSelected ? planColor : Colors.grey),
                          const SizedBox(width: 8),
                          Text(f, style: theme.textTheme.bodyMedium),
                        ]),
                      )),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscribed to ${(_plans[_selectedPlan]['name'] as String)} plan!')));
                },
                child: Text('Subscribe to ${_plans[_selectedPlan]['name']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
