import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_data.dart';

class RecentTransactions extends StatelessWidget {
  final AppData appData;
  final NumberFormat nf;

  const RecentTransactions({super.key, required this.appData, required this.nf});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.tableHeaderBg,
            child: const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          appData.recentSales.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No recent transactions.', style: TextStyle(color: AppColors.textHint))),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appData.recentSales.length > 8 ? 8 : appData.recentSales.length,
                itemBuilder: (context, index) {
                  final s = appData.recentSales[index];
                  return Container(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceBorder))),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                      title: Text(s.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(s.invoiceNumber),
                      trailing: Text(nf.format(s.grandTotal), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}
