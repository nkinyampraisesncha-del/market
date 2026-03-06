import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue (Last 7 Days)', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  SizedBox(height: 150, child: LineChart(LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: const [FlSpot(0,100), FlSpot(1,250), FlSpot(2,180), FlSpot(3,400), FlSpot(4,320), FlSpot(5,500), FlSpot(6,450)],
                      isCurved: true, color: colorScheme.primary, barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: colorScheme.primary.withOpacity(0.1)),
                    )],
                  ))),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Row(children: [
              _MetricCard(label: 'New Users', value: '0', change: '+0%', positive: true),
              const SizedBox(width: 12),
              _MetricCard(label: 'Active Listings', value: '0', change: '+0%', positive: true),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _MetricCard(label: 'Total Orders', value: '0', change: '+0%', positive: true),
              const SizedBox(width: 12),
              _MetricCard(label: 'Revenue', value: '\$0', change: '+0%', positive: true),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool positive;

  const _MetricCard({required this.label, required this.value, required this.change, required this.positive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(change, style: TextStyle(color: positive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
