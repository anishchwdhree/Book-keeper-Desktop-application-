import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_data.dart';

class TopSellingProducts extends StatelessWidget {
  final AppData appData;

  const TopSellingProducts({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    // Aggregate quantity sold per product this month
    final now = DateTime.now();
    final Map<int, double> qtySold = {};
    final Map<int, String> names = {};

    for (final sale in appData.sales) {
      if (sale.date.year == now.year && sale.date.month == now.month) {
        for (final item in sale.items) {
          final pid = item.product.id!;
          qtySold[pid] = (qtySold[pid] ?? 0) + item.quantityInKg;
          names[pid] = item.product.name;
        }
      }
    }

    final sorted = qtySold.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.tableHeaderBg,
            child: Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Top 5 Selling Products (This Month)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          if (top5.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No sales this month', style: TextStyle(color: AppColors.textHint))),
            )
          else
            ...List.generate(top5.length, (i) {
              final entry = top5[i];
              final name = names[entry.key] ?? 'Unknown';
              final qty = entry.value;
              final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceBorder))),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text(medal, style: const TextStyle(fontSize: 14))),
                    Expanded(
                      child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Text('${qty.toStringAsFixed(1)} Kg', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
