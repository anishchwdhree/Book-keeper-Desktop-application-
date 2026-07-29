import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../models/purchase_return_model.dart';
import '../../purchases/models/purchase_model.dart';

class _ReturnItem {
  final ProductModel product;
  final double quantity;
  final double unitCost;
  double get lineTotal => quantity * unitCost;

  _ReturnItem({required this.product, required this.quantity, required this.unitCost});
}

class CreatePurchaseReturnDialog extends StatefulWidget {
  const CreatePurchaseReturnDialog({super.key});

  @override
  State<CreatePurchaseReturnDialog> createState() => _CreatePurchaseReturnDialogState();
}

class _CreatePurchaseReturnDialogState extends State<CreatePurchaseReturnDialog> {
  final _appData = AppData();
  String? _selectedSupplier;
  final List<_ReturnItem> _returnItems = [];
  final _vatRate = 13.0;

  final _invoiceNumController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _invoiceNumController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double get _subTotal => _returnItems.fold(0.0, (s, i) => s + i.lineTotal);
  double get _vatAmount => _subTotal * _vatRate / 100;
  double get _grandTotal => _subTotal + _vatAmount;

  void _addItemToReturn() {
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add products in Inventory first!')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        ProductModel? selectedProduct;
        final qtyController = TextEditingController(text: '1');
        final costController = TextEditingController();
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Item to Return', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<ProductModel>(
                isDense: true,
                decoration: const InputDecoration(labelText: 'Select Product', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                items: _appData.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.currentStock})', style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (p) {
                  setDialogState(() {
                    selectedProduct = p;
                    costController.text = p?.purchasePrice.toString() ?? '';
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: 'Return Quantity', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]),
              const SizedBox(height: 10),
              TextFormField(controller: costController, decoration: const InputDecoration(labelText: 'Unit Cost (Rs)', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (selectedProduct == null) return;
                  final qty = double.tryParse(qtyController.text) ?? 0;
                  final cost = double.tryParse(costController.text) ?? 0;
                  if (qty <= 0 || cost <= 0) return;
                  Navigator.pop(context, _ReturnItem(product: selectedProduct!, quantity: qty, unitCost: cost));
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    ).then((result) {
      if (result != null && result is _ReturnItem) {
        setState(() => _returnItems.add(result));
      }
    });
  }

  void _submit() {
    if (_selectedSupplier == null || _returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a supplier and add items to return')));
      return;
    }

    final supplierId = int.tryParse(_selectedSupplier!);
    final spr = _appData.suppliers.firstWhere((s) => s.id == supplierId, orElse: () => _appData.suppliers.first);

    final returnModel = PurchaseReturnModel(
      returnNumber: _appData.nextPurchaseReturnNumber,
      date: DateTime.now(),
      supplierId: spr.id,
      supplierName: spr.name,
      originalInvoiceNumber: _invoiceNumController.text.trim(),
      reason: _reasonController.text.trim(),
      items: _returnItems.map((c) => PurchaseItemModel(product: c.product, quantity: c.quantity, unitCost: c.unitCost)).toList(),
      subTotal: _subTotal,
      vatAmount: _vatAmount,
      grandTotal: _grandTotal,
    );
    Navigator.of(context).pop(returnModel);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: AppColors.tableHeaderBg, borderRadius: BorderRadius.vertical(top: Radius.circular(3))),
            child: Row(children: [
              const Icon(Icons.assignment_return_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('New Purchase Return (Debit Note)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white70, size: 18)),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Supplier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  isDense: true,
                  decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  initialValue: _selectedSupplier,
                  items: _appData.suppliers.map((s) => DropdownMenuItem(value: s.id.toString(), child: Text(s.name, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setState(() => _selectedSupplier = v),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Original Invoice #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    TextField(controller: _invoiceNumController, decoration: const InputDecoration(hintText: 'INV-1002', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Reason for Return', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    TextField(controller: _reasonController, decoration: const InputDecoration(hintText: 'e.g. Damaged goods', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                  ])),
                ]),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Items to Return', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  OutlinedButton.icon(onPressed: _addItemToReturn, icon: const Icon(Icons.add, size: 14), label: const Text('Add Item', style: TextStyle(fontSize: 11)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6))),
                ]),
                const SizedBox(height: 8),
                if (_returnItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(2)),
                    child: const Center(child: Text('No items added yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                  )
                else
                  ..._returnItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
                      child: Row(children: [
                        Expanded(flex: 3, child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Expanded(child: Text('x${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                        Expanded(child: Text('Rs.${item.unitCost.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                        Expanded(child: Text('Rs.${item.lineTotal.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                        const SizedBox(width: 4),
                        InkWell(
                          child: const Icon(Icons.close, size: 16, color: AppColors.error),
                          onTap: () => setState(() => _returnItems.removeAt(i)),
                        ),
                      ]),
                    );
                  }),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _totalRow('Sub Total', _subTotal),
                _totalRow('VAT (13%)', _vatAmount),
                const Divider(height: 12),
                _totalRow('Grand Total (Debit)', _grandTotal, bold: true),
              ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(onPressed: () => Navigator.of(context).pop(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: const Text('Cancel', style: TextStyle(fontSize: 12))),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Record Return', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: bold ? 14 : 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text('Rs.${value.toStringAsFixed(2)}', style: TextStyle(fontSize: bold ? 14 : 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ]),
    );
  }
}
