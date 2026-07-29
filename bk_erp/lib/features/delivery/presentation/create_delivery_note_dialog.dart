import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../models/delivery_note_model.dart';
import '../../billing/models/sale_model.dart';

class _DeliveryItem {
  final ProductModel product;
  final double quantity;

  _DeliveryItem({required this.product, required this.quantity});
}

class CreateDeliveryNoteDialog extends StatefulWidget {
  const CreateDeliveryNoteDialog({super.key});

  @override
  State<CreateDeliveryNoteDialog> createState() => _CreateDeliveryNoteDialogState();
}

class _CreateDeliveryNoteDialogState extends State<CreateDeliveryNoteDialog> {
  final _appData = AppData();
  String? _selectedCustomer;
  final List<_DeliveryItem> _items = [];

  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _vehicleController.dispose();
    _driverController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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

        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Dispatch Item', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<ProductModel>(
                isDense: true,
                decoration: const InputDecoration(labelText: 'Select Product', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                items: _appData.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (Stock: ${p.currentStock})', style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (p) => setDialogState(() => selectedProduct = p),
              ),
              const SizedBox(height: 10),
              TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantity', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (selectedProduct == null) return;
                  final qty = double.tryParse(qtyController.text) ?? 0;
                  if (qty <= 0) return;
                  setState(() {
                    final existingIndex = _items.indexWhere((i) => i.product.id == selectedProduct!.id);
                    if (existingIndex >= 0) {
                      _items[existingIndex] = _DeliveryItem(product: selectedProduct!, quantity: _items[existingIndex].quantity + qty);
                    } else {
                      _items.add(_DeliveryItem(product: selectedProduct!, quantity: qty));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot save empty delivery note.')));
      return;
    }

    final custId = int.tryParse(_selectedCustomer ?? '');
    final customer = _appData.customers.firstWhere((c) => c.id == custId, orElse: () => _appData.customers.first);

    final note = DeliveryNoteModel(
      deliveryNumber: _appData.nextDeliveryNumber,
      date: DateTime.now(),
      customerId: custId,
      customerName: custId == null ? 'Walk-in Customer' : customer.name,
      items: _items.map((i) => SaleItemModel(product: i.product, quantity: i.quantity, unitPrice: 0.0)).toList(),
      vehicleNumber: _vehicleController.text.trim(),
      driverName: _driverController.text.trim(),
      status: 'Dispatched',
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(note);
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
              decoration: const BoxDecoration(color: AppColors.tableHeaderBg, borderRadius: BorderRadius.vertical(top: Radius.circular(3))),
              child: Row(children: [
                const Icon(Icons.local_shipping, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('New Delivery Note (Challan)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
                            label: const Text('Add Dispatch Item', style: TextStyle(fontSize: 12)),
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
                                              Text('${item.quantity} ${item.product.unit}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            ])),
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
                            const Text('Customer (To)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              isDense: true,
                              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              initialValue: _selectedCustomer,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Walk-in / Cash', style: TextStyle(fontSize: 12))),
                                ..._appData.customers.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name, style: const TextStyle(fontSize: 12)))),
                              ],
                              onChanged: (v) => setState(() => _selectedCustomer = v),
                            ),
                            const SizedBox(height: 12),
                            const Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            TextField(controller: _vehicleController, decoration: const InputDecoration(hintText: 'e.g. Ba. 2 Kha 1234', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                            const SizedBox(height: 12),
                            const Text('Driver Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            TextField(controller: _driverController, decoration: const InputDecoration(hintText: 'e.g. Ram Bahadur', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                            const SizedBox(height: 12),
                            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.primary)),
                            const SizedBox(height: 4),
                            TextField(controller: _notesController, maxLines: 2, decoration: const InputDecoration(hintText: 'Any delivery instructions', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8))),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                                child: const Text('Generate Delivery Note', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
}
