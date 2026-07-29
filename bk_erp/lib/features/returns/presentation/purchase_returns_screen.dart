import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/purchase_return_model.dart';
import 'create_purchase_return_dialog.dart';

class PurchaseReturnsScreen extends StatefulWidget {
  const PurchaseReturnsScreen({super.key});

  @override
  State<PurchaseReturnsScreen> createState() => _PurchaseReturnsScreenState();
}

class _PurchaseReturnsScreenState extends State<PurchaseReturnsScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<PurchaseReturnModel> get _filtered {
    if (_searchQuery.isEmpty) return _appData.purchaseReturns;
    final q = _searchQuery.toLowerCase();
    return _appData.purchaseReturns.where((r) =>
      r.returnNumber.toLowerCase().contains(q) ||
      r.supplierName.toLowerCase().contains(q) ||
      r.originalInvoiceNumber.toLowerCase().contains(q)
    ).toList();
  }

  void _createNewReturn() async {
    if (_appData.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add suppliers first')));
      return;
    }
    final result = await showDialog<PurchaseReturnModel>(
      context: context,
      builder: (_) => const CreatePurchaseReturnDialog(),
    );
    if (result != null) {
      if (!mounted) return;
      setState(() => _appData.addPurchaseReturn(result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Return recorded (Debit Note Generated)')));
    }
  }

  void _viewReturn(PurchaseReturnModel r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Debit Note ${r.returnNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier: ${r.supplierName}', style: const TextStyle(fontSize: 12)),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(r.date)}', style: const TextStyle(fontSize: 12)),
            Text('Original Invoice: ${r.originalInvoiceNumber}', style: const TextStyle(fontSize: 12)),
            Text('Reason: ${r.reason}', style: const TextStyle(fontSize: 12)),
            const Divider(),
            ...r.items.map((i) => Text('${i.product.name} x${i.quantity} = Rs.${(i.quantity * i.unitCost).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12))),
            const Divider(),
            Text('Sub Total: Rs.${r.subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            Text('VAT (13%): Rs.${r.vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            Text('Grand Total: Rs.${r.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final displayed = _filtered.reversed.toList();
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
                    Icon(Icons.assignment_return, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Purchase Returns (Debit Notes)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(bottom: BorderSide(color: AppColors.surfaceBorder))),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search by number, supplier or invoice...',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF666600)),
                            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF666600)),
                            prefixIconConstraints: const BoxConstraints(minWidth: 36),
                            fillColor: AppColors.searchBg,
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.surfaceBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.surfaceBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _createNewReturn,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Return', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: AppColors.tableHeaderBg,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            _hdr('Return #', flex: 2),
                            _hdr('Date', flex: 2),
                            _hdr('Supplier', flex: 3),
                            _hdr('Original Inv #', flex: 2),
                            _hdr('Total (Rs)', flex: 2, numeric: true),
                            _hdr('Actions', flex: 1, numeric: true),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      Expanded(
                        child: displayed.isEmpty
                            ? const Center(child: Text('No purchase returns recorded yet.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                            : ListView.separated(
                                itemCount: displayed.length,
                                separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.surfaceBorder),
                                itemBuilder: (context, index) {
                                  final r = displayed[index];
                                  return InkWell(
                                    onDoubleTap: () => _viewReturn(r),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          _cell(r.returnNumber, flex: 2, bold: true),
                                          _cell(DateFormat('MMM dd, yyyy').format(r.date), flex: 2),
                                          _cell(r.supplierName, flex: 3),
                                          _cell(r.originalInvoiceNumber, flex: 2),
                                          _cell(r.grandTotal.toStringAsFixed(2), flex: 2, numeric: true, color: AppColors.error, bold: true),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () => _viewReturn(r),
                                                child: const Icon(Icons.visibility, size: 15, color: AppColors.primary),
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
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
                child: Text(
                  'Total Returns: ${_appData.purchaseReturns.length}  |  Filtered: ${displayed.length}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hdr(String t, {required int flex, bool numeric = false}) => Expanded(flex: flex, child: Text(t, textAlign: numeric ? TextAlign.right : TextAlign.left, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText, fontSize: 12)));
  Widget _cell(String t, {required int flex, bool numeric = false, bool bold = false, Color? color}) => Expanded(flex: flex, child: Text(t, textAlign: numeric ? TextAlign.right : TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: color ?? AppColors.textPrimary)));
}
