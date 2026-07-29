import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../../billing/models/sale_model.dart';
import '../models/return_model.dart';

class CreateReturnDialog extends StatefulWidget {
  const CreateReturnDialog({super.key});

  @override
  State<CreateReturnDialog> createState() => _CreateReturnDialogState();
}

class _CreateReturnDialogState extends State<CreateReturnDialog> {
  final _appData = AppData();
  String? _selectedCustomerName;
  int? _selectedCustomerId;
  final List<_ReturnItem> _items = [];
  final TextEditingController _originalInvController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  double get _subTotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get _vatAmount => _subTotal > 0 ? _subTotal * (_appData.settings.defaultVatRate / 100) : 0.0;
  double get _grandTotal => _subTotal + _vatAmount;

  @override
  void dispose() {
    _originalInvController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No products in inventory!')));
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        ProductModel? selectedProduct;
        final qtyController = TextEditingController(text: '1');
        final priceController = TextEditingController();

        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Return Item', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<ProductModel>(
                isDense: true,
                decoration: const InputDecoration(labelText: 'Select Product', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                items: _appData.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.currentStock})', style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (p) {
                  setDialogState(() {
                    selectedProduct = p;
                    priceController.text = p?.sellingPrice.toString() ?? '';
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Return Quantity', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Unit Price (Rs)', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              ),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (selectedProduct == null) return;
                  final qty = double.tryParse(qtyController.text) ?? 0;
                  final price = double.tryParse(priceController.text) ?? 0;
                  if (qty <= 0 || price <= 0) return;
                  Navigator.pop(context, _ReturnItem(product: selectedProduct!, quantity: qty, unitPrice: price));
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    ).then((result) {
      if (result != null && result is _ReturnItem) {
        setState(() => _items.add(result));
      }
    });
  }

  void _submit() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one return item.')));
      return;
    }
    if (_selectedCustomerName == null || _selectedCustomerName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer.')));
      return;
    }

    final returnModel = ReturnModel(
      returnNumber: _appData.nextReturnNumber,
      date: DateTime.now(),
      customerId: _selectedCustomerId,
      customerName: _selectedCustomerName ?? 'Unknown',
      originalInvoiceNumber: _originalInvController.text.trim(),
      items: _items.map((i) => SaleItemModel(product: i.product, quantity: i.quantity, unitPrice: i.unitPrice)).toList(),
      subTotal: _subTotal,
      vatAmount: _vatAmount,
      grandTotal: _grandTotal,
      reason: _reasonController.text.trim(),
    );

    Navigator.of(context).pop(returnModel);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.tableHeaderBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
              ),
              child: Row(children: [
                const Icon(Icons.assignment_return, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Create Sales Return / Credit Note', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white70, size: 18)),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Return Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warning)),
                              OutlinedButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Add Item', style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
                              child: _items.isEmpty
                                  ? const Center(child: Text('No items added yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)))
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(6),
                                      itemCount: _items.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final item = _items[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              Text('${item.quantity} x Rs.${item.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                              const SizedBox(width: 8),
                                              Text('Rs.${item.lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                              const SizedBox(width: 4),
                                              InkWell(onTap: () => setState(() => _items.removeAt(index)), child: const Icon(Icons.close, color: AppColors.error, size: 16)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Customer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.warning)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              isDense: true,
                              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              initialValue: _selectedCustomerName,
                              items: _appData.customers.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedCustomerName = v;
                                  try { _selectedCustomerId = _appData.customers.firstWhere((c) => c.name == v).id; } catch (_) { _selectedCustomerId = null; }
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text('Original Invoice #', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.warning)),
                            const SizedBox(height: 4),
                            TextField(controller: _originalInvController, decoration: const InputDecoration(hintText: 'INV-00001', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                            const SizedBox(height: 10),
                            const Text('Return Reason', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.warning)),
                            const SizedBox(height: 4),
                            TextField(controller: _reasonController, maxLines: 2, decoration: const InputDecoration(hintText: 'e.g. Damaged goods', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                            const SizedBox(height: 14),
                            const Text('Refund Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.warning)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.cardRed, borderRadius: BorderRadius.circular(2), border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
                              child: Column(
                                children: [
                                  _summaryRow('Sub Total', _subTotal),
                                  const SizedBox(height: 4),
                                  _summaryRow('VAT (${_appData.settings.defaultVatRate.toStringAsFixed(0)}%)', _vatAmount),
                                  const Divider(height: 12),
                                  _summaryRow('Total Refund', _grandTotal, bold: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: const Text('Cancel', style: TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    onPressed: _submit,
                    icon: const Icon(Icons.save, size: 16),
                    label: const Text('Process Return', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double val, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, fontSize: 12)),
        Text('Rs.${val.toStringAsFixed(2)}', style: TextStyle(color: bold ? AppColors.error : AppColors.textPrimary, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, fontSize: bold ? 13 : 12)),
      ],
    );
  }
}

class _ReturnItem {
  final ProductModel product;
  final double quantity;
  final double unitPrice;
  double get lineTotal => quantity * unitPrice;

  _ReturnItem({required this.product, required this.quantity, required this.unitPrice});
}
