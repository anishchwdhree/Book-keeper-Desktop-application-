import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/customer_model.dart';
import 'add_customer_dialog.dart';
import '../utils/customer_statement_pdf.dart';
import 'customer_ledger_screen.dart';
import 'customer_receivables_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  String _filterType = 'All';
  final _searchController = TextEditingController();

  List<CustomerModel> get _filtered {
    var list = List<CustomerModel>.from(_appData.customers);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.phone.contains(q) ||
        c.vatNumber.contains(q) ||
        c.address.toLowerCase().contains(q) ||
        c.safeBankName.toLowerCase().contains(q)
      ).toList();
    }

    if (_filterType != 'All') {
      if (_filterType == 'With Balance') {
        list = list.where((c) => c.outstandingBalance > 0).toList();
      } else if (_filterType == 'Clear') {
        list = list.where((c) => c.outstandingBalance <= 0).toList();
      } else if (_filterType == 'Wholesale') {
        list = list.where((c) => c.rateType.toLowerCase().contains('wholesale')).toList();
      } else if (_filterType == 'Retail') {
        list = list.where((c) => c.rateType.toLowerCase().contains('retail')).toList();
      }
    }

    return list;
  }

  void _openDialog([CustomerModel? customer]) async {
    final result = await showDialog<CustomerModel>(
      context: context,
      builder: (_) => AddCustomerDialog(customer: customer),
    );
    if (result != null) {
      setState(() {
        if (customer != null) {
          _appData.updateCustomer(result);
        } else {
          _appData.addCustomer(result);
        }
      });
    }
  }

  void _openLedger(CustomerModel c) {
    showDialog(context: context, builder: (_) => CustomerLedgerScreen(customer: c));
  }

  void _printStatement(CustomerModel c) {
    final ledger = _appData.getCustomerLedger(c.id!);
    CustomerStatementPdfGenerator.printStatement(context, c, _appData.settings, ledger);
  }

  void _delete(CustomerModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Delete Customer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to delete "${c.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _appData.deleteCustomer(c.id!));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _gridBorder = BorderSide(color: Color(0xFFD5D8DF), width: 0.6);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final totalCustomersCount = _appData.customers.length;
        final totalReceivablesAmt = _appData.totalReceivables;
        final withBalanceCount = _appData.customers.where((c) => c.outstandingBalance > 0).length;
        final wholesaleCount = _appData.customers.where((c) => c.rateType.toLowerCase().contains('wholesale')).length;

        return Container(
          color: const Color(0xFFEBEBE4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Header & KPI Executive Summary Band ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer Management & Directory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('Manage customer master profiles, selling preferences, bank details & outstanding ledger balances', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerReceivablesScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: const Text('Receive Credit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _openDialog(),
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('Add New Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _kpiCard('TOTAL CUSTOMERS', '$totalCustomersCount Accounts', Icons.people, AppColors.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: _kpiCard('TOTAL RECEIVABLES', 'Rs. ${totalReceivablesAmt.toStringAsFixed(0)}', Icons.monetization_on, AppColors.error)),
                        const SizedBox(width: 10),
                        Expanded(child: _kpiCard('PENDING ACCOUNTS', '$withBalanceCount Unsettled', Icons.pending_actions, AppColors.warning)),
                        const SizedBox(width: 10),
                        Expanded(child: _kpiCard('WHOLESALE CLIENTS', '$wholesaleCount Clients', Icons.storefront, AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Search & Filter Ribbon ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: const Color(0xFFF4F4EE),
                child: Row(
                  children: [
                    SizedBox(
                      width: 320,
                      height: 30,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search customer name, phone, address, bank...',
                          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                          prefixIconConstraints: const BoxConstraints(minWidth: 30),
                          filled: true,
                          fillColor: AppColors.searchBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _gridBorder),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _gridBorder),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ],
                    const SizedBox(width: 12),

                    // Filter Chips
                    _buildFilterChip('All', _filterType == 'All', () => setState(() => _filterType = 'All')),
                    const SizedBox(width: 6),
                    _buildFilterChip('With Balance', _filterType == 'With Balance', () => setState(() => _filterType = 'With Balance')),
                    const SizedBox(width: 6),
                    _buildFilterChip('Paid Up', _filterType == 'Clear', () => setState(() => _filterType = 'Clear')),
                    const SizedBox(width: 6),
                    _buildFilterChip('Wholesale', _filterType == 'Wholesale', () => setState(() => _filterType = 'Wholesale')),
                    const SizedBox(width: 6),
                    _buildFilterChip('Retail', _filterType == 'Retail', () => setState(() => _filterType = 'Retail')),

                    const Spacer(),
                    Text(
                      'Showing ${_filtered.length} of $totalCustomersCount customers',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // ── Excel Data Grid (Header + Rows) ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const minWidth = 1170.0;
                    final gridWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
                    final extra = gridWidth - minWidth;
                    final nameWidth = 150.0 + (extra * 0.22);
                    final addrWidth = 120.0 + (extra * 0.15);
                    final itemsWidth = 160.0 + (extra * 0.28);
                    final payWidth = 130.0 + (extra * 0.15);
                    final outWidth = 100.0 + (extra * 0.10);
                    final actWidth = 120.0 + (extra * 0.10);

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: gridWidth,
                        height: constraints.maxHeight,
                        child: Column(
                          children: [
                            // Excel Header Row
                            Container(
                              height: 32,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  _excelHeader('S.NO', 40),
                                  _excelHeader('CUSTOMER NAME', nameWidth),
                                  _excelHeader('PHONE', 95),
                                  _excelHeader('ADDRESS', addrWidth),
                                  _excelHeader('PURCHASED ITEMS', itemsWidth),
                                  _excelHeader('RATE TYPE', 75),
                                  _excelHeader('PREFERRED UNIT', 70),
                                  _excelHeader('TYPICAL QTY / RATE', 110),
                                  _excelHeader('PAY VIA / BANK DETAILS', payWidth),
                                  _excelHeader('OUTSTANDING (RS)', outWidth, isNum: true),
                                  _excelHeader('ACTIONS', actWidth),
                                ],
                              ),
                            ),

                            // Excel Data Rows
                            Expanded(
                              child: _appData.customers.isEmpty && _searchQuery.isEmpty
                                  ? _buildEmpty('No customers registered yet', Icons.people_outline, () => _openDialog(), 'Add First Customer')
                                  : _filtered.isEmpty
                                      ? const Center(child: Text('No matching customers found', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)))
                                      : ListView.builder(
                                          itemCount: _filtered.length,
                                          itemBuilder: (ctx, i) {
                                            final c = _filtered[i];

                                            // Compute purchased items summary from sales history for this customer
                                            final customerSales = _appData.sales.where((s) => (s.customerId != null && s.customerId == c.id) || s.customerName.toLowerCase() == c.name.toLowerCase());
                                            final Map<String, double> itemTotals = {};
                                            for (final s in customerSales) {
                                              for (final item in s.items) {
                                                itemTotals[item.product.name] = (itemTotals[item.product.name] ?? 0.0) + item.quantity;
                                              }
                                            }
                                            final String purchasedItemsSummary = itemTotals.isNotEmpty
                                                ? itemTotals.entries.map((e) {
                                                    final qtyStr = e.value % 1 == 0 ? e.value.toInt().toString() : e.value.toStringAsFixed(1);
                                                    return '${e.key} ($qtyStr Kg)';
                                                  }).join(', ')
                                                : (c.purchasedItems.isNotEmpty ? c.purchasedItems : '-');

                                            final bool hasBank = c.paymentMethod == 'Bank Transfer' || c.safeBankName.isNotEmpty;
                                            final String paymentDisplay = hasBank
                                                ? (c.safeBankName.isNotEmpty ? c.safeBankName : 'Bank Transfer')
                                                : c.paymentMethod;

                                            final String qtyDisplay = c.typicalQuantity > 0
                                                ? '${c.typicalQuantity.toStringAsFixed(0)} ${c.preferredUnit}'
                                                : c.preferredUnit;

                                            return InkWell(
                                              hoverColor: const Color(0xFFEBF3FA),
                                              onTap: () => _openLedger(c),
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                                  border: const Border(bottom: _gridBorder),
                                                ),
                                                child: Row(
                                                  children: [
                                                    _excelCell('${i + 1}', 40, isNum: true, textColor: AppColors.textHint),
                                                    _excelCell(c.name, nameWidth, isBold: true),
                                                    _excelCell(c.phone.isNotEmpty ? c.phone : '-', 95),
                                                    _excelCell(c.address.isNotEmpty ? c.address : '-', addrWidth),
                                                    _excelCell(purchasedItemsSummary, itemsWidth, isBold: itemTotals.isNotEmpty, textColor: itemTotals.isNotEmpty ? AppColors.primary : AppColors.textPrimary),
                                                    _excelCellBadge(c.rateType.isNotEmpty ? c.rateType : 'Standard', 75, const Color(0xFF003399)),
                                                    _excelCell(c.preferredUnit, 70),
                                                    _excelCell('$qtyDisplay @ Rs.${c.sellingRate.toStringAsFixed(0)}', 110),

                                                    // Pay Via Cell with Bank Details Hover Tooltip
                                                    Tooltip(
                                                      richMessage: TextSpan(
                                                        children: [
                                                          TextSpan(text: '🏛️ Bank: ${c.safeBankName.isNotEmpty ? c.safeBankName : "Bank Account"}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                                          TextSpan(text: '👤 Account Holder: ${c.safeAccountHolder.isNotEmpty ? c.safeAccountHolder : c.name}\n', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                                          TextSpan(text: '💳 Account Number: ${c.safeAccountNumber.isNotEmpty ? c.safeAccountNumber : "N/A"}', style: const TextStyle(fontSize: 11, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF1E293B),
                                                        borderRadius: BorderRadius.circular(4),
                                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                                      ),
                                                      padding: const EdgeInsets.all(10),
                                                      child: Container(
                                                        width: payWidth,
                                                        height: 32,
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        decoration: const BoxDecoration(border: Border(right: _gridBorder)),
                                                        alignment: Alignment.centerLeft,
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              hasBank ? Icons.account_balance : Icons.payments,
                                                              size: 13,
                                                              color: hasBank ? AppColors.primary : AppColors.secondary,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                paymentDisplay,
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight: hasBank ? FontWeight.bold : FontWeight.w400,
                                                                  color: hasBank ? AppColors.primary : AppColors.textPrimary,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // Outstanding Balance Column
                                                    Container(
                                                      width: outWidth,
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
                                                      alignment: Alignment.centerRight,
                                                      child: c.outstandingBalance > 0
                                                          ? _excelStatusBadge('Rs. ${c.outstandingBalance.toStringAsFixed(0)}', AppColors.error)
                                                          : _excelStatusBadge('CLEAR', AppColors.success),
                                                    ),

                                                    // Actions Buttons Column
                                                    SizedBox(
                                                      width: actWidth,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Tooltip(
                                                            message: 'Customer Ledger',
                                                            child: InkWell(
                                                              onTap: () => _openLedger(c),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(color: AppColors.info.withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                                child: const Icon(Icons.book, size: 14, color: AppColors.info),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Tooltip(
                                                            message: 'Print Statement',
                                                            child: InkWell(
                                                              onTap: () => _printStatement(c),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(color: AppColors.secondary.withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                                child: const Icon(Icons.print, size: 14, color: AppColors.secondary),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Tooltip(
                                                            message: 'Edit Profile',
                                                            child: InkWell(
                                                              onTap: () => _openDialog(c),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                                child: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Tooltip(
                                                            message: 'Delete Customer',
                                                            child: InkWell(
                                                              onTap: () => _delete(c),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                                child: const Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                                                              ),
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
                                        ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Excel Status Bar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.table_chart, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Ready  |  Total Customers: $totalCustomersCount  |  Receivables: Rs. ${totalReceivablesAmt.toStringAsFixed(0)}  |  Filtered: ${_filtered.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Text('BK ERP Customer Directory', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFD5D8DF)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(3)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: isSelected ? AppColors.primary : _gridBorder.color),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String message, IconData icon, VoidCallback onPressed, String btnLabel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint.withAlpha(80)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 30,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add, size: 15),
              label: Text(btnLabel, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _excelHeader(String text, double width, {bool isNum = false}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF333333), letterSpacing: 0.3),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _excelCell(String text, double width, {bool isNum = false, bool isBold = false, Color? textColor}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: textColor ?? AppColors.textPrimary),
      ),
    );
  }

  Widget _excelCellBadge(String text, double width, Color color) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(2)),
        child: Text(
          text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _excelStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(50)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
