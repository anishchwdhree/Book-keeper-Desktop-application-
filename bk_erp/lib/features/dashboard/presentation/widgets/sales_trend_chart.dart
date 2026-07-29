import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_data.dart';

class SalesTrendChart extends StatelessWidget {
  final AppData appData;

  const SalesTrendChart({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Get sales for the last 7 days (including today)
    List<FlSpot> spots = [];
    double maxSales = 0;
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dailySales = appData.sales
          .where((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day)
          .fold(0.0, (sum, s) => sum + s.grandTotal);
      
      spots.add(FlSpot((6 - i).toDouble(), dailySales));
      if (dailySales > maxSales) maxSales = dailySales;
    }
    
    // Default maxSales to 100 to avoid flatline at 0
    if (maxSales == 0) maxSales = 100;

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
            child: const Text('Sales Trend (Last 7 Days)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxSales * 1.2,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, 
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(NumberFormat.compact().format(value), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          );
                        }
                      )
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx <= 6) {
                            final d = now.subtract(Duration(days: 6 - idx));
                            final title = DateFormat('E').format(d); // e.g. Mon, Tue
                            return SideTitleWidget(axisSide: meta.axisSide, child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
