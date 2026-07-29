import 'package:flutter/material.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../inventory/presentation/inventory_screen.dart';
import '../billing/presentation/billing_screen.dart';
import '../purchases/presentation/purchases_screen.dart';
import '../customers/presentation/customers_screen.dart';
import '../receipts/presentation/receipts_screen.dart';
import '../payments/presentation/payments_screen.dart';
import '../expenses/presentation/expenses_screen.dart';
import '../returns/presentation/returns_screen.dart';
import '../reports/presentation/reports_screen.dart';
import '../reports/presentation/daybook_screen.dart';
import '../reports/presentation/statement_reports_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../calculator/presentation/calculator_dialog.dart';
import '../estimates/presentation/estimates_screen.dart';
import '../returns/presentation/purchase_returns_screen.dart';
import '../delivery/presentation/delivery_notes_screen.dart';
import '../purchases/presentation/purchase_orders_screen.dart';
import '../sales_orders/presentation/sales_orders_screen.dart';
import '../accounting/presentation/contra_entry_screen.dart';
import '../accounting/presentation/journal_voucher_screen.dart';
import '../accounting/presentation/audit_trail_screen.dart';
import '../bank_accounts/presentation/bank_accounts_screen.dart';
import '../stock/presentation/stock_summary_screen.dart';
import '../stock/presentation/items_sold_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'sidebar_widget.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.dashboard_rounded,        label: 'Dashboard',          screen: const DashboardScreen(),       group: 'Home'),
    NavItem(icon: Icons.receipt_long_rounded,     label: 'Sales / Invoices',   screen: const BillingScreen(),         group: 'Transactions'),
    NavItem(icon: Icons.local_mall_rounded,       label: 'Purchases',          screen: const PurchasesScreen(),       group: 'Transactions'),
    NavItem(icon: Icons.call_received_rounded,    label: 'Receipts (In)',       screen: const ReceiptsScreen(),        group: 'Transactions'),
    NavItem(icon: Icons.call_made_rounded,        label: 'Payments (Out)',      screen: const PaymentsScreen(),        group: 'Transactions'),
    NavItem(icon: Icons.money_off_rounded,        label: 'Expenses',           screen: const ExpensesScreen(),        group: 'Transactions'),
    NavItem(icon: Icons.shopping_cart_checkout,   label: 'Sales Orders',       screen: const SalesOrdersScreen(),     group: 'Transactions'),
    NavItem(icon: Icons.note_add_rounded,         label: 'Estimates & Quotes', screen: const EstimatesScreen(),       group: 'Transactions'),
    NavItem(icon: Icons.local_shipping_rounded,   label: 'Delivery Notes',     screen: const DeliveryNotesScreen(),   group: 'Transactions'),
    NavItem(icon: Icons.assignment_return_rounded,label: 'Sales Returns',      screen: const ReturnsScreen(),         group: 'Transactions'),
    NavItem(icon: Icons.assignment_return,        label: 'Purchase Returns',   screen: const PurchaseReturnsScreen(), group: 'Transactions'),
    NavItem(icon: Icons.request_quote_rounded,    label: 'Purchase Orders',    screen: const PurchaseOrdersScreen(),  group: 'Transactions'),
    NavItem(icon: Icons.inventory_2_rounded,      label: 'Inventory Items',    screen: const InventoryScreen(),       group: 'Masters'),
    NavItem(icon: Icons.warehouse,                label: 'Stock Summary',      screen: const StockSummaryScreen(),    group: 'Masters'),
    NavItem(icon: Icons.shopping_cart,            label: 'Items Sold',         screen: const ItemsSoldScreen(),       group: 'Masters'),
    NavItem(icon: Icons.people_rounded,           label: 'Customers',          screen: const CustomersScreen(),       group: 'Masters'),
    NavItem(icon: Icons.account_balance,           label: 'Bank Accounts',      screen: const BankAccountsScreen(),    group: 'Masters'),
    NavItem(icon: Icons.compare_arrows,           label: 'Contra Entries',     screen: const ContraEntryScreen(),     group: 'Accounting'),
    NavItem(icon: Icons.account_balance_wallet,   label: 'Journal Vouchers',   screen: const JournalVoucherScreen(),  group: 'Accounting'),
    NavItem(icon: Icons.book_rounded,             label: 'Day Book (Ledger)',  screen: const DayBookScreen(),         group: 'Reports'),
    NavItem(icon: Icons.bar_chart_rounded,        label: 'Financial Reports',  screen: const ReportsScreen(),         group: 'Reports'),
    NavItem(icon: Icons.description_rounded,      label: 'Statement Reports',  screen: const StatementReportsScreen(), group: 'Reports'),
    NavItem(icon: Icons.history_rounded,          label: 'Audit Trail',        screen: const AuditTrailScreen(),      group: 'Utilities'),
    NavItem(icon: Icons.settings_rounded,         label: 'Settings',           screen: const SettingsScreen(),        group: 'Utilities'),
    NavItem(icon: Icons.calculate,                label: 'Calculator',         screen: const DashboardScreen(),       group: 'Utilities'),
  ];

  void _navigateTo(int index) {
    if (index == 24) {
      showDialog(context: context, builder: (_) => const CalculatorDialog());
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new_invoice': _navigateTo(1); break;
      case 'new_purchase': _navigateTo(2); break;
      case 'new_receipt': _navigateTo(3); break;
      case 'new_payment': _navigateTo(4); break;
      case 'new_expense': _navigateTo(5); break;
      case 'inventory': _navigateTo(12); break;
      case 'customers': _navigateTo(15); break;
      case 'settings': _navigateTo(22); break;
      case 'reports': _navigateTo(20); break;
      case 'daybook': _navigateTo(19); break;
      case 'audit': _navigateTo(21); break;
      case 'calculator': _navigateTo(24); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _MenuBar(onAction: _handleMenuAction),
          _ToolbarRibbon(
            isCompact: isCompact,
            onNewInvoice:  () => _navigateTo(1),
            onNewReceipt:  () => _navigateTo(3),
            onNewExpense:  () => _navigateTo(5),
            onNewPurchase: () => _navigateTo(2),
            onCalculator:  () => showDialog(context: context, builder: (_) => const CalculatorDialog()),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SidebarWidget(
                  selectedIndex: _selectedIndex,
                  items: _navItems,
                  onItemSelected: _navigateTo,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _navItems[_selectedIndex].screen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _StatusBar(appData: null),
        ],
      ),
    );
  }
}

class _MenuBar extends StatelessWidget {
  final ValueChanged<String> onAction;
  const _MenuBar({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 1)),
      ),
      child: Row(
        children: [
          _MenuBarItem(label: 'File', children: [
            _MenuAction(label: 'New Invoice (F8)', shortcut: 'F8', onTap: () => onAction('new_invoice')),
            _MenuAction(label: 'New Purchase (F9)', shortcut: 'F9', onTap: () => onAction('new_purchase')),
            _MenuAction(label: 'New Receipt (F6)', shortcut: 'F6', onTap: () => onAction('new_receipt')),
            _MenuAction(label: 'New Payment', shortcut: 'F7', onTap: () => onAction('new_payment')),
            _MenuAction(label: 'New Expense', shortcut: 'Alt+E', onTap: () => onAction('new_expense')),
            const Divider(height: 1),
            _MenuAction(label: 'Settings', onTap: () => onAction('settings')),
          ]),
          _MenuBarItem(label: 'Masters', children: [
            _MenuAction(label: 'Inventory Items', onTap: () => onAction('inventory')),
            _MenuAction(label: 'Customers', onTap: () => onAction('customers')),
          ]),
          _MenuBarItem(label: 'Reports', children: [
            _MenuAction(label: 'Day Book', onTap: () => onAction('daybook')),
            _MenuAction(label: 'Financial Reports', onTap: () => onAction('reports')),
            _MenuAction(label: 'Audit Trail', onTap: () => onAction('audit')),
          ]),
          _MenuBarItem(label: 'Help', children: [
            _MenuAction(label: 'Calculator', onTap: () => onAction('calculator')),
            _MenuAction(label: 'About BK-Ramgram', onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: AppColors.tableHeaderBg,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset('assets/images/logo_circle.png', width: 16, height: 16, fit: BoxFit.cover),
                              ),
                              SizedBox(width: 6),
                              Text('About BK-Ramgram', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset('assets/images/logo_full.png', width: 120, height: 80, fit: BoxFit.contain),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text('BK-Ramgram Seed ERP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0E8),
                                  border: Border.all(color: AppColors.surfaceBorder),
                                ),
                                child: const Text(
                                  'Book Keeper ERP for Ramgarm Seed Company (PVT) Ltd.\n Wholesale & Retail Seed Management System.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ]),
        ],
      ),
    );
  }
}

class _MenuBarItem extends StatefulWidget {
  final String label;
  final List<Widget> children;
  const _MenuBarItem({required this.label, required this.children});

  @override
  State<_MenuBarItem> createState() => _MenuBarItemState();
}

class _MenuBarItemState extends State<_MenuBarItem> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (_isOpen) setState(() => _isOpen = true);
      },
      child: GestureDetector(
        onTap: () => setState(() => _isOpen = !_isOpen),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              color: _isOpen ? AppColors.primary.withAlpha(30) : Colors.transparent,
              child: Text(widget.label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
            ),
            if (_isOpen)
              Positioned(
                top: 24,
                left: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Material(
                    elevation: 0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.children.map((c) => c).toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final String label;
  final String? shortcut;
  final VoidCallback? onTap;
  const _MenuAction({required this.label, this.shortcut, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
        // Close all menus
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
            if (shortcut != null)
              Text(shortcut!, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final dynamic appData;
  const _StatusBar({required this.appData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.statusBarBg,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, size: 7, color: AppColors.success),
          SizedBox(width: 6),
          Text('Ready', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Spacer(),
          Text('BK-Ramgram Seed  |  FY 2025-2026', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          SizedBox(width: 16),
          Text('Gold Plan', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ToolbarRibbon extends StatelessWidget {
  const _ToolbarRibbon({
    required this.isCompact,
    required this.onNewInvoice,
    required this.onNewReceipt,
    required this.onNewExpense,
    required this.onNewPurchase,
    required this.onCalculator,
  });

  final bool isCompact;
  final VoidCallback onNewInvoice;
  final VoidCallback onNewReceipt;
  final VoidCallback onNewExpense;
  final VoidCallback onNewPurchase;
  final VoidCallback onCalculator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: AppColors.ribbonBg,
        border: Border(bottom: BorderSide(color: AppColors.ribbonBorder)),
      ),
      child: Row(
        children: [
          _RibbonBtn(label: 'F8: Sale/Invoice',   icon: Icons.receipt_long,   onTap: onNewInvoice, compact: isCompact),
          const _RibbonDivider(),
          _RibbonBtn(label: 'F6: Receipt',         icon: Icons.call_received,  onTap: onNewReceipt,  compact: isCompact),
          const _RibbonDivider(),
          _RibbonBtn(label: 'Alt+E: Expense',      icon: Icons.money_off,      onTap: onNewExpense,  compact: isCompact),
          const _RibbonDivider(),
          _RibbonBtn(label: 'F9: Purchase',        icon: Icons.local_shipping, onTap: onNewPurchase, compact: isCompact),
          const Spacer(),
          if (!isCompact) ...[
            const Text('Ctrl+F: Search', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(width: 12),
          ],
          Tooltip(
            message: 'Calculator',
            child: InkWell(
              onTap: onCalculator,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(Icons.calculate, size: 16, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonBtn extends StatelessWidget {
  const _RibbonBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: compact ? label : '',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: compact
              ? Icon(icon, size: 15, color: AppColors.textPrimary)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: AppColors.textPrimary),
                    const SizedBox(width: 4),
                    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RibbonDivider extends StatelessWidget {
  const _RibbonDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: AppColors.ribbonBorder,
    );
  }
}
