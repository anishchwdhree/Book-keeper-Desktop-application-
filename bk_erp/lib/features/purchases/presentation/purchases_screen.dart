import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/supplier_model.dart';
import '../models/purchase_model.dart';
import 'add_supplier_dialog.dart';
import 'add_purchase_dialog.dart';
import 'supplier_ledger_screen.dart';
import 'supplier_payables_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  final _appData = AppData();
  late TabController _tabController;
  String _purchasesSearchQuery = '';
  String _suppliersSearchQuery = '';
  final _purchasesSearchController = TextEditingController();
  final _suppliersSearchController = TextEditingController();

  List<PurchaseModel> get _filteredPurchases {
    if (_purchasesSearchQuery.isEmpty) return _appData.purchases;
    final q = _purchasesSearchQuery.toLowerCase();
    return _appData.purchases
        .where(
          (p) =>
              p.invoiceNumber.toLowerCase().contains(q) ||
              p.supplierName.toLowerCase().contains(q),
        )
        .toList();
  }

  List<SupplierModel> get _filteredSuppliers {
    if (_suppliersSearchQuery.isEmpty) return _appData.suppliers;
    final q = _suppliersSearchQuery.toLowerCase();
    return _appData.suppliers
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.phone.contains(q) ||
              s.suppliedItems.toLowerCase().contains(q) ||
              s.safeBankName.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _purchasesSearchController.dispose();
    _suppliersSearchController.dispose();
    super.dispose();
  }

  void _addSupplier([SupplierModel? supplier]) async {
    final result = await showDialog<SupplierModel>(
      context: context,
      builder: (_) => AddSupplierDialog(supplier: supplier),
    );
    if (result != null) {
      setState(() {
        if (supplier != null) {
          _appData.updateSupplier(result);
        } else {
          _appData.addSupplier(result);
        }
      });
    }
  }

  void _openLedger(SupplierModel s) {
    showDialog(
      context: context,
      builder: (_) => SupplierLedgerScreen(supplier: s),
    );
  }

  void _deleteSupplier(SupplierModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text(
              'Delete Supplier',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${s.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _appData.deleteSupplier(s.id!));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addPurchase() async {
    if (_appData.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a supplier first!')),
      );
      _tabController.animateTo(1);
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
    if (result != null) {
      setState(() => _appData.addPurchase(result));
    }
  }

  void _showDeletePurchase(PurchaseModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text(
              'Delete Purchase',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Delete purchase ${p.invoiceNumber}? Item stock will be reversed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _appData.deletePurchase(p));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${p.invoiceNumber} deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static const _gridBorder = BorderSide(color: Color(0xFFD5D8DF), width: 0.6);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final totalPurchasesAmt = _appData.purchases.fold(
          0.0,
          (s, p) => s + p.grandTotal,
        );
        final totalPayablesAmt = _appData.totalPayables;
        final totalBankSuppliers = _appData.suppliers
            .where(
              (s) =>
                  s.paymentMethod == 'Bank Account' ||
                  s.safeBankName.isNotEmpty,
            )
            .length;

        return Container(
          color: const Color(0xFFEBEBE4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Banner ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.surfaceBorder),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchases & Supplier Directory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Manage vendor bills, wholesale rates, bank accounts, and payables',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: () => _addSupplier(),
                        icon: const Icon(
                          Icons.person_add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Add Supplier',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupplierPayablesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'Credit Payables',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.error,
                            width: 1.2,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: _addPurchase,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text(
                          'New Purchase',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── KPI Summary Cards Band ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: const Color(0xFFF2F2EC),
                child: Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        'TOTAL PURCHASES',
                        'Rs. ${totalPurchasesAmt.toStringAsFixed(0)}',
                        Icons.receipt_long,
                        const Color(0xFF003399),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        'TOTAL PAYABLES',
                        'Rs. ${totalPayablesAmt.toStringAsFixed(0)}',
                        Icons.account_balance_wallet,
                        AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        'TOTAL SUPPLIERS',
                        '${_appData.suppliers.length}',
                        Icons.people,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        'BANK ACCOUNT VENDORS',
                        '$totalBankSuppliers',
                        Icons.account_balance,
                        const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Bar ──
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.tableHeaderBg,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF002266), width: 1.5),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: AppColors.secondary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 16),
                          const SizedBox(width: 6),
                          Text('Purchases Log (${_appData.purchases.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Suppliers & Bank Master (${_appData.suppliers.length})',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildPurchasesTab(), _buildSuppliersTab()],
                ),
              ),

              // ── Excel Footer Status Bar ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_chart,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ready  |  Purchases: ${_appData.purchases.length}  |  Suppliers: ${_appData.suppliers.length}  |  Payables: Rs. ${totalPayablesAmt.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'BK ERP Sheet Mode',
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(3),
            ),
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
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
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

  // ═══════════════════════════════════════════════════════════════════
  // PURCHASES TAB (Spreadsheet Grid)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPurchasesTab() {
    return Column(
      children: [
        // ── Search Ribbon ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFFF4F4EE),
          child: Row(
            children: [
              SizedBox(
                width: 320,
                height: 30,
                child: TextField(
                  controller: _purchasesSearchController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search invoice # or supplier name...',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 30),
                    filled: true,
                    fillColor: AppColors.searchBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: _gridBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: _gridBorder,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _purchasesSearchQuery = v),
                ),
              ),
              if (_purchasesSearchQuery.isNotEmpty) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _purchasesSearchController.clear();
                    setState(() => _purchasesSearchQuery = '');
                  },
                ),
              ],
              const SizedBox(width: 12),
              Text(
                'Showing ${_filteredPurchases.length} of ${_appData.purchases.length} invoices',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // ── Excel Header Row ──
        Container(
          height: 32,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1),
            ),
          ),
          child: Row(
            children: [
              _excelHeader('S.NO', 45),
              _excelHeader('INVOICE #', 120),
              _excelHeader('DATE', 100),
              _excelHeader('SUPPLIER NAME', 170),
              _excelHeader('PURCHASED PRODUCTS (NAME / QTY / RATE)', 240),
              _excelHeader('PAYMENT METHOD', 150),
              _excelHeader('TOTAL AMOUNT', 110, isNum: true),
              _excelHeader('PAID AMOUNT', 110, isNum: true),
              _excelHeader('DUE AMOUNT', 110, isNum: true),
              const SizedBox(width: 70),
            ],
          ),
        ),

        // ── Excel Rows ──
        Expanded(
          child: _filteredPurchases.isEmpty
              ? _buildEmpty(
                  'No purchases recorded yet',
                  Icons.receipt_long_outlined,
                  _addPurchase,
                  'Record First Purchase',
                )
              : ListView.builder(
                  itemCount: _filteredPurchases.length,
                  itemBuilder: (ctx, i) {
                    final p =
                        _filteredPurchases[_filteredPurchases.length - 1 - i];

                    // Lookup supplier for bank details
                    final supplier = _appData.suppliers.firstWhere(
                      (s) =>
                          (s.id != null && s.id == p.supplierId) ||
                          s.name.toLowerCase() == p.supplierName.toLowerCase(),
                      orElse: () => SupplierModel(name: p.supplierName),
                    );

                    final bool isBank =
                        p.paymentMethod.contains('Bank') ||
                        supplier.safeBankName.isNotEmpty;

                    final String itemsSummary = p.items.isEmpty
                        ? '-'
                        : p.items
                              .map(
                                (item) =>
                                    '${item.product.name} (${item.quantity.toStringAsFixed(0)} ${item.unit} @ Rs.${item.unitCost.toStringAsFixed(0)})',
                              )
                              .join(', ');
                    return InkWell(
                      hoverColor: const Color(0xFFEBF3FA),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: i.isEven
                              ? Colors.white
                              : const Color(0xFFF9FAFB),
                          border: const Border(bottom: _gridBorder),
                        ),
                        child: Row(
                          children: [
                            _excelCell(
                              '${i + 1}',
                              45,
                              isNum: true,
                              textColor: AppColors.textHint,
                            ),
                            _excelCell(
                              p.invoiceNumber,
                              120,
                              isBold: true,
                              textColor: AppColors.primary,
                            ),
                            _excelCell(
                              DateFormat('yyyy-MM-dd').format(p.date),
                              100,
                            ),
                            _excelCell(p.supplierName, 170, isBold: true),

                            // Product Name, Unit, Quantity, Rate Cell
                            Container(
                              width: 240,
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(right: _gridBorder),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                itemsSummary,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Payment Method Cell with Hover Tooltip displaying Bank Name, Holder Name, Account Number
                            SizedBox(
                              width: 150,
                              child: isBank
                                  ? Tooltip(
                                      richMessage: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '🏛️ Bank: ${supplier.safeBankName.isNotEmpty ? supplier.safeBankName : "Bank Account"}\n',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '👤 Account Holder: ${supplier.safeAccountHolder.isNotEmpty ? supplier.safeAccountHolder : supplier.name}\n',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '💳 Account Number: ${supplier.safeAccountNumber.isNotEmpty ? supplier.safeAccountNumber : "N/A"}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.amberAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        height: 32,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: const BoxDecoration(
                                          border: Border(right: _gridBorder),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.account_balance,
                                              size: 13,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${p.paymentMethod}${supplier.safeBankName.isNotEmpty ? " (${supplier.safeBankName})" : ""}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(right: _gridBorder),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Icon(
                                            p.paymentMethod == 'Cheque'
                                                ? Icons.note
                                                : Icons.payments,
                                            size: 13,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              p.paymentMethod,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),

                            _excelCell(
                              'Rs. ${p.grandTotal.toStringAsFixed(0)}',
                              110,
                              isNum: true,
                              isBold: true,
                            ),
                            _excelCell(
                              'Rs. ${p.paidAmount.toStringAsFixed(0)}',
                              110,
                              isNum: true,
                            ),
                            Expanded(
                              flex: 110,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(right: _gridBorder),
                                ),
                                alignment: Alignment.centerRight,
                                child: p.dueAmount > 0
                                    ? _excelStatusBadge(
                                        'Rs. ${p.dueAmount.toStringAsFixed(0)}',
                                        AppColors.error,
                                      )
                                    : _excelStatusBadge(
                                        'PAID',
                                        AppColors.success,
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    message: 'Delete Purchase',
                                    child: InkWell(
                                      onTap: () => _showDeletePurchase(p),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withAlpha(20),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 14,
                                          color: AppColors.error,
                                        ),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUPPLIERS TAB (Spreadsheet Grid with Bank Account details)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSuppliersTab() {
    return Column(
      children: [
        // ── Search Ribbon ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: const Color(0xFFF4F4EE),
          child: Row(
            children: [
              SizedBox(
                width: 340,
                height: 30,
                child: TextField(
                  controller: _suppliersSearchController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search supplier name, phone, item or bank...',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 30),
                    filled: true,
                    fillColor: AppColors.searchBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: _gridBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: _gridBorder,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _suppliersSearchQuery = v),
                ),
              ),
              if (_suppliersSearchQuery.isNotEmpty) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _suppliersSearchController.clear();
                    setState(() => _suppliersSearchQuery = '');
                  },
                ),
              ],
              const SizedBox(width: 12),
              Text(
                'Showing ${_filteredSuppliers.length} of ${_appData.suppliers.length} suppliers',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // ── Excel Header Row ──
        Container(
          height: 32,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1),
            ),
          ),
          child: Row(
            children: [
              _excelHeader('S.NO', 45),
              _excelHeader('SUPPLIER NAME', 170),
              _excelHeader('PHONE', 100),
              _excelHeader('RATE TYPE', 90),
              _excelHeader('ITEMS SUPPLIED', 120),
              _excelHeader('TYPICAL QTY', 90),
              _excelHeader('RATE / UNIT', 95, isNum: true),
              _excelHeader('PAYMENT MODE / BANK', 160),
              _excelHeader('PAID (RS)', 90, isNum: true),
              _excelHeader('OUTSTANDING', 105, isNum: true),
              const SizedBox(width: 95),
            ],
          ),
        ),

        // ── Excel Rows ──
        Expanded(
          child: _filteredSuppliers.isEmpty
              ? _buildEmpty(
                  'No suppliers registered yet',
                  Icons.people_outline,
                  () => _addSupplier(),
                  'Add First Supplier',
                )
              : ListView.builder(
                  itemCount: _filteredSuppliers.length,
                  itemBuilder: (ctx, i) {
                    final s = _filteredSuppliers[i];

                    final bool isBank =
                        s.paymentMethod == 'Bank Account' ||
                        s.safeBankName.isNotEmpty;
                    final String paymentDisplay = isBank
                        ? (s.safeBankName.isNotEmpty
                              ? s.safeBankName
                              : 'Bank Account')
                        : s.paymentMethod;

                    final String qtyDisplay = s.defaultQty > 0
                        ? '${s.defaultQty.toStringAsFixed(0)} ${s.defaultUnit}'
                        : s.defaultUnit;

                    return InkWell(
                      hoverColor: const Color(0xFFEBF3FA),
                      onTap: () => _openLedger(s),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: i.isEven
                              ? Colors.white
                              : const Color(0xFFF9FAFB),
                          border: const Border(bottom: _gridBorder),
                        ),
                        child: Row(
                          children: [
                            _excelCell(
                              '${i + 1}',
                              45,
                              isNum: true,
                              textColor: AppColors.textHint,
                            ),
                            _excelCell(s.name, 170, isBold: true),
                            _excelCell(s.phone.isNotEmpty ? s.phone : '-', 100),
                            _excelCellBadge(
                              s.rateType.isNotEmpty ? s.rateType : 'Wholesale',
                              90,
                              const Color(0xFF003399),
                            ),
                            _excelCell(
                              s.suppliedItems.isNotEmpty
                                  ? s.suppliedItems
                                  : '-',
                              120,
                            ),
                            _excelCell(qtyDisplay, 90),
                            _excelCell(
                              'Rs. ${s.defaultRate.toStringAsFixed(0)}',
                              95,
                              isNum: true,
                            ),
                            Tooltip(
                              richMessage: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '🏛️ Bank: ${s.safeBankName.isNotEmpty ? s.safeBankName : "Bank Account"}\n',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '👤 Account Holder: ${s.safeAccountHolder.isNotEmpty ? s.safeAccountHolder : s.name}\n',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '💳 Account Number: ${s.safeAccountNumber.isNotEmpty ? s.safeAccountNumber : "N/A"}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: 160,
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(right: _gridBorder),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      isBank
                                          ? Icons.account_balance
                                          : Icons.payments,
                                      size: 14,
                                      color: isBank
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        paymentDisplay,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isBank
                                              ? FontWeight.bold
                                              : FontWeight.w400,
                                          color: isBank
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _excelCell(
                              'Rs. ${s.paidAmount.toStringAsFixed(0)}',
                              90,
                              isNum: true,
                            ),
                            Expanded(
                              flex: 105,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(right: _gridBorder),
                                ),
                                alignment: Alignment.centerRight,
                                child: s.outstandingBalance > 0
                                    ? _excelStatusBadge(
                                        'Rs. ${s.outstandingBalance.toStringAsFixed(0)}',
                                        AppColors.error,
                                      )
                                    : _excelStatusBadge(
                                        'CLEARED',
                                        AppColors.success,
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: 95,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    message: 'View Ledger',
                                    child: InkWell(
                                      onTap: () => _openLedger(s),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withAlpha(20),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.menu_book,
                                          size: 14,
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Tooltip(
                                    message: 'Edit Supplier',
                                    child: InkWell(
                                      onTap: () => _addSupplier(s),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(
                                            20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit_outlined,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Tooltip(
                                    message: 'Delete Supplier',
                                    child: InkWell(
                                      onTap: () => _deleteSupplier(s),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withAlpha(20),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 14,
                                          color: AppColors.error,
                                        ),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EXCEL SPREADSHEET WIDGET HELPERS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildEmpty(
    String message,
    IconData icon,
    VoidCallback onPressed,
    String btnLabel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint.withAlpha(80)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add, size: 16),
              label: Text(btnLabel, style: const TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
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
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2D3748),
          letterSpacing: 0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _excelCell(
    String text,
    double width, {
    bool isNum = false,
    bool isBold = false,
    Color? textColor,
  }) {
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _excelCellBadge(String text, double width, Color badgeColor) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: badgeColor.withAlpha(15),
          border: Border.all(color: badgeColor.withAlpha(50)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: badgeColor,
          ),
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
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
