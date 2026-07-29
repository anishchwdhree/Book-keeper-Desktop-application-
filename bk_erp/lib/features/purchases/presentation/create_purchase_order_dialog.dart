import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../models/purchase_order_model.dart';
import '../models/purchase_model.dart';

class _POItem {
  final ProductModel product;
  final double quantity;
  final double unitCost;
  double get lineTotal => quantity * unitCost;

  _POItem({required this.product, required this.quantity, required this.unitCost});
}

class CreatePurchaseOrderDialog extends StatefulWidget {
  const CreatePurchaseOrderDialog({super.key});

  @override
  State<CreatePurchaseOrderDialog> createState() => _CreatePurchaseOrderDialogState();
}

class _CreatePurchaseOrderDialogState extends State<CreatePurchaseOrderDialog> {
  final _appData = AppData();
  int? _selectedSupplierId;
  final List<_POItem> _poItems = [];
  final _vatRate = 13.0;
  final _notesController = TextEditingController();
  DateTime? _expectedDate;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _subTotal => _poItems.fold(0.0, (s, i) => s + i.lineTotal);
  double get _vatAmount => _subTotal * _vatRate / 100;
  double get _grandTotal => _subTotal + _vatAmount;

  void _addItemToPO() {
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
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: AppColors.tableHeaderBg,
              child: const Text('Add PO Item', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                    child: DropdownButtonFormField<ProductModel>(
                      initialValue: selectedProduct,
                      isDense: true,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Select Product',
                        hintStyle: const TextStyle(fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                      items: _appData.products.map((p) =>
                        DropdownMenuItem(value: p, child: Text(p.name, style: const TextStyle(fontSize: 12)))
                      ).toList(),
                      onChanged: (p) {
                        setDialogState(() {
                          selectedProduct = p;
                          costController.text = p?.purchasePrice.toString() ?? '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            controller: qtyController,
                            style: const TextStyle(fontSize: 12),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                            decoration: InputDecoration(
                              hintText: 'Qty',
                              hintStyle: const TextStyle(fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            controller: costController,
                            style: const TextStyle(fontSize: 12),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                            decoration: InputDecoration(
                              hintText: 'Est. Unit Cost (Rs)',
                              hintStyle: const TextStyle(fontSize: 11),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontSize: 12))),
              SizedBox(
                height: 26,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedProduct == null) return;
                    final qty = double.tryParse(qtyController.text) ?? 0;
                    final cost = double.tryParse(costController.text) ?? 0;
                    if (qty <= 0 || cost <= 0) return;
                    Navigator.pop(context, _POItem(product: selectedProduct!, quantity: qty, unitCost: cost));
                  },
                  child: const Text('Add', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          );
        });
      },
    ).then((result) {
      if (result != null && result is _POItem) {
        setState(() => _poItems.add(result));
      }
    });
  }

  void _submit() {
    if (_selectedSupplierId == null || _poItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a supplier and add items to PO')));
      return;
    }
    final supplier = _appData.suppliers.firstWhere((s) => s.id == _selectedSupplierId);
    final po = PurchaseOrderModel(
      poNumber: _appData.nextPoNumber,
      date: DateTime.now(),
      expectedDate: _expectedDate,
      supplierId: supplier.id,
      supplierName: supplier.name,
      notes: _notesController.text.trim(),
      items: _poItems.map((c) => PurchaseItemModel(
        product: c.product,
        quantity: c.quantity,
        unitCost: c.unitCost,
      )).toList(),
      subTotal: _subTotal,
      vatAmount: _vatAmount,
      grandTotal: _grandTotal,
      status: 'Sent',
    );
    Navigator.of(context).pop(po);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 750,
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            // ── Title bar (blue) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: AppColors.tableHeaderBg,
              child: Row(
                children: [
                  const Icon(Icons.request_quote_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  const Text('New Purchase Order', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close, color: Colors.white70, size: 16)),
                ],
              ),
            ),
            // ── Body ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier + Expected Date row
                    Row(
                      children: [
                        _compactLabel('Supplier'),
                        const SizedBox(width: 4),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: DropdownButtonFormField<int>(
                               initialValue: _selectedSupplierId,
                              isDense: true,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Select supplier',
                                hintStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                              ),
                              items: _appData.suppliers.map((s) =>
                                DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 12)))
                              ).toList(),
                              onChanged: (v) => setState(() => _selectedSupplierId = v),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _compactLabel('Expected Delivery'),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _expectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _expectedDate = picked);
                          },
                          child: Container(
                            width: 110,
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.surfaceBorder),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _expectedDate != null ? DateFormat('yyyy-MM-dd').format(_expectedDate!) : 'Select Date',
                                  style: TextStyle(fontSize: 11, color: _expectedDate != null ? AppColors.textPrimary : AppColors.textHint),
                                ),
                                const Icon(Icons.calendar_today, size: 13, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Notes row
                    Row(
                      children: [
                        _compactLabel('Notes'),
                        const SizedBox(width: 4),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              controller: _notesController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Optional notes...',
                                hintStyle: const TextStyle(fontSize: 11),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Items header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _compactLabel('PO Items'),
                        SizedBox(
                          height: 24,
                          child: OutlinedButton.icon(
                            onPressed: _addItemToPO,
                            icon: const Icon(Icons.add, size: 13),
                            label: const Text('Add Item', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              side: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Items table
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              color: AppColors.tableHeaderBg,
                              height: 26,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  _headerCell('#', flex: 1),
                                  _headerCell('Product', flex: 4),
                                  _headerCell('Qty', flex: 2, isNumeric: true),
                                  _headerCell('Rate', flex: 2, isNumeric: true),
                                  _headerCell('Amount', flex: 2, isNumeric: true),
                                  _headerCell('', flex: 1),
                                ],
                              ),
                            ),
                            // Table body
                            Expanded(
                              child: _poItems.isEmpty
                                  ? Center(
                                      child: Text('No items added',
                                        style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                                    )
                                  : ListView.builder(
                                      itemCount: _poItems.length,
                                      itemBuilder: (context, i) {
                                        final item = _poItems[i];
                                        return Container(
                                          color: i.isEven ? AppColors.surface : const Color(0xFFF5F5F0),
                                          height: 26,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            children: [
                                              _dataCell('${i + 1}', flex: 1, isNumeric: true),
                                              _dataCell(item.product.name, flex: 4),
                                              _dataCell(item.quantity.toStringAsFixed(0), flex: 2, isNumeric: true),
                                              _dataCell(item.unitCost.toStringAsFixed(2), flex: 2, isNumeric: true),
                                              _dataCell(item.lineTotal.toStringAsFixed(2), flex: 2, isNumeric: true, isBold: true),
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: InkWell(
                                                    onTap: () => setState(() => _poItems.removeAt(i)),
                                                    child: const Icon(Icons.close, size: 13, color: AppColors.error),
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
                    const SizedBox(height: 8),

                    // ── Summary ──
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0E8),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          const Spacer(flex: 5),
                          SizedBox(
                            width: 220,
                            child: Column(
                              children: [
                                _summaryRow('Est. Sub Total', _subTotal),
                                _summaryRow('Est. VAT (13%)', _vatAmount),
                                Container(height: 1, color: AppColors.surfaceBorder),
                                _summaryRow('Est. Grand Total', _grandTotal, bold: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Footer ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 26,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 26,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save, size: 14),
                      label: const Text('Generate PO', style: TextStyle(fontSize: 12)),
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

  // ── Compact helpers ──
  Widget _compactLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
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

  Widget _dataCell(String text, {required int flex, bool isBold = false, bool isNumeric = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 12 : 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary)),
          Text(
            value.abs().toStringAsFixed(2),
            style: TextStyle(fontSize: bold ? 12 : 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
