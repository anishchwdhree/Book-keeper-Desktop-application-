import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../models/estimate_model.dart';
import '../../billing/models/sale_model.dart';

class _EstimateItem {
  final ProductModel product;
  final double quantity;
  final double unitPrice;
  double get lineTotal => quantity * unitPrice;

  _EstimateItem({required this.product, required this.quantity, required this.unitPrice});
}

class CreateEstimateDialog extends StatefulWidget {
  const CreateEstimateDialog({super.key});

  @override
  State<CreateEstimateDialog> createState() => _CreateEstimateDialogState();
}

class _CreateEstimateDialogState extends State<CreateEstimateDialog> {
  final _appData = AppData();
  String? _selectedCustomer;
  final List<_EstimateItem> _items = [];
  final _notesController = TextEditingController();
  DateTime? _validUntil;
  double _discount = 0.0;

  @override
  void initState() {
    super.initState();
    _validUntil = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _subTotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get _taxableAmount => _subTotal - _discount;
  double get _vatAmount => _taxableAmount > 0 ? _taxableAmount * (_appData.settings.defaultVatRate / 100) : 0.0;
  double get _grandTotal => _taxableAmount + _vatAmount;

  void _addItem() {
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add products to Inventory first!')));
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
            title: const Text('Add Product to Estimate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
              TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantity', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]),
              const SizedBox(height: 10),
              TextFormField(controller: priceController, decoration: const InputDecoration(labelText: 'Selling Price (Rs)', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (selectedProduct == null) return;
                  final qty = double.tryParse(qtyController.text) ?? 0;
                  final price = double.tryParse(priceController.text) ?? 0;
                  if (qty <= 0 || price <= 0) return;
                  setState(() {
                    final existingIndex = _items.indexWhere((i) => i.product.id == selectedProduct!.id);
                    if (existingIndex >= 0) {
                      _items[existingIndex] = _EstimateItem(product: selectedProduct!, quantity: _items[existingIndex].quantity + qty, unitPrice: price);
                    } else {
                      _items.add(_EstimateItem(product: selectedProduct!, quantity: qty, unitPrice: price));
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add Item'),
              ),
            ],
          );
        });
      },
    );
  }

  void _submit() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot save empty estimate.')));
      return;
    }

    final custId = int.tryParse(_selectedCustomer ?? '');
    final customer = _appData.customers.firstWhere((c) => c.id == custId, orElse: () => _appData.customers.first);

    final estimate = EstimateModel(
      estimateNumber: _appData.nextEstimateNumber,
      date: DateTime.now(),
      validUntil: _validUntil,
      customerId: custId,
      customerName: custId == null ? 'Walk-in Customer' : customer.name,
      items: _items.map((i) => SaleItemModel(product: i.product, quantity: i.quantity, unitPrice: i.unitPrice)).toList(),
      subTotal: _subTotal,
      discountAmount: _discount,
      taxableAmount: _taxableAmount,
      vatAmount: _vatAmount,
      grandTotal: _grandTotal,
      status: 'Sent',
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(estimate);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: SizedBox(
        width: 700,
        height: 650,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(color: AppColors.tableHeaderBg, borderRadius: BorderRadius.vertical(top: Radius.circular(3))),
              child: Row(children: [
                const Icon(Icons.receipt, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Create New Estimate', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white70, size: 18)),
              ]),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBlue, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 8)),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _items.isEmpty
                                ? const Center(child: Text('No items added yet.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                                : ListView.separated(
                                    itemCount: _items.length,
                                    separatorBuilder: (context, _) => const Divider(height: 1, color: AppColors.surfaceBorder),
                                    itemBuilder: (context, index) {
                                      final item = _items[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              Text('${item.quantity} ${item.product.unit} x Rs.${item.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            ])),
                                            Text('Rs.${item.lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryDark)),
                                            const SizedBox(width: 4),
                                            InkWell(onTap: () => setState(() => _items.removeAt(index)), child: const Icon(Icons.remove_circle, color: AppColors.error, size: 18)),
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
                  Container(width: 1, color: AppColors.surfaceBorder),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.background,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Customer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              isDense: true,
                              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              initialValue: _selectedCustomer,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Walk-in Customer', style: TextStyle(fontSize: 12))),
                                ..._appData.customers.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name, style: const TextStyle(fontSize: 12)))),
                              ],
                              onChanged: (v) => setState(() => _selectedCustomer = v),
                            ),
                            const SizedBox(height: 12),
                            const Text('Valid Until', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(context: context, initialDate: _validUntil ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                                if (picked != null) setState(() => _validUntil = picked);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(_validUntil != null ? DateFormat('yyyy-MM-dd').format(_validUntil!) : 'Select', style: const TextStyle(fontSize: 12)),
                                  const Icon(Icons.calendar_today, size: 14),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            TextField(controller: _notesController, maxLines: 2, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                            const SizedBox(height: 16),
                            const Text('Estimate Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryDark)),
                            const SizedBox(height: 8),
                            _summaryRow('Sub Total', _subTotal),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text('Discount (-)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                SizedBox(
                                  width: 90,
                                  height: 26,
                                  child: TextFormField(
                                    initialValue: _discount == 0 ? '' : _discount.toString(),
                                    textAlign: TextAlign.right,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), isDense: true, border: OutlineInputBorder()),
                                    style: const TextStyle(fontSize: 12),
                                    onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0.0),
                                  ),
                                ),
                              ]),
                            ),
                            _summaryRow('Taxable Amt', _taxableAmount),
                            _summaryRow('VAT (${_appData.settings.defaultVatRate}%)', _vatAmount),
                            const Divider(height: 16, thickness: 1),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Rs.${_grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                            ]),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                                child: const Text('Save Estimate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
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
  }

  Widget _summaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text('Rs.${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ]),
    );
  }
}
