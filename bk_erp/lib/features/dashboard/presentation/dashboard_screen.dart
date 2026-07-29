import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../../core/utils/nepali_date.dart';
import '../../../core/utils/responsive.dart';

import '../../billing/presentation/create_invoice_dialog.dart';
import '../../billing/models/sale_model.dart';
import '../../purchases/presentation/add_purchase_dialog.dart';
import '../../purchases/models/purchase_model.dart';
import '../../customers/presentation/add_customer_dialog.dart';
import '../../customers/models/customer_model.dart';

import 'widgets/account_grid.dart';
import 'widgets/payment_summary.dart';
import 'widgets/low_stock_grid.dart';
import 'widgets/sales_trend_chart.dart';
import 'widgets/income_expense_chart.dart';
import 'widgets/top_selling_products.dart';
import 'widgets/recent_transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _appData = AppData();
  final nf = NumberFormat.currency(locale: 'en_NP', symbol: 'Rs. ');

  void _createNewInvoice() async {
    final result = await showDialog<SaleModel>(
      context: context,
      builder: (_) => const CreateInvoiceDialog(),
    );
    if (result != null && mounted) {
      setState(() => _appData.addSale(result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tax Invoice created successfully.')),
      );
    }
  }

  void _createNewPurchase() async {
    if (_appData.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a supplier first!')),
      );
      return;
    }
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add products in Inventory first!'),
        ),
      );
      return;
    }
    final result = await showDialog<PurchaseModel>(
      context: context,
      builder: (_) => const AddPurchaseDialog(),
    );
    if (result != null && mounted) {
      setState(() => _appData.addPurchase(result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase entry added successfully.')),
      );
    }
  }

  void _addCustomer() async {
    final result = await showDialog<CustomerModel>(
      context: context,
      builder: (_) => const AddCustomerDialog(),
    );
    if (result != null && mounted) {
      setState(() => _appData.addCustomer(result));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Customer profile added.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.contentPadding;
    final isCompact = context.isCompact;
    final todayBsStr = NepaliDate.todayFormatted();
    final todayAdStr = DateFormat('EEE, dd MMM yyyy').format(DateTime.now());

    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final totalCashBank = _appData.cashInHand + _appData.bankBalance;

        final bankRows = <List<String>>[
          ['Cash in Hand', nf.format(_appData.cashInHand)],
        ];
        if (_appData.bankAccounts.isNotEmpty) {
          for (final a in _appData.bankAccounts) {
            final bal = _appData.getBankAccountBalance(a.id ?? 0);
            bankRows.add([a.bankName, nf.format(bal)]);
          }
        } else {
          bankRows.add([
            'Bank Accounts Total',
            nf.format(_appData.bankBalance),
          ]);
        }

        return Container(
          color: const Color(0xFFEBEBE4),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Executive Welcome Banner & Quick Actions ──────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.dashboard_customize,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ramgram Seed Company Private Limited',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        'Miti: BS $todayBsStr',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '($todayAdStr)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Quick Action Buttons
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _createNewInvoice,
                                icon: const Icon(Icons.receipt_long, size: 15),
                                label: const Text(
                                  'Create Invoice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _createNewPurchase,
                                icon: const Icon(Icons.shopping_cart, size: 15),
                                label: const Text(
                                  'Add Purchase',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _addCustomer,
                                icon: const Icon(Icons.person_add, size: 15),
                                label: const Text(
                                  'Add Customer',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.surfaceBorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: pad),

                // ── Top Financial KPI Cards Row ────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _kpiSummaryCard(
                        'MONTHLY SALES',
                        nf.format(_appData.monthlySales),
                        '${_appData.sales.length} Invoices Recorded',
                        Icons.monetization_on,
                        const Color(0xFF1B5E20),
                        const Color(0xFFE8F5E9),
                      ),
                    ),
                    SizedBox(width: pad),
                    Expanded(
                      child: _kpiSummaryCard(
                        'CASH & BANK BALANCES',
                        nf.format(totalCashBank),
                        'Cash: ${nf.format(_appData.cashInHand)}',
                        Icons.account_balance_wallet,
                        AppColors.primary,
                        const Color(0xFFEBF3FA),
                      ),
                    ),
                    SizedBox(width: pad),
                    Expanded(
                      child: _kpiSummaryCard(
                        'CUSTOMER RECEIVABLES',
                        nf.format(_appData.totalReceivables),
                        'Money to Collect',
                        Icons.pending_actions,
                        AppColors.warning,
                        const Color(0xFFFFF8E1),
                      ),
                    ),
                    SizedBox(width: pad),
                    Expanded(
                      child: _kpiSummaryCard(
                        'SUPPLIER PAYABLES',
                        nf.format(_appData.totalPayables),
                        'Money to Pay',
                        Icons.outbox,
                        AppColors.error,
                        const Color(0xFFFFEBEE),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: pad),

                // ── Main Managed 2-Column Dashboard Grid ──────────────────
                if (isCompact)
                  Column(
                    children: [
                      // Financial Summary
                      AccountGrid(
                        title: 'Financial Summary (This Month)',
                        items: [
                          [
                            'Total Sales Revenue',
                            nf.format(_appData.monthlySales),
                          ],
                          [
                            'Total Purchases Cost',
                            nf.format(_appData.monthlyPurchases),
                          ],
                          [
                            'Operating Expenses',
                            nf.format(_appData.monthlyExpenses),
                          ],
                          [
                            'Estimated Net Profit',
                            nf.format(_appData.monthlyProfit),
                          ],
                        ],
                      ),
                      SizedBox(height: pad),
                      AccountGrid(
                        title: 'Cash / Bank Balances',
                        items: bankRows,
                      ),
                      SizedBox(height: pad),
                      PaymentSummary(appData: _appData, nf: nf),
                      SizedBox(height: pad),
                      LowStockGrid(appData: _appData),
                      SizedBox(height: pad),
                      SalesTrendChart(appData: _appData),
                      SizedBox(height: pad),
                      IncomeExpenseChart(appData: _appData),
                      SizedBox(height: pad),
                      TopSellingProducts(appData: _appData),
                      SizedBox(height: pad),
                      RecentTransactions(appData: _appData, nf: nf),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── LEFT COLUMN (60% Width): Performance & Trends ──
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            // Monthly P&L Summary & Cash Accounts side by side
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AccountGrid(
                                    title: 'Financial Summary (This Month)',
                                    items: [
                                      [
                                        'Total Sales Revenue',
                                        nf.format(_appData.monthlySales),
                                      ],
                                      [
                                        'Total Purchases Cost',
                                        nf.format(_appData.monthlyPurchases),
                                      ],
                                      [
                                        'Operating Expenses',
                                        nf.format(_appData.monthlyExpenses),
                                      ],
                                      [
                                        'Estimated Net Profit',
                                        nf.format(_appData.monthlyProfit),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(width: pad),
                                Expanded(
                                  child: AccountGrid(
                                    title: 'Liquid Cash & Bank Ledgers',
                                    items: bankRows,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: pad),

                            // Sales Trend Analytics Chart
                            SalesTrendChart(appData: _appData),
                            SizedBox(height: pad),

                            // Income vs Expense Chart
                            IncomeExpenseChart(appData: _appData),
                            SizedBox(height: pad),

                            // Recent Transactions Audit Log
                            RecentTransactions(appData: _appData, nf: nf),
                          ],
                        ),
                      ),
                      SizedBox(width: pad),

                      // ── RIGHT COLUMN (40% Width): Stock Alerts & Best Sellers ──
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            // Low Stock Reorder Alerts Grid
                            LowStockGrid(appData: _appData),
                            SizedBox(height: pad),

                            // Cash vs Online / Bank Payment Breakdown
                            PaymentSummary(appData: _appData, nf: nf),
                            SizedBox(height: pad),

                            // Top Selling Seed Products
                            TopSellingProducts(appData: _appData),
                          ],
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: pad),

                // ── Status Bar Footer ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusBarBg,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ERP System Active  |  Products: ${_appData.products.length}  |  Customers: ${_appData.customers.length}  |  Suppliers: ${_appData.suppliers.length}  |  Invoices: ${_appData.sales.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'BK ERP Engine v2.5',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kpiSummaryCard(
    String title,
    String mainValue,
    String subValue,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withAlpha(80)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mainValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subValue,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
