import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../../../core/theme/app_theme.dart';
import '../models/purchase_model.dart';
import '../models/supplier_model.dart';
import 'pay_credit_dialog.dart';

class SupplierPayablesScreen extends StatefulWidget {
  const SupplierPayablesScreen({super.key});

  @override
  State<SupplierPayablesScreen> createState() => _SupplierPayablesScreenState();
}

class _SupplierPayablesScreenState extends State<SupplierPayablesScreen> {
  final _appData = AppData();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedRowIndex;

  static const _gridBorder = BorderSide(color: Color(0xFFD5D8DF), width: 0.6);

  @override
  void initState() {
    super.initState();
    _appData.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appData.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  List<PurchaseModel> get _pendingPurchases {
    final list = _appData.purchases.where((p) => p.dueAmount > 0).toList();
    if (_searchQuery.trim().isEmpty) return list;

    final q = _searchQuery.toLowerCase();
    return list.where((p) {
      final suppMatch = p.supplierName.toLowerCase().contains(q);
      final invMatch = p.invoiceNumber.toLowerCase().contains(q);
      final itemMatch = p.items.any((i) => i.product.name.toLowerCase().contains(q));
      return suppMatch || invMatch || itemMatch;
    }).toList();
  }

  SupplierModel? _getSupplierFor(PurchaseModel p) {
    if (p.supplierId != null) {
      try {
        return _appData.suppliers.firstWhere((s) => s.id == p.supplierId);
      } catch (_) {}
    }
    try {
      return _appData.suppliers.firstWhere((s) => s.name == p.supplierName);
    } catch (_) {}
    return null;
  }

  Future<void> _openPayDialog(PurchaseModel purchase) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PayCreditDialog(purchase: purchase),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment recorded for Bill #${purchase.invoiceNumber} successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_US');
    final pendingList = _pendingPurchases;
    final totalBillSum = pendingList.fold<double>(0.0, (sum, p) => sum + p.grandTotal);
    final totalPaidSum = pendingList.fold<double>(0.0, (sum, p) => sum + p.paidAmount);
    final totalPayableCredit = pendingList.fold<double>(0.0, (sum, p) => sum + p.dueAmount);
    final activeSuppliersCount = pendingList.map((p) => p.supplierName).toSet().length;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBE4),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Credited to Pay Left (Supplier Payables)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Summary Cards Ribbon ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    'TOTAL CREDIT DUE TO PAY',
                    'Rs. ${currencyFmt.format(totalPayableCredit)}',
                    Icons.account_balance_wallet,
                    Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpiCard(
                    'PENDING CREDIT PURCHASES',
                    '${pendingList.length} Bills',
                    Icons.receipt_long,
                    Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpiCard(
                    'ACTIVE SUPPLIERS WITH DUE',
                    '$activeSuppliersCount Vendors',
                    Icons.business,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Search & Filter Control Ribbon ──
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
                      hintText: 'Search supplier, bill #, item...',
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD5D8DF)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'Showing ${pendingList.length} credit bills left to pay',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // ── Excel Data Grid Content ──
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const minWidth = 1270.0;
                final gridWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
                final extra = gridWidth - minWidth;
                final suppWidth = 160.0 + (extra * 0.20);
                final infoWidth = 160.0 + (extra * 0.20);
                final itemWidth = 240.0 + (extra * 0.60);

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
                            gradient: LinearGradient(
                              colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                          ),
                          child: Row(
                            children: [
                              _excelHeader('S.NO', 45),
                              _excelHeader('DATE', 90),
                              _excelHeader('BILL #', 110),
                              _excelHeader('SUPPLIER NAME', suppWidth),
                              _excelHeader('PHONE & ADDRESS', infoWidth),
                              _excelHeader('PURCHASED ITEMS (QTY @ RATE)', itemWidth),
                              _excelHeader('TOTAL BILL (RS)', 120, isNum: true),
                              _excelHeader('PAID (RS)', 100, isNum: true),
                              _excelHeader('DUE TO PAY (RS)', 125, isNum: true),
                              _excelHeader('ACTION', 120, isCenter: true),
                            ],
                          ),
                        ),

                        // Excel Grid Rows
                        Expanded(
                          child: pendingList.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: pendingList.length,
                                  itemBuilder: (context, index) {
                                    final purchase = pendingList[index];
                                    final supplier = _getSupplierFor(purchase);
                                    final address = supplier?.address.isNotEmpty == true ? supplier!.address : '-';
                                    final phone = supplier?.phone.isNotEmpty == true ? supplier!.phone : '-';
                                    final dateStr = DateFormat('yyyy-MM-dd').format(purchase.date);
                                    final itemsSummary = purchase.items.isEmpty
                                        ? '-'
                                        : purchase.items
                                            .map((i) => '${i.product.name} (${i.quantity.toStringAsFixed(0)} ${i.unit} @ Rs.${i.unitCost.toStringAsFixed(0)})')
                                            .join(', ');
                                    final isExpanded = _expandedRowIndex == index;

                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _expandedRowIndex = isExpanded ? null : index;
                                            });
                                          },
                                          hoverColor: const Color(0xFFEBF3FA),
                                          child: Container(
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: isExpanded
                                                  ? const Color(0xFFFFFBEB)
                                                  : (index.isEven ? Colors.white : const Color(0xFFF9FAFB)),
                                              border: const Border(bottom: _gridBorder),
                                            ),
                                            child: Row(
                                              children: [
                                                _excelCell('${index + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                                _excelCell(dateStr, 90),
                                                _excelCell('#${purchase.invoiceNumber}', 110, isBold: true, textColor: AppColors.primary),
                                                _excelCell(purchase.supplierName, suppWidth, isBold: true),
                                                _excelCell('Ph: $phone | $address', infoWidth, textColor: AppColors.textSecondary),
                                                _excelCell(itemsSummary, itemWidth),
                                                _excelCell(currencyFmt.format(purchase.grandTotal), 120, isNum: true, isBold: true),
                                                _excelCell(currencyFmt.format(purchase.paidAmount), 100, isNum: true, textColor: Colors.green.shade700),
                                                _excelCellBadge('Rs. ${currencyFmt.format(purchase.dueAmount)}', 125, Colors.red.shade700),
                                                Container(
                                                  width: 120,
                                                  height: 34,
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                  decoration: const BoxDecoration(border: Border(right: _gridBorder)),
                                                  alignment: Alignment.center,
                                                  child: SizedBox(
                                                    height: 24,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () => _openPayDialog(purchase),
                                                      icon: const Icon(Icons.payment, size: 12),
                                                      label: const Text('Pay Credit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red.shade700,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Expandable Item Detail Table
                                        if (isExpanded)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                            color: const Color(0xFFFFFDF5),
                                            decoration: const BoxDecoration(
                                              border: Border(bottom: _gridBorder),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.receipt_long, size: 14, color: AppColors.primary),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Bill Item Breakdown for #${purchase.invoiceNumber} (${purchase.supplierName}):',
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Table(
                                                  border: TableBorder.all(color: const Color(0xFFD5D8DF), width: 0.8),
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(3),
                                                    1: FlexColumnWidth(1.5),
                                                    2: FlexColumnWidth(1.5),
                                                    3: FlexColumnWidth(2),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      decoration: const BoxDecoration(color: Color(0xFFE4E6EA)),
                                                      children: const [
                                                        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Product Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                                        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Quantity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                                        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Unit Rate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                                        Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Line Total (Rs)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                                      ],
                                                    ),
                                                    ...purchase.items.map(
                                                      (item) => TableRow(
                                                        children: [
                                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text(item.product.name, style: const TextStyle(fontSize: 11))),
                                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 11))),
                                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Rs. ${currencyFmt.format(item.unitCost)}', style: const TextStyle(fontSize: 11))),
                                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Rs. ${currencyFmt.format(item.lineTotal)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                        ),

                        // Excel Summary Totals Footer Row
                        if (pendingList.isNotEmpty)
                          Container(
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2E8F0),
                              border: Border(
                                top: BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                bottom: BorderSide(color: Color(0xFF94A3B8), width: 1.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                _excelCell('TOTALS (${pendingList.length} Bills)', 45 + 90 + 110 + suppWidth + infoWidth + itemWidth, isBold: true, textColor: AppColors.textPrimary),
                                _excelCell(currencyFmt.format(totalBillSum), 120, isNum: true, isBold: true),
                                _excelCell(currencyFmt.format(totalPaidSum), 100, isNum: true, isBold: true, textColor: Colors.green.shade800),
                                _excelCellBadge('Rs. ${currencyFmt.format(totalPayableCredit)}', 125, Colors.red.shade800),
                                const SizedBox(width: 120),
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

          // ── Excel Sheet Status Bar ──
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFFD5D8DF),
            child: Row(
              children: [
                const Icon(Icons.table_chart, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Ready  |  Supplier Payables Sheet Mode  |  Bills: ${pendingList.length}  |  Total Credit Left to Pay: Rs. ${currencyFmt.format(totalPayableCredit)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const Spacer(),
                const Text('BK ERP Sheet Engine', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFD5D8DF)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
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
                Text(
                  label,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _excelHeader(String text, double width, {bool isNum = false, bool isCenter = false}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isCenter ? Alignment.center : (isNum ? Alignment.centerRight : Alignment.centerLeft),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF2D3748), letterSpacing: 0.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _excelCell(String text, double width, {bool isNum = false, bool isBold = false, Color? textColor}) {
    return Container(
      width: width,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _excelCellBadge(String text, double width, Color color) {
    return Container(
      width: width,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          border: Border.all(color: color.withAlpha(50)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade400),
          const SizedBox(height: 12),
          const Text('No Outstanding Supplier Credit!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            _searchQuery.isNotEmpty ? 'No credit bills matching "$_searchQuery".' : 'All supplier bills have been fully paid.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
