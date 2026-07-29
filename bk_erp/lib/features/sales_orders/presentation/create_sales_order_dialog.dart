import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../../customers/models/customer_model.dart';
import '../../billing/models/sale_model.dart';
import '../models/sales_order_model.dart';

class CreateSalesOrderDialog extends StatefulWidget {
  const CreateSalesOrderDialog({super.key});

  @override
  State<CreateSalesOrderDialog> createState() => _CreateSalesOrderDialogState();
}

class _CreateSalesOrderDialogState extends State<CreateSalesOrderDialog> {
  final _appData = AppData();
  CustomerModel? _selectedCustomer;
  final List<_SOItem> _items = [];
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  double _discount = 0.0;

  double get _subTotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get _taxableAmount => _subTotal - _discount;
  double get _vatAmount => _taxableAmount > 0 ? _taxableAmount * (_appData.settings.defaultVatRate / 100) : 0.0;
  double get _grandTotal => _taxableAmount + _vatAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCustomer == null && _appData.customers.isNotEmpty) {
        setState(() => _selectedCustomer = _appData.customers.first);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add products to Inventory first.')));
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        ProductModel? selectedProduct;
        String selectedUnit = 'Kg';
        final qtyController = TextEditingController(text: '1');
        final priceController = TextEditingController();

        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            child: Container(
              width: 380,
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
                    child: const Text('Add Item to Sales Order',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _label('Product'),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 34,
                           child: DropdownButtonFormField<ProductModel>(
                             initialValue: selectedProduct,
                            isDense: true,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                            items: _appData.products
                                .where((p) => p.currentStock > 0)
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text('${p.name} (${p.currentStock.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (p) {
                              setDialogState(() {
                                selectedProduct = p;
                                selectedUnit = p?.sellingUnit ?? 'Kg';
                                priceController.text = p?.sellingPrice.toStringAsFixed(2) ?? '';
                              });
                            },
                          ),
                        ),
                        if (selectedProduct != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: const Color(0xFFF0F0E8),
                            child: Text(
                              'Available: ${selectedProduct!.currentStock.toStringAsFixed(1)} Kg',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Unit'),
                                const SizedBox(height: 4),
                                 SizedBox(
                                   height: 34,
                                    child: DropdownButtonFormField<String>(
                                     initialValue: selectedUnit,
                                    isDense: true,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'Kg', child: Text('Kg', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Kuntal', child: Text('Kuntal', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Bag', child: Text('Bag', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Quintal', child: Text('Quintal', style: TextStyle(fontSize: 13))),
                                    ],
                                    onChanged: (v) => setDialogState(() => selectedUnit = v!),
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Qty'),
                                const SizedBox(height: 4),
                                _numField(qtyController, '1'),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _label('Rate (Rs)'),
                        const SizedBox(height: 4),
                        _numField(priceController, '0.00'),
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
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              side: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedProduct == null) return;
                              final qty = double.tryParse(qtyController.text) ?? 0;
                              final price = double.tryParse(priceController.text) ?? 0;
                              if (qty <= 0 || price <= 0) return;
                              Navigator.pop(
                                context,
                                _SOItem(product: selectedProduct!, quantity: qty, unitPrice: price, unit: selectedUnit),
                              );
                            },
                            child: const Text('Add', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).then((result) {
      if (result != null && result is _SOItem) {
        setState(() => _items.add(result));
      }
    });
  }

  void _submit() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item.')));
      return;
    }

    final so = SalesOrderModel(
      soNumber: _appData.nextSalesOrderNumber,
      date: DateTime.now(),
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name ?? 'Walk-in',
      items: _items.map((i) => SaleItemModel(
        product: i.product,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
        unit: i.unit,
      )).toList(),
      subTotal: _subTotal,
      discountAmount: _discount,
      vatAmount: _vatAmount,
      grandTotal: _grandTotal,
      status: 'Draft',
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(so);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 800,
        height: 650,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: AppColors.tableHeaderBg,
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  const Text('New Sales Order', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          SizedBox(
                          height: 26,
                          child: OutlinedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 13),
                            label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              side: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                          ),
                        ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
                              child: Column(
                                children: [
                                  Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    color: AppColors.tableHeaderBg,
                                    child: Row(
                                      children: [
                                        _headerCell('Product', flex: 3, alignRight: false),
                                        _headerCell('Unit', flex: 1, alignRight: false),
                                        _headerCell('Qty', flex: 1),
                                        _headerCell('Rate', flex: 2),
                                        _headerCell('Amount', flex: 2),
                                        const SizedBox(width: 32),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: _items.isEmpty
                                        ? const Center(
                                            child: Text('No items added.', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                                          )
                                        : ListView.builder(
                                            itemCount: _items.length,
                                            itemBuilder: (context, index) {
                                              final item = _items[index];
                                              return Container(
                                                height: 30,
                                                color: index.isEven ? AppColors.surface : const Color(0xFFF5F5F0),
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    _dataCell(item.product.name, flex: 3, alignRight: false),
                                                    _dataCell(item.unit, flex: 1, alignRight: false),
                                                    _dataCell(item.quantity.toStringAsFixed(0), flex: 1),
                                                    _dataCell(item.unitPrice.toStringAsFixed(2), flex: 2),
                                                    _dataCell(item.lineTotal.toStringAsFixed(2), flex: 2, bold: true),
                                                    SizedBox(
                                                      width: 32,
                                                      child: InkWell(
                                                        onTap: () => setState(() => _items.removeAt(index)),
                                                        child: const Icon(Icons.close, size: 13, color: AppColors.error),
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
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, color: AppColors.surfaceBorder),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Customer'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 34,
                              child: DropdownButtonFormField<CustomerModel>(
                                 initialValue: _selectedCustomer,
                                isDense: true,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                                items: _appData.customers.map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                    )).toList(),
                                onChanged: (v) => setState(() => _selectedCustomer = v),
                              ),
                            ),
                            const SizedBox(height: 10),

                            _label('Discount (Rs)'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 34,
                              child: TextField(
                                controller: _discountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                                onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0.0),
                              ),
                            ),
                            const SizedBox(height: 10),

                            _label('Notes'),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _notesController,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Optional notes...',
                                hintStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.cardGreen,
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Order Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  const SizedBox(height: 6),
                                  _summaryRow('Sub Total', _subTotal),
                                  _summaryRow('Discount', -_discount, isNegative: true),
                                  _summaryRow('Taxable Amount', _taxableAmount),
                                  _summaryRow('VAT (${_appData.settings.defaultVatRate.toStringAsFixed(0)}%)', _vatAmount),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 3),
                                    child: Divider(height: 1),
                                  ),
                                  _summaryRow('Grand Total', _grandTotal, bold: true),
                                ],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.statusBarBg,
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save, size: 14),
                      label: const Text('Save Sales Order', style: TextStyle(fontSize: 13)),
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

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  }

  Widget _numField(TextEditingController ctrl, String hint) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _headerCell(String text, {required int flex, bool alignRight = true}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
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
        style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _summaryRow(String label, double val, {bool bold = false, bool isNegative = false}) {
    final displayVal = isNegative && val < 0
        ? '- Rs. ${val.abs().toStringAsFixed(2)}'
        : 'Rs. ${val.toStringAsFixed(2)}';
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
          Text(displayVal, style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          )),
        ],
      ),
    );
  }
}

class _SOItem {
  final ProductModel product;
  final double quantity;
  final double unitPrice;
  final String unit;
  double get lineTotal => quantity * unitPrice;

  _SOItem({required this.product, required this.quantity, required this.unitPrice, this.unit = 'Kg'});
}
