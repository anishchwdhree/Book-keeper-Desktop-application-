import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../models/supplier_model.dart';
import '../models/purchase_model.dart';
import '../../../core/utils/nepali_date.dart';

class AddPurchaseDialog extends StatefulWidget {
  const AddPurchaseDialog({super.key});

  @override
  State<AddPurchaseDialog> createState() => _AddPurchaseDialogState();
}

class _AddPurchaseDialogState extends State<AddPurchaseDialog> {
  final _appData = AppData();
  int? _selectedSupplierId;
  SupplierModel? _selectedSupplier;
  String _paymentMethod = 'Cash';
  int? _selectedBankAccountId;
  final List<_CartItem> _cartItems = [];
  final _mitiController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();

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

  double get _subTotal => _cartItems.fold(0.0, (s, i) => s + i.grossTotal);
  double get _discountAmount => _cartItems.fold(0.0, (s, i) => s + i.discountAmount);
  double get _grandTotal => _subTotal - _discountAmount;

  @override
  void initState() {
    super.initState();
    // Auto-populate Miti Date with today's Nepali (BS) date
    _mitiController.text = NepaliDate.todayFormatted();
    // Auto-select first supplier if available
    if (_appData.suppliers.isNotEmpty) {
      _onSupplierSelected(_appData.suppliers.first.id);
    }
  }

  @override
  void dispose() {
    _mitiController.dispose();
    _paidAmountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _onSupplierSelected(int? supplierId) {
    if (supplierId == null) return;
    final supplier = _appData.suppliers.firstWhere((s) => s.id == supplierId);
    setState(() {
      _selectedSupplierId = supplierId;
      _selectedSupplier = supplier;

      _bankNameController.text = supplier.safeBankName;
      _accountHolderController.text = supplier.safeAccountHolder;
      _accountNumberController.text = supplier.safeAccountNumber;

      // Auto-set payment method from supplier preference
      if (supplier.paymentMethod == 'Bank Account' || supplier.paymentMethod == 'Bank Transfer') {
        _paymentMethod = 'Bank Transfer';
      } else if (supplier.paymentMethod == 'Online') {
        _paymentMethod = 'Online / QR';
      } else {
        _paymentMethod = supplier.paymentMethod.isNotEmpty ? supplier.paymentMethod : 'Cash';
      }

      // Always clear and repopulate cart from supplier's suppliedItems
      _cartItems.clear();
      if (supplier.suppliedItems.isNotEmpty) {
        final items = supplier.suppliedItems.split(RegExp(r'[,;]'));
        for (final itemName in items) {
          final trimmedName = itemName.trim();
          if (trimmedName.isEmpty) continue;

          ProductModel resolvedProduct;
          try {
            resolvedProduct = _appData.products.firstWhere(
              (p) => p.name.toLowerCase() == trimmedName.toLowerCase(),
            );
          } catch (_) {
            resolvedProduct = ProductModel(
              id: null,
              name: trimmedName,
              purchasePrice: supplier.defaultRate,
              purchaseUnit: supplier.defaultUnit.isNotEmpty ? supplier.defaultUnit : 'Quintal',
            );
          }

          // Use product's own purchase values, fall back to supplier defaults
          final qty = supplier.defaultQty > 0 ? supplier.defaultQty : 1.0;
          final cost = resolvedProduct.purchasePrice > 0 ? resolvedProduct.purchasePrice : supplier.defaultRate;
          final unit = resolvedProduct.purchaseUnit.isNotEmpty ? resolvedProduct.purchaseUnit : supplier.defaultUnit;

          _cartItems.add(_CartItem(
            product: resolvedProduct,
            quantity: qty,
            unitCost: cost,
            unit: unit,
          ));
        }
      }

      _paidAmountController.text = _grandTotal > 0 ? _grandTotal.toStringAsFixed(2) : '';
    });
  }

  void _addItemToCart() {
    showDialog(
      context: context,
      builder: (context) {
        String typedProductName = '';
        final qtyController = TextEditingController(text: '1');
        final costController = TextEditingController();
        final discountController = TextEditingController(text: '0');

        String selectedUnit = 'Quintal';

        // Pre-fill unit or cost if supplier selected
        if (_selectedSupplier != null) {
          if (_selectedSupplier!.defaultUnit.isNotEmpty) {
            selectedUnit = _selectedSupplier!.defaultUnit;
          }
          if (_selectedSupplier!.defaultRate > 0) {
            costController.text = _selectedSupplier!.defaultRate.toStringAsFixed(2);
          }
          if (_selectedSupplier!.defaultQty > 0) {
            qtyController.text = _selectedSupplier!.defaultQty.toStringAsFixed(0);
          }
        }

        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            child: Container(
              width: 440,
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
                    child: const Text('Add Purchase Item', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _compactLabel('Product Name *'),
                        const SizedBox(height: 4),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            typedProductName = textEditingValue.text;
                            final query = textEditingValue.text.toLowerCase().trim();
                            final suggestions = <String>{};

                            // Supplier items
                            if (_selectedSupplier != null && _selectedSupplier!.suppliedItems.isNotEmpty) {
                              for (final item in _selectedSupplier!.suppliedItems.split(RegExp(r'[,;]'))) {
                                if (query.isEmpty || item.trim().toLowerCase().contains(query)) {
                                  suggestions.add(item.trim());
                                }
                              }
                            }
                            // Inventory products
                            for (final p in _appData.products) {
                              if (query.isEmpty || p.name.toLowerCase().contains(query)) {
                                suggestions.add(p.name);
                              }
                            }

                            return suggestions;
                          },
                          onSelected: (selectedName) {
                            typedProductName = selectedName;
                            setDialogState(() {
                              try {
                                final p = _appData.products.firstWhere((prod) => prod.name.toLowerCase() == selectedName.toLowerCase());
                                costController.text = p.purchasePrice.toStringAsFixed(2);
                                selectedUnit = p.purchaseUnit;
                              } catch (_) {
                                if (_selectedSupplier != null && _selectedSupplier!.defaultRate > 0) {
                                  costController.text = _selectedSupplier!.defaultRate.toStringAsFixed(2);
                                }
                              }
                            });
                          },
                          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                            textEditingController.addListener(() {
                              typedProductName = textEditingController.text;
                            });
                            return _compactField(textEditingController, 'Search or type product name', focusNode: focusNode);
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _compactLabel('Buying Unit'),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 34,
                                child: DropdownButtonFormField<String>(
                                  initialValue: ['Quintal', 'Kuntal', 'Bag', 'Kg', 'Pcs'].contains(selectedUnit) ? selectedUnit : 'Quintal',
                                  isDense: true,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
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
                                    DropdownMenuItem(value: 'Pcs', child: Text('Pcs', style: TextStyle(fontSize: 13))),
                                  ],
                                  onChanged: (v) => setDialogState(() => selectedUnit = v ?? 'Quintal'),
                                ),
                              ),
                            ],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_compactLabel('Quantity'), const SizedBox(height: 3), _compactNumField(qtyController, '1')],
                          )),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_compactLabel('Rate per Unit (Rs)'), const SizedBox(height: 3), _compactNumField(costController, '0.00')],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_compactLabel('Discount %'), const SizedBox(height: 3), _compactNumField(discountController, '0')],
                          )),
                        ]),

                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              if (typedProductName.trim().isEmpty) return;
                              final qty = double.tryParse(qtyController.text) ?? 0;
                              final cost = double.tryParse(costController.text) ?? 0;
                              final disc = double.tryParse(discountController.text) ?? 0;
                              if (qty <= 0 || cost <= 0) return;

                              ProductModel resolvedProduct;
                              try {
                                resolvedProduct = _appData.products.firstWhere(
                                  (p) => p.name.toLowerCase() == typedProductName.toLowerCase(),
                                );
                              } catch (_) {
                                resolvedProduct = ProductModel(
                                  id: null,
                                  name: typedProductName.trim(),
                                  purchasePrice: cost,
                                  purchaseUnit: selectedUnit,
                                );
                              }

                              Navigator.pop(context, _CartItem(
                                product: resolvedProduct,
                                quantity: qty,
                                unitCost: cost,
                                unit: selectedUnit,
                                discountPercent: disc,
                              ));
                            },
                            child: const Text('Add to Cart', style: TextStyle(fontSize: 13)),
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
      if (result != null && result is _CartItem) {
        setState(() {
          _cartItems.add(result);
          _paidAmountController.text = _grandTotal.toStringAsFixed(2);
        });
      }
    });
  }

  void _submit() {
    if (_selectedSupplierId == null || _cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a supplier and add at least one item')));
      return;
    }
    if ((_paymentMethod == 'Bank Transfer' || _paymentMethod == 'Cheque') && _bankNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or type a bank name')));
      return;
    }

    final supplier = _appData.suppliers.firstWhere((s) => s.id == _selectedSupplierId);

    // Auto-create any missing items in inventory so stock update works
    // (guards against creating the same item twice if the cart has duplicate rows)
    final createdNames = <String>{};
    for (final item in _cartItems) {
      if (item.product.id == null) {
        final nameKey = item.product.name.trim().toLowerCase();
        if (!createdNames.add(nameKey)) continue;
        final newProduct = ProductModel(
          id: _appData.nextId,
          name: item.product.name,
          purchaseUnit: item.unit,
          sellingUnit: 'Kg',
          purchasePrice: item.unitCost,
          sellingPrice: item.unitCost * 1.15, // Default 15% margin estimate
          initialQuantity: 0.0,
          currentStock: 0.0,
        );
        _appData.addProduct(newProduct);
      }
    }

    final purchase = PurchaseModel(
      id: _appData.nextId,
      invoiceNumber: _appData.nextPurchaseNumber,
      date: DateTime.now(),
      miti: _mitiController.text.trim(),
      supplierName: supplier.name,
      supplierId: supplier.id,
      items: _cartItems.map((c) {
        // Resolve product ID in case it was auto-created
        final prod = _appData.products.firstWhere(
          (p) => p.name.toLowerCase() == c.product.name.toLowerCase(),
          orElse: () => c.product,
        );
        return PurchaseItemModel(
          product: prod,
          quantity: c.quantity,
          unitCost: c.unitCost,
          unit: c.unit,
          discountPercent: c.discountPercent,
          discountAmount: c.discountAmount,
          vatPercent: 0.0,
          vatAmount: 0.0,
        );
      }).toList(),
      subTotal: _subTotal,
      discountAmount: _discountAmount,
      taxableAmount: _grandTotal,
      vatAmount: 0.0,
      grandTotal: _grandTotal,
      paymentMethod: _paymentMethod,
      bankAccountId: _selectedBankAccountId,
      paidAmount: _paymentMethod == 'Credit' ? 0.0 : (double.tryParse(_paidAmountController.text) ?? _grandTotal),
    );

    Navigator.of(context).pop(purchase);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 800,
        height: 680,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            // â”€â”€ Title Bar (Blue) â”€â”€
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.tableHeaderBg,
              child: Row(
                children: [
                  const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text('New Purchase Entry', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close, color: Colors.white70, size: 18)),
                ],
              ),
            ),

            // â”€â”€ Main Body â”€â”€
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Supplier & Miti Date
                    Row(
                      children: [
                        _compactLabel('Supplier *'),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedSupplierId,
                              isDense: true,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Select supplier',
                                hintStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                              ),
                              items: _appData.suppliers.map((s) =>
                                DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))
                              ).toList(),
                              onChanged: _onSupplierSelected,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _compactLabel('Miti Date'),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 140,
                          height: 34,
                          child: TextField(
                            controller: _mitiController,
                            style: const TextStyle(fontSize: 13),
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
                    const SizedBox(height: 8),

                    // Supplier Auto-Details Banner (if supplier selected)
                    if (_selectedSupplier != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F8),
                          border: Border.all(color: AppColors.primary.withAlpha(60)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 15, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rate Type: ${_selectedSupplier!.rateType.isNotEmpty ? _selectedSupplier!.rateType : "Wholesale"}  |  Items: ${_selectedSupplier!.suppliedItems.isNotEmpty ? _selectedSupplier!.suppliedItems : "-"}  |  Rate: Rs.${_selectedSupplier!.defaultRate.toStringAsFixed(0)}/${_selectedSupplier!.defaultUnit}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedSupplier!.safeBankName.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(20),
                                  border: Border.all(color: AppColors.success.withAlpha(80)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_balance, size: 12, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_selectedSupplier!.safeBankName} (${_selectedSupplier!.safeAccountNumber})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Row 2: Payment Method
                    Row(
                      children: [
                        _compactLabel('Payment Mode'),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 170,
                          height: 34,
                          child: DropdownButtonFormField<String>(
                            initialValue: _paymentMethod == 'Bank Account' ? 'Bank Transfer' : _paymentMethod,
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
                            onChanged: (v) => setState(() {
                              _paymentMethod = v ?? 'Cash';
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Bank Details Section (Visible when Bank Transfer / Online / Cheque selected)
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
                                Text('Bank Transfer Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                                                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
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
                    const SizedBox(height: 8),

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
                    const SizedBox(height: 10),

                    // Header for Items Table & Add Button
                    Row(
                      children: [
                        const Text('Purchase Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const Spacer(),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: _addItemToCart,
                            icon: const Icon(Icons.add, size: 15),
                            label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Items Spreadsheet Grid
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.surfaceBorder),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 30,
                              color: AppColors.tableHeaderBg,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  _headerCell('#', flex: 1),
                                  _headerCell('Product Name', flex: 5),
                                  _headerCell('Unit', flex: 2),
                                  _headerCell('Qty', flex: 2, isNumeric: true),
                                  _headerCell('Rate (Rs)', flex: 3, isNumeric: true),
                                  _headerCell('Amount (Rs)', flex: 3, isNumeric: true),
                                  const SizedBox(width: 36),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _cartItems.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.shopping_bag_outlined, size: 36, color: AppColors.textHint.withAlpha(80)),
                                          const SizedBox(height: 6),
                                          const Text('No purchase items added yet', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _cartItems.length,
                                      separatorBuilder: (_, _) => const Divider(height: 1),
                                      itemBuilder: (ctx, i) {
                                        final item = _cartItems[i];
                                        return Container(
                                          height: 32,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                          child: Row(
                                            children: [
                                              _dataCell('${i + 1}', flex: 1),
                                              _dataCell(item.product.name, flex: 5, isBold: true),
                                              _dataCell(item.unit, flex: 2),
                                              _dataCell(item.quantity.toStringAsFixed(0), flex: 2, isNumeric: true),
                                              _dataCell(item.unitCost.toStringAsFixed(2), flex: 3, isNumeric: true),
                                              _dataCell(item.lineTotal.toStringAsFixed(2), flex: 3, isNumeric: true, isBold: true),
                                              SizedBox(
                                                width: 36,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _cartItems.removeAt(i);
                                                      _paidAmountController.text = _grandTotal.toStringAsFixed(2);
                                                    });
                                                  },
                                                  child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
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

                    // Invoice Totals Calculation Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F0),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Purchase Summary:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                Text('Total amount after applicable discounts.', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 240,
                            child: Column(
                              children: [
                                _summaryRow('Sub Total', _subTotal),
                                _summaryRow('Discount', _discountAmount, isRed: true),
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

            // â”€â”€ Footer Controls â”€â”€
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Save Purchase', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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

  Widget _compactLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _compactField(TextEditingController ctrl, String hint, {FocusNode? focusNode}) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 13),
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

  Widget _compactNumField(TextEditingController ctrl, String hint) {
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

  Widget _headerCell(String text, {required int flex, bool isNumeric = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
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

  Widget _summaryRow(String label, double value, {bool bold = false, bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 13 : 11.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary)),
          Text(
            value.abs().toStringAsFixed(2),
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

class _CartItem {
  final ProductModel product;
  final double quantity;
  final double unitCost;
  final String unit;
  final double discountPercent;

  double get grossTotal => quantity * unitCost;
  double get discountAmount => grossTotal * (discountPercent / 100);
  double get lineTotal => grossTotal - discountAmount;

  _CartItem({
    required this.product,
    required this.quantity,
    required this.unitCost,
    this.unit = 'Quintal',
    this.discountPercent = 0.0,
  });
}
