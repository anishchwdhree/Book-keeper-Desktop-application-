import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_data.dart';

class LowStockGrid extends StatelessWidget {
  final AppData appData;

  const LowStockGrid({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = appData.products.where((p) => p.isLowStock).toList();
    
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
            color: AppColors.cardRed,
            child: const Text('Low Stock Alerts', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStockItems.isEmpty ? 1 : (lowStockItems.length > 5 ? 5 : lowStockItems.length),
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surfaceBorder),
            itemBuilder: (context, index) {
              if (lowStockItems.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('Stock levels OK', style: TextStyle(color: AppColors.success)));
              final product = lowStockItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(product.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary))),
                    Text('${product.currentStock} left', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                  ],
                ),
              );
            },
          ),
          if (lowStockItems.length > 5) ...[
            const Divider(height: 1, color: AppColors.surfaceBorder),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {}, // Go to inventory
                child: const Text('View All', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            )
          ]
        ],
      ),
    );
  }
}
