import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/purchase_order_model.dart';
import 'create_purchase_order_dialog.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<PurchaseOrderModel> get _filteredOrders {
    var list = _appData.purchaseOrders;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((po) =>
        po.poNumber.toLowerCase().contains(q) ||
        po.supplierName.toLowerCase().contains(q)
      ).toList();
    }
    if (_statusFilter != 'All') {
      list = list.where((po) => po.status == _statusFilter).toList();
    }
    return list;
  }

  void _createNewPO() async {
    if (_appData.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add suppliers first')));
      return;
    }
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add products in Inventory first!')));
      return;
    }
    final result = await showDialog<PurchaseOrderModel>(
      context: context,
      builder: (_) => const CreatePurchaseOrderDialog(),
    );
    if (result != null) {
      if (!mounted) return;
      setState(() => _appData.addPurchaseOrder(result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Order saved successfully!')));
    }
  }

  void _viewPO(PurchaseOrderModel po) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: AppColors.tableHeaderBg,
          child: Text('PO ${po.poNumber}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Supplier', po.supplierName),
              _detailRow('Date', DateFormat('yyyy-MM-dd').format(po.date)),
              if (po.expectedDate != null)
                _detailRow('Expected', DateFormat('yyyy-MM-dd').format(po.expectedDate!)),
              if (po.notes.isNotEmpty) _detailRow('Notes', po.notes),
              const Divider(color: AppColors.surfaceBorder, height: 10),
              const SizedBox(height: 4),
              // Items mini-table
              Container(
                color: AppColors.tableHeaderBg,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 24,
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: Text('Item', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                    const Expanded(flex: 2, child: Text('Qty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center)),
                    const Expanded(flex: 2, child: Text('Rate', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.right)),
                    const Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              ...po.items.map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 22,
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(i.product.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1)),
                    Expanded(flex: 2, child: Text('${i.quantity}', style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text(i.unitCost.toStringAsFixed(2), style: const TextStyle(fontSize: 11), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text((i.quantity * i.unitCost).toStringAsFixed(2), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                  ],
                ),
              )),
              const Divider(color: AppColors.surfaceBorder, height: 10),
              _detailRow('Sub Total', 'Rs.${po.subTotal.toStringAsFixed(2)}'),
              _detailRow('VAT (13%)', 'Rs.${po.vatAmount.toStringAsFixed(2)}'),
              _detailRow('Grand Total', 'Rs.${po.grandTotal.toStringAsFixed(2)}', bold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontSize: 12)),
          ),
          if (po.status == 'Sent' || po.status == 'Draft')
            SizedBox(
              height: 26,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _appData.updatePurchaseOrder(po.copyWith(status: 'Received')));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PO marked as Received')),
                  );
                },
                child: const Text('Mark Received', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _fulfillPO(PurchaseOrderModel po) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        title: const Text('Fulfill PO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        content: Text('Mark ${po.poNumber} as fulfilled? This will convert it to a purchase.', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontSize: 12))),
          SizedBox(
            height: 26,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _appData.updatePurchaseOrder(po.copyWith(status: 'Received')));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PO fulfilled successfully')),
                );
              },
              child: const Text('Fulfill', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Toolbar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: AppColors.surface,
                child: Row(
                  children: [
                    const Text('Purchase Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 16),
                    VerticalDivider(width: 1, color: AppColors.surfaceBorder),
                    const SizedBox(width: 12),
                    _toolbarButton(Icons.add, 'New PO', _createNewPO),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.statusBarBg, border: Border.all(color: AppColors.surfaceBorder, width: 1)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _statusChip('Total: ${_appData.purchaseOrders.length}'),
                          Container(width: 1, height: 14, color: AppColors.surfaceBorder),
                          _statusChip('Draft: ${_appData.purchaseOrders.where((p) => p.status == 'Draft').length}'),
                          Container(width: 1, height: 14, color: AppColors.surfaceBorder),
                          _statusChip('Sent: ${_appData.purchaseOrders.where((p) => p.status == 'Sent').length}'),
                          Container(width: 1, height: 14, color: AppColors.surfaceBorder),
                          _statusChip('Received: ${_appData.purchaseOrders.where((p) => p.status == 'Received').length}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── Search + Filter bar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: AppColors.background,
                child: Row(
                  children: [
                    SizedBox(
                      width: 340,
                      height: 36,
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search POs...',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          prefixIconConstraints: const BoxConstraints(minWidth: 36),
                          fillColor: AppColors.searchBg,
                          filled: true,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.surfaceBorder)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.surfaceBorder)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status filter chips
                    _filterChip('All'),
                    const SizedBox(width: 4),
                    _filterChip('Draft'),
                    const SizedBox(width: 4),
                    _filterChip('Sent'),
                    const SizedBox(width: 4),
                    _filterChip('Received'),
                    const Spacer(),
                    Text('Showing ${_filteredOrders.length} of ${_appData.purchaseOrders.length}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // ── Data Grid ──
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  child: _filteredOrders.isEmpty
                      ? _buildEmpty()
                      : Column(
                          children: [
                            // Header
                            Container(
                              color: AppColors.tableHeaderBg,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              height: 30,
                              child: Row(
                                children: [
                                  _headerCell('PO #', flex: 2),
                                  _headerCell('Date', flex: 2),
                                  _headerCell('Supplier', flex: 3),
                                  _headerCell('Total', flex: 2, isNumeric: true),
                                  _headerCell('Status', flex: 1),
                                  _headerCell('Actions', flex: 2, isNumeric: true),
                                ],
                              ),
                            ),
                            // Rows
                            Expanded(
                              child: ListView.builder(
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final po = _filteredOrders[_filteredOrders.length - 1 - index];
                                  return Container(
                                    color: index.isEven ? AppColors.surface : const Color(0xFFF5F5F0),
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      children: [
                                        _dataCell(po.poNumber, flex: 2, isBold: true, textColor: AppColors.primary),
                                        _dataCell(DateFormat('yyyy-MM-dd').format(po.date), flex: 2),
                                        _dataCell(po.supplierName, flex: 3),
                                        _dataCell(po.grandTotal.toStringAsFixed(2), flex: 2, isNumeric: true, isBold: true),
                                        // Status
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: _statusColor(po.status).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: Text(
                                                po.status,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(po.status)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Actions
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _actionIcon(Icons.visibility, AppColors.info, () => _viewPO(po)),
                                                if (po.status != 'Received')
                                                  _actionIcon(Icons.check_circle, AppColors.success, () => _fulfillPO(po)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              // ── Status Bar ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Text(
                  'Total Orders: ${_appData.purchaseOrders.length}  |  Filtered: ${_filteredOrders.length}  |  Amount: Rs.${_filteredOrders.fold(0.0, (s, po) => s + po.grandTotal).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.request_quote_outlined, size: 48, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          const Text('No purchase orders', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _createNewPO,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create First PO'),
          ),
        ],
      ),
    );
  }

  Widget _toolbarButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceBorder),
            color: AppColors.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(tooltip, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _statusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _statusChip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Received': return AppColors.success;
      case 'Sent': return AppColors.secondary;
      case 'Draft': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  Widget _headerCell(String text, {required int flex, bool isNumeric = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, bool isNumeric = false, bool isBold = false, Color? textColor}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
