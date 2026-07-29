import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AccountGrid extends StatelessWidget {
  final String title;
  final List<List<String>> items;

  const AccountGrid({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
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
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.isEmpty ? 1 : items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surfaceBorder),
            itemBuilder: (context, index) {
              if (items.isEmpty) return const Padding(padding: EdgeInsets.all(12), child: Text('No records', style: TextStyle(color: AppColors.textHint)));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(items[index][0], style: const TextStyle(color: AppColors.textPrimary)),
                    Text(items[index][1], style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
