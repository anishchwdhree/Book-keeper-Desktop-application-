import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_data.dart';

class IncomeExpenseChart extends StatelessWidget {
  final AppData appData;

  const IncomeExpenseChart({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    final income = appData.monthlySales + appData.monthlyReceipts;
    final expense = appData.monthlyPurchases + appData.monthlyExpenses + appData.monthlyPayments;
    final total = income + expense;
    final incomePct = total > 0 ? (income / total * 100) : 50.0;
    final expensePct = total > 0 ? (expense / total * 100) : 50.0;
    
    // Profit margin based on income
    final profitPct = income > 0 ? ((income - expense) / income * 100) : 0.0;

    return Container(
      height: 250,
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
            child: const Text('Income vs Expense (This Month)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.success,
                          value: incomePct,
                          title: 'In',
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: AppColors.error,
                          value: expensePct,
                          title: 'Out',
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Text('Margin\n${profitPct.toStringAsFixed(1)}%', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}
