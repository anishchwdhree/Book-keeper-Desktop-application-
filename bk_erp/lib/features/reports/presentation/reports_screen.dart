import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _appData = AppData();
  final nf = NumberFormat.currency(locale: 'en_NP', symbol: 'Rs. ');
  String _activeReport = 'Profit & Loss';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        return Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.tableHeaderBg,
                child: const Row(
                  children: [
                    Icon(Icons.assessment, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Financial Reports', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(bottom: BorderSide(color: AppColors.surfaceBorder))),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Profit & Loss', 'Balance Sheet', 'Tax Summary'].map((tab) {
                      final isActive = _activeReport == tab;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () => setState(() => _activeReport = tab),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(tab, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textSecondary)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(child: _buildActiveReport()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveReport() {
    switch (_activeReport) {
      case 'Profit & Loss': return _buildProfitLoss();
      case 'Balance Sheet': return _buildBalanceSheet();
      case 'Tax Summary': return _buildTaxSummary();
      default: return const SizedBox();
    }
  }

  Widget _buildProfitLoss() {
    final sales = _appData.monthlySales;
    final purchases = _appData.monthlyPurchases;
    final expenses = _appData.monthlyExpenses;
    final grossProfit = sales - purchases;
    final netProfit = grossProfit - expenses;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.tableHeaderBg,
            child: const Text('Profit & Loss Statement', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reportSection('INCOME', [
                    ['Total Sales Revenue', nf.format(sales)],
                  ]),
                  _reportSection('COST OF GOODS', [
                    ['Total Purchases', nf.format(purchases)],
                  ]),
                  _reportHighlight('GROSS PROFIT', nf.format(grossProfit), grossProfit >= 0),
                  _reportSection('OPERATING EXPENSES', [
                    ['Total Operating Expenses', nf.format(expenses)],
                  ]),
                  _reportHighlight('NET PROFIT / (LOSS)', nf.format(netProfit), netProfit >= 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSheet() {
    double assetStock = _appData.products.fold(0.0, (sum, p) => sum + p.currentStock * p.sellingPrice);
    double assetCash = _appData.cashInHand;
    double assetBank = _appData.bankBalance;
    double assetDebtors = _appData.totalReceivables;
    double totalAssets = assetStock + assetCash + assetBank + assetDebtors;
    double liabCreditors = _appData.totalPayables;
    double equity = totalAssets - liabCreditors;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.tableHeaderBg,
            child: const Text('Balance Sheet', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reportSection('ASSETS', [
                    ['Cash in Hand', nf.format(assetCash)],
                    ['Bank Accounts', nf.format(assetBank)],
                    ['Sundry Debtors', nf.format(assetDebtors)],
                    ['Closing Stock', nf.format(assetStock)],
                  ]),
                  _reportHighlight('TOTAL ASSETS', nf.format(totalAssets), true),
                  _reportSection('LIABILITIES & EQUITY', [
                    ['Sundry Creditors', nf.format(liabCreditors)],
                    ['Capital Account', nf.format(equity)],
                  ]),
                  _reportHighlight('TOTAL LIAB. & EQUITY', nf.format(liabCreditors + equity), true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSummary() {
    final vatCollected = _appData.totalVatCollected;
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.tableHeaderBg,
            child: const Text('Tax Summary (VAT)', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reportSection('VAT COLLECTED ON SALES', [
                    ['13% VAT on Taxable Sales', nf.format(vatCollected)],
                  ]),
                  _reportSection('VAT PAID ON PURCHASES', [
                    ['13% VAT on Taxable Purchases', 'Rs. 0.00'],
                  ]),
                  _reportHighlight('NET VAT PAYABLE TO IRD', nf.format(vatCollected), false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportSection(String label, List<List<String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
        ...rows.map((r) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(r[0], style: const TextStyle(fontSize: 13)),
            Text(r[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        )),
      ],
    );
  }

  Widget _reportHighlight(String label, String value, bool positive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: positive ? AppColors.cardGreen : AppColors.cardRed,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: positive ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: positive ? AppColors.success : AppColors.error)),
      ]),
    );
  }
}
