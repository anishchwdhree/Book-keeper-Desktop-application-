import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/sale_model.dart';
import '../../customers/models/customer_model.dart';
import 'create_invoice_dialog.dart';
import '../utils/invoice_pdf_generator.dart';

enum InvoiceSortColumn { invoiceNumber, date, customer, amount, status }

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  String _dateFilter = 'All Time';
  String _statusFilter = 'All';

  InvoiceSortColumn _sortColumn = InvoiceSortColumn.date;
  bool _sortAscending = false;

  List<SaleModel> get _filteredSales {
    var list = List<SaleModel>.from(_appData.sales);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
          s.invoiceNumber.toLowerCase().contains(q) ||
          s.customerName.toLowerCase().contains(q)).toList();
    }

    if (_statusFilter != 'All') {
      if (_statusFilter == 'Overdue') {
        list = list.where((s) => s.isOverdue).toList();
      } else {
        list = list.where((s) => s.status == _statusFilter).toList();
      }
    }

    if (_dateFilter != 'All Time') {
      final now = DateTime.now();
      if (_dateFilter == 'This Month') {
        list = list.where((s) => s.date.year == now.year && s.date.month == now.month).toList();
      } else if (_dateFilter == 'Last Month') {
        final lastMonth = DateTime(now.year, now.month - 1);
        list = list.where((s) => s.date.year == lastMonth.year && s.date.month == lastMonth.month).toList();
      } else if (_dateFilter == 'This Year') {
        list = list.where((s) => s.date.year == now.year).toList();
      }
    }

    list.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case InvoiceSortColumn.invoiceNumber:
          comparison = a.invoiceNumber.compareTo(b.invoiceNumber);
          break;
        case InvoiceSortColumn.date:
          comparison = a.date.compareTo(b.date);
          break;
        case InvoiceSortColumn.customer:
          comparison = a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase());
          break;
        case InvoiceSortColumn.amount:
          comparison = a.grandTotal.compareTo(b.grandTotal);
          break;
        case InvoiceSortColumn.status:
          comparison = a.status.compareTo(b.status);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return list;
  }

  void _onSort(InvoiceSortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

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

  void _deleteInvoice(SaleModel s) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Container(
          width: 420,
          decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppColors.error,
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Delete Invoice', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete invoice ${s.invoiceNumber}?', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${s.customerName}', style: const TextStyle(fontSize: 12)),
                          Text('Amount: Rs. ${s.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                          Text('Status: ${s.status}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will restore stock and reverse any outstanding balance. This action cannot be undone.',
                      style: TextStyle(fontSize: 11, color: AppColors.error),
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
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          side: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _appData.deleteSale(s));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.invoiceNumber} deleted. Stock restored.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Delete Invoice', style: TextStyle(fontSize: 12, color: Colors.white)),
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
  }

  void _viewInvoice(SaleModel s) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Container(
          width: 540,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppColors.tableHeaderBg,
                child: Row(
                  children: [
                    const Icon(Icons.receipt, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text('Invoice ${s.invoiceNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white70, size: 16),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Customer', s.customerName),
                      _detailRow('Date', DateFormat('dd-MMM-yyyy HH:mm').format(s.date)),
                      if (s.miti.isNotEmpty) _detailRow('Nepali Miti', s.miti),
                      if (s.dueDate != null)
                        _detailRow('Due Date', DateFormat('dd-MMM-yyyy').format(s.dueDate!)),
                      _detailRow('Payment Mode', s.paymentMethod),
                      _detailRow('Status', s.isOverdue ? 'Overdue' : s.status),
                      if (s.notes.isNotEmpty) _detailRow('Notes', s.notes),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 26,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              color: AppColors.tableHeaderBg,
                              child: Row(
                                children: [
                                  _headerCell('Product', flex: 4, alignRight: false),
                                  _headerCell('Unit', flex: 1, alignRight: false),
                                  _headerCell('Qty', flex: 1),
                                  _headerCell('Rate', flex: 2),
                                  _headerCell('Amount', flex: 2),
                                ],
                              ),
                            ),
                            ...s.items.asMap().entries.map((entry) {
                              final i = entry.value;
                              final isEven = entry.key % 2 == 0;
                              return Container(
                                height: 26,
                                color: isEven ? AppColors.surface : const Color(0xFFF5F5F0),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    _dataCell(i.product.name, flex: 4, alignRight: false),
                                    _dataCell(i.unit, flex: 1, alignRight: false),
                                    _dataCell(i.quantity.toStringAsFixed(0), flex: 1),
                                    _dataCell(i.unitPrice.toStringAsFixed(2), flex: 2),
                                    _dataCell(i.lineTotal.toStringAsFixed(2), flex: 2, bold: true),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 220,
                          child: Column(
                            children: [
                              _summaryLine('Sub Total', 'Rs. ${s.subTotal.toStringAsFixed(2)}'),
                              if (s.discountAmount > 0)
                                _summaryLine('Discount', '- Rs. ${s.discountAmount.toStringAsFixed(2)}'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 3),
                                child: Divider(height: 1),
                              ),
                              _summaryLine('Grand Total', 'Rs. ${s.grandTotal.toStringAsFixed(2)}', bold: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          side: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        child: const Text('Close', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          InvoicePdfGenerator.printInvoice(context, s, _appData.settings);
                        },
                        icon: const Icon(Icons.print, size: 14),
                        label: const Text('Print', style: TextStyle(fontSize: 12)),
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
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex, bool alignRight = true}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, bool bold = false, bool alignRight = true}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          )),
          Text(value, style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          )),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isOverdue) {
    final displayStatus = isOverdue ? 'Overdue' : status;
    final bgColor = isOverdue
        ? AppColors.error.withValues(alpha: 0.12)
        : status == 'Paid'
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.warning.withValues(alpha: 0.12);
    final fgColor = isOverdue
        ? AppColors.error
        : status == 'Paid'
            ? AppColors.success
            : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(3)),
      child: Text(displayStatus, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fgColor)),
    );
  }

  static const _borderSide = BorderSide(color: Color(0xFFD0D0D0), width: 0.5);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final displayed = _filteredSales;
        final totalSalesAmount = _appData.sales.fold(0.0, (sum, s) => sum + s.grandTotal);
        final paidAmount = _appData.sales.where((s) => s.status == 'Paid').fold(0.0, (sum, s) => sum + s.grandTotal);
        final unpaidAmount = _appData.sales.where((s) => s.status != 'Paid').fold(0.0, (sum, s) => sum + s.grandTotal);
        final overdueCount = _appData.sales.where((s) => s.isOverdue).length;

        return Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Header & KPI Summary Band ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        const Text('Sales & Tax Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _createNewInvoice,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Create New Tax Invoice', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
                        _buildKpiCard('TOTAL REVENUE', 'Rs. ${totalSalesAmount.toStringAsFixed(0)}', '${_appData.sales.length} Invoices', Icons.monetization_on, const Color(0xFF1B5E20), const Color(0xFFE8F5E9)),
                        const SizedBox(width: 10),
                        _buildKpiCard('PAID INVOICES', 'Rs. ${paidAmount.toStringAsFixed(0)}', '${_appData.sales.where((s) => s.status == "Paid").length} Settled', Icons.check_circle, AppColors.success, const Color(0xFFE8F5E9)),
                        const SizedBox(width: 10),
                        _buildKpiCard('UNPAID BALANCE', 'Rs. ${unpaidAmount.toStringAsFixed(0)}', '${_appData.sales.where((s) => s.status != "Paid").length} Pending', Icons.pending_actions, AppColors.warning, const Color(0xFFFFF8E1)),
                        const SizedBox(width: 10),
                        _buildKpiCard('OVERDUE ALERTS', '$overdueCount Invoices', overdueCount > 0 ? 'Requires Collection' : 'None Overdue', Icons.error_outline, AppColors.error, const Color(0xFFFFEBEE)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Search + Filter Toolbar ──
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: Color(0xFFB0B0B0))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 320,
                      height: 34,
                      child: TextField(
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search invoice #, customer...',
                          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                          prefixIconConstraints: const BoxConstraints(minWidth: 30),
                          filled: true,
                          fillColor: AppColors.searchBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _borderSide),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _borderSide),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Filter Chips
                    _buildFilterChip('All', _statusFilter == 'All', () => setState(() => _statusFilter = 'All')),
                    const SizedBox(width: 6),
                    _buildFilterChip('Paid', _statusFilter == 'Paid', () => setState(() => _statusFilter = 'Paid')),
                    const SizedBox(width: 6),
                    _buildFilterChip('Unpaid', _statusFilter == 'Unpaid', () => setState(() => _statusFilter = 'Unpaid')),
                    const SizedBox(width: 6),
                    _buildFilterChip('Overdue', _statusFilter == 'Overdue', () => setState(() => _statusFilter = 'Overdue')),
                    const Spacer(),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: _borderSide.color),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dateFilter,
                          isDense: true,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          items: const [
                            DropdownMenuItem(value: 'All Time', child: Text('All Time', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'This Month', child: Text('This Month', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Last Month', child: Text('Last Month', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'This Year', child: Text('This Year', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (v) => setState(() => _dateFilter = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Excel Data Grid Header ──
              Container(
                height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFE8E8E0), Color(0xFFD8D8D0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Row(
                  children: [
                    _sortableHeader('S.No', 45, null),
                    _sortableHeader('Invoice #', 115, InvoiceSortColumn.invoiceNumber),
                    _sortableHeader('Date', 95, InvoiceSortColumn.date),
                    _sortableHeader('Customer Name', 150, InvoiceSortColumn.customer),
                    _sortableHeader('Items (Name, Qty, Unit, Rate, Amount)', 280, null),
                    _sortableHeader('Grand Total (Rs)', 115, InvoiceSortColumn.amount, isNum: true),
                    _sortableHeader('Payment Mode', 120, null),
                    _sortableHeader('Status', 80, InvoiceSortColumn.status),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Excel Rows List ──
              Expanded(
                child: displayed.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: displayed.length,
                        itemBuilder: (ctx, i) {
                          final s = displayed[i];

                          final String itemsSummary = s.items.isEmpty
                              ? '-'
                              : s.items.map((item) {
                                  final qtyStr = item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toStringAsFixed(1);
                                  final rateStr = item.unitPrice % 1 == 0 ? item.unitPrice.toInt().toString() : item.unitPrice.toStringAsFixed(2);
                                  final totalStr = item.lineTotal % 1 == 0 ? item.lineTotal.toInt().toString() : item.lineTotal.toStringAsFixed(2);
                                  return '${item.product.name} ($qtyStr ${item.unit} × Rs.$rateStr = Rs.$totalStr)';
                                }).join(', ');

                          // Lookup customer for fallback bank details
                          final customer = _appData.customers.firstWhere(
                            (c) => (c.id != null && c.id == s.customerId) || c.name.toLowerCase() == s.customerName.toLowerCase(),
                            orElse: () => CustomerModel(name: s.customerName),
                          );

                          final String bName = s.safeBankName.isNotEmpty ? s.safeBankName : customer.safeBankName;
                          final String bHolder = s.safeAccountHolder.isNotEmpty ? s.safeAccountHolder : (customer.safeAccountHolder.isNotEmpty ? customer.safeAccountHolder : s.customerName);
                          final String bNumber = s.safeAccountNumber.isNotEmpty ? s.safeAccountNumber : (customer.safeAccountNumber.isNotEmpty ? customer.safeAccountNumber : 'N/A');
                          final bool isBank = s.paymentMethod.contains('Bank') || s.paymentMethod.contains('Online') || bName.isNotEmpty;
                          final String bankName = bName.isNotEmpty ? bName : 'Bank Account';
                          final String accountHolder = bHolder.isNotEmpty ? bHolder : s.customerName;
                          final String accountNumber = bNumber.isNotEmpty ? bNumber : 'N/A';

                          return InkWell(
                            onTap: () => _viewInvoice(s),
                            child: Container(
                              height: 32,
                              color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
                              child: Row(
                                children: [
                                  _excelCell('${i + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                  _excelCell(s.invoiceNumber, 115, isBold: true, textColor: AppColors.primary),
                                  _excelCell(DateFormat('yyyy-MM-dd').format(s.date), 95),
                                  _excelCell(s.customerName, 150, isBold: true),

                                  // Products (Name, Qty, Unit, Rate, Amount) Cell
                                  Container(
                                    width: 280,
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: const BoxDecoration(border: Border(right: _borderSide)),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      itemsSummary,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  _excelCell('Rs. ${s.grandTotal.toStringAsFixed(2)}', 115, isNum: true, isBold: true, textColor: AppColors.primary),

                                  // Payment Mode Cell with Bank Hover Tooltip
                                  SizedBox(
                                    width: 130,
                                    child: isBank
                                        ? Tooltip(
                                            richMessage: TextSpan(
                                              children: [
                                                TextSpan(text: '🏛️ Bank: $bankName\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                                TextSpan(text: '👤 Account Holder: $accountHolder\n', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                                TextSpan(text: '💳 Account Number: $accountNumber', style: const TextStyle(fontSize: 11, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E293B),
                                              borderRadius: BorderRadius.circular(4),
                                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              height: 32,
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              decoration: const BoxDecoration(border: Border(right: _borderSide)),
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.account_balance, size: 13, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${s.paymentMethod}${bankName.isNotEmpty && bankName != "Bank Account" ? " ($bankName)" : ""}',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 32,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            decoration: const BoxDecoration(border: Border(right: _borderSide)),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  s.paymentMethod == 'Cheque' ? Icons.note : Icons.payments,
                                                  size: 13,
                                                  color: AppColors.secondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    s.paymentMethod,
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),

                                  SizedBox(
                                    width: 85,
                                    child: Center(child: _buildStatusBadge(s.status, s.isOverdue)),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 15, color: AppColors.primary),
                                            tooltip: 'View Invoice Details',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                            onPressed: () => _viewInvoice(s),
                                          ),
                                          const SizedBox(width: 2),
                                          IconButton(
                                            icon: const Icon(Icons.print, size: 15, color: AppColors.secondary),
                                            tooltip: 'Print PDF Invoice',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                            onPressed: () => InvoicePdfGenerator.printInvoice(context, s, _appData.settings),
                                          ),
                                          const SizedBox(width: 2),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 15, color: AppColors.error),
                                            tooltip: 'Delete Invoice',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                            onPressed: () => _deleteInvoice(s),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ── Real-Time Status Bar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Text(
                  'Total Invoices: ${_appData.sales.length}  |  Filtered: ${displayed.length}  |  Total Sales Value: Rs. ${totalSalesAmount.toStringAsFixed(2)}  |  Unpaid Pending: Rs. ${unpaidAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String mainValue, String subValue, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(mainValue, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subValue, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _sortableHeader(String text, double width, InvoiceSortColumn? col, {bool isNum = false}) {
    final bool isCurrent = col != null && _sortColumn == col;
    return InkWell(
      onTap: col != null ? () => _onSort(col) : null,
      child: Container(
        width: width,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(border: Border(right: _borderSide, bottom: _borderSide)),
        child: Row(
          mainAxisAlignment: isNum ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? AppColors.primary : const Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (col != null) ...[
              const SizedBox(width: 4),
              Icon(
                isCurrent
                    ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 12,
                color: isCurrent ? AppColors.primary : Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _excelCell(String text, double width, {bool isNum = false, bool isBold = false, Color? textColor}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _borderSide)),
      child: Align(
        alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: textColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 54, color: AppColors.textHint.withAlpha(80)),
          const SizedBox(height: 10),
          const Text('No tax invoices found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('Click "Create New Tax Invoice" to generate an invoice.', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _createNewInvoice,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create First Invoice', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
