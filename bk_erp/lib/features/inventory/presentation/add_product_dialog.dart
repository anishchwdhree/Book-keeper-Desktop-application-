import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/product_model.dart';

class _ItemSuggestion {
  final String name;
  final String buyUnit;
  final double purchaseRate;
  final double defaultQty;
  final String sourceLabel;
  final bool isSupplier;

  _ItemSuggestion({
    required this.name,
    required this.buyUnit,
    required this.purchaseRate,
    required this.defaultQty,
    required this.sourceLabel,
    this.isSupplier = false,
  });
}

class AddProductDialog extends StatefulWidget {
  final ProductModel? product;
  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  final List<String> _purchaseUnits = ['Quintal', 'Kuntal', 'Bag', 'Kg', 'Pcs'];
  final List<String> _sellingUnits = ['Kg', 'Kuntal', 'Bag', 'Quintal', 'Pcs'];
  String _purchaseUnit = 'Quintal';
  String _sellingUnit = 'Kg';
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _currentStockController;
  late TextEditingController _reorderController;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    if (p != null && !_purchaseUnits.contains(p.purchaseUnit) && p.purchaseUnit.isNotEmpty) {
      _purchaseUnits.add(p.purchaseUnit);
    }
    if (p != null && !_sellingUnits.contains(p.sellingUnit) && p.sellingUnit.isNotEmpty) {
      _sellingUnits.add(p.sellingUnit);
    }
    _purchaseUnit = p?.purchaseUnit ?? 'Quintal';
    _sellingUnit = p?.sellingUnit ?? 'Kg';
    _purchasePriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toStringAsFixed(2) : '',
    );
    _sellingPriceController = TextEditingController(
      text: p != null ? p.sellingPrice.toStringAsFixed(2) : '',
    );
    _currentStockController = TextEditingController(
      text: p != null ? p.currentStock.toStringAsFixed(0) : '',
    );
    _reorderController = TextEditingController(
      text: p != null && p.reorderLevel > 0 ? p.reorderLevel.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  void _applySuggestion(_ItemSuggestion suggestion) {
    _nameController.text = suggestion.name;
    setState(() {
      if (suggestion.buyUnit.isNotEmpty) {
        if (!_purchaseUnits.contains(suggestion.buyUnit)) {
          _purchaseUnits.add(suggestion.buyUnit);
        }
        _purchaseUnit = suggestion.buyUnit;
      }
      if (suggestion.purchaseRate > 0) {
        _purchasePriceController.text = suggestion.purchaseRate.toStringAsFixed(2);
      }
      if (!_isEditing && suggestion.defaultQty > 0) {
        _currentStockController.text = suggestion.defaultQty.toStringAsFixed(0);
      }
    });
  }

  List<_ItemSuggestion> _getSuggestions(String query) {
    final suggestions = <_ItemSuggestion>[];
    final q = query.toLowerCase().trim();

    // 1. Supplier items
    for (final s in AppData().suppliers) {
      if (s.suppliedItems.isNotEmpty) {
        final items = s.suppliedItems.split(RegExp(r'[,;]'));
        for (final item in items) {
          final trimmed = item.trim();
          if (trimmed.isNotEmpty) {
            if (q.isEmpty || trimmed.toLowerCase().contains(q)) {
              suggestions.add(_ItemSuggestion(
                name: trimmed,
                buyUnit: s.defaultUnit.isNotEmpty ? s.defaultUnit : 'Quintal',
                purchaseRate: s.defaultRate,
                defaultQty: s.defaultQty,
                sourceLabel: 'Supplier: ${s.name}',
                isSupplier: true,
              ));
            }
          }
        }
      }
    }

    // 2. Existing inventory items
    for (final p in AppData().products) {
      if (q.isEmpty || p.name.toLowerCase().contains(q)) {
        suggestions.add(_ItemSuggestion(
          name: p.name,
          buyUnit: p.purchaseUnit,
          purchaseRate: p.purchasePrice,
          defaultQty: p.currentStock,
          sourceLabel: 'Existing Product',
          isSupplier: false,
        ));
      }
    }

    return suggestions;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an item name')));
      return;
    }
    Navigator.of(context).pop(ProductModel(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      inventoryGroup: 'All Items',
      purchaseUnit: _purchaseUnit,
      sellingUnit: _sellingUnit,
      unit: _sellingUnit,
      purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      initialQuantity: _isEditing ? widget.product!.initialQuantity : (double.tryParse(_currentStockController.text) ?? 0.0),
      currentStock: _isEditing ? widget.product!.currentStock : (double.tryParse(_currentStockController.text) ?? 0.0),
      reorderLevel: double.tryParse(_reorderController.text) ?? 0.0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header Bar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: AppColors.tableHeaderBg,
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'Edit Item' : 'Add Item',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white70, size: 18),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Item Name Autocomplete (Suggests from Suppliers & Inventory) ──
                    _label('Item Name *'),
                    const SizedBox(height: 4),
                    Autocomplete<_ItemSuggestion>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _getSuggestions('');
                        }
                        return _getSuggestions(textEditingValue.text);
                      },
                      displayStringForOption: (option) => option.name,
                      onSelected: (suggestion) => _applySuggestion(suggestion),
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: Container(
                              width: 480,
                              constraints: const BoxConstraints(maxHeight: 220),
                              color: Colors.white,
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      'Unit: ${option.buyUnit}  |  Rate: Rs.${option.purchaseRate.toStringAsFixed(0)}  |  Stock: ${option.defaultQty.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: option.isSupplier ? AppColors.primary.withAlpha(20) : const Color(0xFF003399).withAlpha(15),
                                        border: Border.all(color: option.isSupplier ? AppColors.primary : const Color(0xFF003399)),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        option.sourceLabel,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: option.isSupplier ? AppColors.primary : const Color(0xFF003399)),
                                      ),
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        if (textEditingController.text.isEmpty && _nameController.text.isNotEmpty) {
                          textEditingController.text = _nameController.text;
                        }
                        textEditingController.addListener(() {
                          _nameController.text = textEditingController.text;
                          // Auto match if exact supplier item typed
                          final matches = _getSuggestions(textEditingController.text);
                          if (matches.isNotEmpty && matches.first.name.toLowerCase() == textEditingController.text.toLowerCase().trim()) {
                            final match = matches.first;
                            if (_purchasePriceController.text.isEmpty && match.purchaseRate > 0) {
                              _purchasePriceController.text = match.purchaseRate.toStringAsFixed(2);
                            }
                            if (!_isEditing && _currentStockController.text.isEmpty && match.defaultQty > 0) {
                              _currentStockController.text = match.defaultQty.toStringAsFixed(0);
                            }
                          }
                        });
                        return SizedBox(
                          height: 34,
                          child: TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Type item name (auto-suggests from suppliers)...',
                              hintStyle: const TextStyle(fontSize: 12),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                              suffixIcon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Buy Unit | Sell Unit ──
                    Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Buy Unit'),
                            const SizedBox(height: 4),
                            _dropdown(
                              value: _purchaseUnit,
                              items: _purchaseUnits,
                              onChanged: (v) => setState(() => _purchaseUnit = v ?? 'Quintal'),
                            ),
                          ],
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Sell Unit'),
                            const SizedBox(height: 4),
                            _dropdown(
                              value: _sellingUnit,
                              items: _sellingUnits,
                              onChanged: (v) => setState(() => _sellingUnit = v ?? 'Kg'),
                            ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Purchase Rate | Selling Rate ──
                    Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Purchase Rate (Rs)'),
                            const SizedBox(height: 4),
                            _field(_purchasePriceController, '0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          ],
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Selling Rate (Rs)'),
                            const SizedBox(height: 4),
                            _field(_sellingPriceController, '0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Opening Stock | Reorder Level ──
                    Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Opening Stock'),
                            const SizedBox(height: 4),
                            _field(_currentStockController, '0',
                              keyboardType: TextInputType.number,
                              enabled: !_isEditing),
                          ],
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Minimum Stock'),
                            const SizedBox(height: 4),
                            _field(_reorderController, '0',
                              keyboardType: TextInputType.number),
                          ],
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Footer Buttons ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
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
                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(_isEditing ? Icons.save : Icons.add, size: 15),
                        label: Text(_isEditing ? 'Save' : 'Add Item', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 34,
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
          errorStyle: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 34,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : items.first,
        isDense: true,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        dropdownColor: AppColors.surface,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
        ),
        items: items.map((t) => DropdownMenuItem(
          value: t,
          child: Text(t, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
