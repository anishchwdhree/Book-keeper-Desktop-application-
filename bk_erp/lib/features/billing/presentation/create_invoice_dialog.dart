import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../../core/utils/nepali_date.dart';
import '../../inventory/models/product_model.dart';
import '../../customers/models/customer_model.dart';
import '../models/sale_model.dart';

class CreateInvoiceDialog extends StatefulWidget {
  const CreateInvoiceDialog({super.key});

  @override
  State<CreateInvoiceDialog> createState() => _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends State<CreateInvoiceDialog> {
  final _appData = AppData();
  CustomerModel? _selectedCustomer;
  final List<_InvoiceItem> _items = [];
  String _paymentMethod = 'Cash';

  final _mitiController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  final _paidAmountController = TextEditingController();

  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _chequeController = TextEditingController();

  double _discount = 0.0;

  static const List<String> _nepalBanks = [
    'NABIL Bank Limited',
    'NIC Asia Bank Limited',
    'Global IME Bank Limited',
    'Nepal Bank Limited',
    'Rastriya Banijya Bank Limited',
    'Agricultural Development Bank Limited (ADBL)',
    'Everest Bank Limited',
    'NMB Bank Limited',
    'Prabhu Bank Limited',
    'Himalayan Bank Limited',
    'Laxmi Sunrise Bank Limited',
    'Sanima Bank Limited',
    'Prime Commercial Bank Limited',
    'Kumari Bank Limited',
    'Citizens Bank International Limited',
    'Machhapuchchre Bank Limited',
    'Nepal Investment Mega Bank Limited (NIMB)',
    'Standard Chartered Bank Nepal Limited',
    'Nepal SBI Bank Limited',
    'Muktinath Bikas Bank Limited',
    'Garima Bikas Bank Limited',
    'Shine Resunga Development Bank Limited',
    'Jyoti Bikas Bank Limited',
    'Kamana Sewa Bikas Bank Limited',
    'Other / Custom Bank',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-set Miti Date to today's Nepali BS date
    _mitiController.text = NepaliDate.todayFormatted();

    // Auto-select first customer if available
    if (_appData.customers.isNotEmpty) {
      _selectedCustomer = _appData.customers.first;
    }
  }

  @override
  void dispose() {
    _mitiController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _chequeController.dispose();
    super.dispose();
  }

  double get _subTotal => _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get _grandTotal => (_subTotal - _discount) > 0 ? (_subTotal - _discount) : 0.0;
  double get _totalQtyKg => _items.fold(0.0, (s, i) => s + ProductModel.convertUnit(i.quantity, i.unit, 'Kg'));

  void _addItem() {
    if (_appData.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add products to Inventory first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        ProductModel? selectedProduct = _appData.products.first;
        String selectedUnit = selectedProduct.sellingUnit.isNotEmpty ? selectedProduct.sellingUnit : 'Kg';
        final qtyController = TextEditingController(text: '1');
        final rateController = TextEditingController(text: selectedProduct.sellingPrice.toStringAsFixed(2));

        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            child: Container(
              width: 440,
              decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: AppColors.tableHeaderBg,
                    child: const Row(
                      children: [
                        Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Add Product to Invoice', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Select Product *'),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 34,
                          child: DropdownButtonFormField<ProductModel>(
                            initialValue: selectedProduct,
                            isDense: true,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            dropdownColor: AppColors.surface,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                            items: _appData.products.map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.name} (Stock: ${p.currentStock.toStringAsFixed(0)} ${p.sellingUnit})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            )).toList(),
                            onChanged: (p) {
                              if (p != null) {
                                setDialogState(() {
                                  selectedProduct = p;
                                  selectedUnit = p.sellingUnit.isNotEmpty ? p.sellingUnit : 'Kg';
                                  rateController.text = p.sellingPrice.toStringAsFixed(2);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Quantity *'),
                                  const SizedBox(height: 4),
                                   _numField(qtyController, 'e.g. 10'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Selling Unit'),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 34,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: ['Quintal', 'Kuntal', 'Bag', 'Kg'].contains(selectedUnit) ? selectedUnit : 'Kg',
                                      isDense: true,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                      dropdownColor: AppColors.surface,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Quintal', child: Text('Quintal', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: 'Kuntal', child: Text('Kuntal', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: 'Bag', child: Text('Bag', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: 'Kg', child: Text('Kg', style: TextStyle(fontSize: 13))),
                                      ],
                                      onChanged: (u) {
                                        if (u != null) setDialogState(() => selectedUnit = u);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _label('Rate per Unit (Rs) *'),
                        const SizedBox(height: 4),
                        _numField(rateController, '0.00'),
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
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedProduct == null) return;
                              final qty = double.tryParse(qtyController.text) ?? 1.0;
                              final rate = double.tryParse(rateController.text) ?? selectedProduct!.sellingPrice;
                              if (qty <= 0) return;

                              Navigator.pop(context, _InvoiceItem(
                                product: selectedProduct!,
                                quantity: qty,
                                unitPrice: rate,
                                unit: selectedUnit,
                              ));
                            },
                            child: const Text('Add to Invoice', style: TextStyle(fontSize: 12)),
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
    ).then((item) {
      if (item != null && item is _InvoiceItem) {
        setState(() {
          _items.add(item);
          _paidAmountController.text = _grandTotal.toStringAsFixed(2);
        });
      }
    });
  }

  void _submit() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer.')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one product to the invoice.')));
      return;
    }

    final sale = SaleModel(
      id: _appData.nextId,
      invoiceNumber: _appData.nextInvoiceNumber,
      date: DateTime.now(),
      miti: _mitiController.text.trim(),
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name ?? 'Walk-in Customer',
      customerVat: _selectedCustomer?.vatNumber ?? '',
      items: _items.map((i) => SaleItemModel(
        product: i.product,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
        unit: i.unit,
      )).toList(),
      subTotal: _subTotal,
      discountAmount: _discount,
      taxableAmount: _grandTotal,
      vatAmount: 0.0,
      grandTotal: _grandTotal,
      paidAmount: _paymentMethod == 'Credit' ? 0.0 : (double.tryParse(_paidAmountController.text) ?? _grandTotal),
      paymentMethod: _paymentMethod,
      paymentTerms: _paymentMethod,
      status: _paymentMethod == 'Credit' 
          ? 'Unpaid' 
          : ((double.tryParse(_paidAmountController.text) ?? _grandTotal) < _grandTotal ? 'Partial' : 'Paid'),
      notes: _notesController.text.trim(),
      bankAccountId: (_paymentMethod == 'Bank Transfer' || _paymentMethod == 'Cheque') ? 1 : null,
      chequeNumber: _paymentMethod == 'Cheque' ? _chequeController.text.trim() : '',
      bankName: (_paymentMethod == 'Bank Transfer' || _paymentMethod == 'Online / QR') ? _bankNameController.text.trim() : '',
      accountHolder: (_paymentMethod == 'Bank Transfer' || _paymentMethod == 'Online / QR') ? _accountHolderController.text.trim() : '',
      accountNumber: (_paymentMethod == 'Bank Transfer' || _paymentMethod == 'Online / QR') ? _accountNumberController.text.trim() : '',
    );

    Navigator.of(context).pop(sale);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 860,
        height: 640,
        decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          children: [
            // â”€â”€ Dialog Header â”€â”€
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.tableHeaderBg,
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text('Create New Tax Invoice', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white70, size: 18),
                  ),
                ],
              ),
            ),

            // â”€â”€ Form Body â”€â”€
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Customer Selection & Miti Date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Customer *'),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 34,
                                child: DropdownButtonFormField<CustomerModel>(
                                  initialValue: _selectedCustomer,
                                  isDense: true,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  dropdownColor: AppColors.surface,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                  ),
                                  items: _appData.customers.map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text('${c.name} (${c.phone.isNotEmpty ? c.phone : "No Phone"})', style: const TextStyle(fontSize: 13)),
                                  )).toList(),
                                  onChanged: (c) {
                                    if (c == null) return;
                                    setState(() {
                                      _selectedCustomer = c;
                                      _items.clear();
                                      // Auto-populate items from customer's purchased items
                                      if (c.purchasedItems.trim().isNotEmpty) {
                                        final productNames = c.purchasedItems
                                            .split(',')
                                            .map((s) => s.trim().toLowerCase())
                                            .where((s) => s.isNotEmpty)
                                            .toList();
                                        for (final name in productNames) {
                                          final match = _appData.products.where((p) => p.name.toLowerCase().contains(name)).toList();
                                          if (match.isNotEmpty) {
                                            final product = match.first;
                                            _items.add(_InvoiceItem(
                                              product: product,
                                              quantity: c.typicalQuantity > 0 ? c.typicalQuantity : 1,
                                              unitPrice: c.sellingRate > 0 ? c.sellingRate : product.sellingPrice,
                                              unit: c.preferredUnit.isNotEmpty ? c.preferredUnit : product.sellingUnit,
                                            ));
                                          }
                                        }
                                      }
                                      // Auto-set payment method & paid amount
                                      _paymentMethod = c.paymentMethod;
                                      if (c.paidAmount > 0) {
                                        _paidAmountController.text = c.paidAmount.toStringAsFixed(2);
                                      } else {
                                        _paidAmountController.text = '';
                                      }
                                      // Auto-populate bank details if applicable
                                      if (c.paymentMethod == 'Bank Transfer' || c.paymentMethod == 'Cheque') {
                                        if (c.bankName != null && c.bankName!.isNotEmpty) {
                                          _bankNameController.text = c.bankName!;
                                        }
                                        if (c.accountHolder != null && c.accountHolder!.isNotEmpty) {
                                          _accountHolderController.text = c.accountHolder!;
                                        }
                                        if (c.accountNumber != null && c.accountNumber!.isNotEmpty) {
                                          _accountNumberController.text = c.accountNumber!;
                                        }
                                      } else {
                                        _bankNameController.clear();
                                        _accountHolderController.clear();
                                        _accountNumberController.clear();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Miti Date (BS)'),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 34,
                                child: TextField(
                                  controller: _mitiController,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    hintText: 'yyyy/mm/dd',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Customer details banner if available
                    if (_selectedCustomer != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(color: AppColors.primary.withAlpha(80)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Customer: ${_selectedCustomer!.name} | Phone: ${_selectedCustomer!.phone.isNotEmpty ? _selectedCustomer!.phone : "-"} | VAT/PAN: ${_selectedCustomer!.vatNumber.isNotEmpty ? _selectedCustomer!.vatNumber : "N/A"}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // â”€â”€ Invoice Items Section â”€â”€
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Invoice Items Table', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        SizedBox(
                          height: 28,
                          child: ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Items Grid Table
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
                      child: Column(
                        children: [
                          Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            color: AppColors.tableHeaderBg,
                            child: Row(
                              children: [
                                _headerCell('#', flex: 1, alignRight: false),
                                _headerCell('Product Name', flex: 5, alignRight: false),
                                _headerCell('Unit', flex: 2, alignRight: false),
                                _headerCell('Qty', flex: 2),
                                _headerCell('Rate (Rs)', flex: 2),
                                _headerCell('Amount (Rs)', flex: 3),
                                const SizedBox(width: 32),
                              ],
                            ),
                          ),
                          if (_items.isEmpty)
                            Container(
                              height: 90,
                              alignment: Alignment.center,
                              child: const Text('No items added. Click "+ Add Item" to populate invoice.', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                            )
                          else
                            ..._items.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              return Container(
                                height: 30,
                                color: idx.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    _dataCell('${idx + 1}', flex: 1, alignRight: false),
                                    _dataCell(item.product.name, flex: 5, alignRight: false, bold: true),
                                    _dataCell(item.unit, flex: 2, alignRight: false),
                                    _dataCell(item.quantity.toStringAsFixed(0), flex: 2),
                                    _dataCell(item.unitPrice.toStringAsFixed(2), flex: 2),
                                    _dataCell(item.lineTotal.toStringAsFixed(2), flex: 3, bold: true),
                                    SizedBox(
                                      width: 32,
                                      child: InkWell(
                                        onTap: () => setState(() => _items.removeAt(idx)),
                                        child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // â”€â”€ Payment Section â”€â”€
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _compactLabel('Payment Mode'),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 170,
                                height: 34,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _paymentMethod,
                                  isDense: true,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  dropdownColor: AppColors.surface,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Online / QR', child: Text('Online / QR', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Credit', child: Text('Credit (Unpaid)', style: TextStyle(fontSize: 13))),
                                  ],
                                  onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Bank Transfer Details Section
                          if (_paymentMethod == 'Bank Transfer' || _paymentMethod == 'Online / QR' || _paymentMethod == 'Cheque') ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                border: Border.all(color: AppColors.primary.withAlpha(90)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.account_balance, size: 15, color: AppColors.primary),
                                      SizedBox(width: 6),
                                      Text('Bank Deposit & Payment Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _compactLabel('Select / Type Bank Name *'),
                                            const SizedBox(height: 4),
                                            Autocomplete<String>(
                                               optionsBuilder: (TextEditingValue textEditingValue) {
                                                 final q = textEditingValue.text.toLowerCase();
                                                 if (q.isEmpty) return _nepalBanks;
                                                 return _nepalBanks.where((b) => b.toLowerCase().contains(q));
                                               },
                                               optionsViewBuilder: (context, onSelected, options) {
                                                 return Align(
                                                   alignment: Alignment.topLeft,
                                                   child: Material(
                                                     elevation: 6,
                                                     borderRadius: BorderRadius.circular(4),
                                                     color: Colors.white,
                                                      child: ConstrainedBox(
                                                        constraints: const BoxConstraints(maxHeight: 180),
                                                        child: Container(
                                                        width: 280,
                                                        decoration: BoxDecoration(
                                                         border: Border.all(color: AppColors.primary, width: 1.2),
                                                         borderRadius: BorderRadius.circular(4),
                                                       ),
                                                       child: ListView.separated(
                                                         padding: EdgeInsets.zero,
                                                         shrinkWrap: true,
                                                         itemCount: options.length,
                                                         separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                                         itemBuilder: (context, index) {
                                                           final option = options.elementAt(index);
                                                           return InkWell(
                                                             hoverColor: const Color(0xFFEBF3FA),
                                                             onTap: () => onSelected(option),
                                                             child: Padding(
                                                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                               child: Row(
                                                                 children: [
                                                                   const Icon(Icons.account_balance, size: 14, color: AppColors.primary),
                                                                   const SizedBox(width: 8),
                                                                   Expanded(
                                                                     child: Text(
                                                                       option,
                                                                       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                                       maxLines: 1,
                                                                       overflow: TextOverflow.ellipsis,
                                                                     ),
                                                                   ),
                                                                 ],
                                                               ),
                                                             ),
                                                           );
                                                         },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                               },
                                               onSelected: (selectedBank) {
                                                 _bankNameController.text = selectedBank;
                                               },
                                               fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                                 if (_bankNameController.text.isNotEmpty && controller.text.isEmpty) {
                                                   controller.text = _bankNameController.text;
                                                 }
                                                 controller.addListener(() {
                                                   _bankNameController.text = controller.text;
                                                 });
                                                 return _compactField(controller, 'Type initial letter (e.g. Nabil, NIC Asia)', focusNode: focusNode);
                                               },
                                             ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _compactLabel('Account Holder Name *'),
                                            const SizedBox(height: 4),
                                            _compactField(_accountHolderController, 'Full name on bank account'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _compactLabel('Account Number *'),
                                            const SizedBox(height: 4),
                                            _compactField(_accountNumberController, 'Bank account number'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Row 3: Amount Paid & Due Indicator
                    if (_paymentMethod != 'Credit')
                      Row(
                        children: [
                          _compactLabel('Amount Paid'),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 200,
                            height: 34,
                            child: TextField(
                              controller: _paidAmountController,
                              style: const TextStyle(fontSize: 13),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'e.g. 10000',
                                hintStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                prefixText: 'Rs. ',
                                prefixStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _paidAmountController.text = _grandTotal.toStringAsFixed(2);
                              });
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 14),
                            label: const Text('Full Amount', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Builder(
                            builder: (context) {
                              final paid = double.tryParse(_paidAmountController.text) ?? 0.0;
                              final due = (_grandTotal - paid).clamp(0, double.infinity);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: due > 0 ? AppColors.error.withAlpha(20) : AppColors.success.withAlpha(20),
                                  border: Border.all(color: due > 0 ? AppColors.error : AppColors.success),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  due > 0 ? 'Due: Rs. ${due.toStringAsFixed(2)}' : 'Fully Paid',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: due > 0 ? AppColors.error : AppColors.success),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 12),

                    // â”€â”€ Invoice Summary Section â”€â”€
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Invoice Summary:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                Text('Total quantity: ${_totalQtyKg.toStringAsFixed(0)} Kg', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 260,
                            child: Column(
                              children: [
                                _summaryRow('Sub Total', _subTotal),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Discount (Rs)', style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary)),
                                    SizedBox(
                                      width: 90,
                                      height: 26,
                                      child: TextField(
                                        controller: _discountController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error),
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          hintText: '0.00',
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                        ),
                                        onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0.0),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 6),
                                _summaryRow('Grand Total (Rs)', _grandTotal, bold: true),
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

            // â”€â”€ Dialog Action Buttons â”€â”€
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Save & Print Invoice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 16)),
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
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _compactLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
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

  Widget _compactField(TextEditingController ctrl, String hint, {FocusNode? focusNode}) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: AppColors.textHint),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
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
        style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _summaryRow(String label, double val, {bool bold = false, bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 13 : 11.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary)),
          Text(
            val.abs().toStringAsFixed(2),
            style: TextStyle(
              fontSize: bold ? 13 : 11.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: isRed ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceItem {
  final ProductModel product;
  final double quantity;
  final double unitPrice;
  final String unit;

  double get lineTotal => quantity * unitPrice;

  _InvoiceItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.unit = 'Kg',
  });
}
