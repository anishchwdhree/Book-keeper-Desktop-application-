import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';
import '../models/customer_model.dart';

class AddCustomerDialog extends StatefulWidget {
  final CustomerModel? customer;
  const AddCustomerDialog({super.key, this.customer});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appData = AppData();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emailController;
  late final TextEditingController _vatController;
  late final TextEditingController _openingBalanceController;
  String _rateType = 'Standard';
  String _preferredUnit = 'Kg';
  final List<String> _preferredUnits = ['Kg', 'Kuntal', 'Bag', 'Quintal'];
  late final TextEditingController _sellingRateController;
  late final TextEditingController _typicalQtyController;
  late final TextEditingController _purchasedItemsController;
  String _paymentMethod = 'Cash';
  late final TextEditingController _paidAmountController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _accountNumberController;

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

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _vatController = TextEditingController(text: c?.vatNumber ?? '');
    _openingBalanceController = TextEditingController(
      text: c != null ? c.openingBalance.toStringAsFixed(2) : '',
    );
    _rateType = c?.rateType ?? 'Standard';
    _preferredUnit = _preferredUnits.contains(c?.preferredUnit) ? c!.preferredUnit : 'Kg';
    _sellingRateController = TextEditingController(
      text: c != null && c.sellingRate > 0 ? c.sellingRate.toStringAsFixed(2) : '',
    );
    _typicalQtyController = TextEditingController(
      text: c != null && c.typicalQuantity > 0 ? c.typicalQuantity.toStringAsFixed(0) : '',
    );
    _purchasedItemsController = TextEditingController(text: c?.purchasedItems ?? '');
    _paymentMethod = c?.paymentMethod ?? 'Cash';
    _paidAmountController = TextEditingController(
      text: c != null && c.paidAmount > 0 ? c.paidAmount.toStringAsFixed(2) : '',
    );
    _bankNameController = TextEditingController(text: c?.bankName ?? '');
    _accountHolderController = TextEditingController(text: c?.accountHolder ?? '');
    _accountNumberController = TextEditingController(text: c?.accountNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _vatController.dispose();
    _openingBalanceController.dispose();
    _sellingRateController.dispose();
    _typicalQtyController.dispose();
    _purchasedItemsController.dispose();
    _paidAmountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(CustomerModel(
      id: widget.customer?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      vatNumber: _vatController.text.trim(),
      openingBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
      outstandingBalance: _isEditing
          ? widget.customer!.outstandingBalance
          : (double.tryParse(_openingBalanceController.text) ?? 0.0),
      rateType: _rateType,
      preferredUnit: _preferredUnit,
      sellingRate: double.tryParse(_sellingRateController.text) ?? 0.0,
      typicalQuantity: double.tryParse(_typicalQtyController.text) ?? 0.0,
      purchasedItems: _purchasedItemsController.text.trim(),
      paymentMethod: _paymentMethod,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,
      bankName: _paymentMethod == 'Bank Transfer' ? _bankNameController.text.trim() : '',
      accountHolder: _paymentMethod == 'Bank Transfer' ? _accountHolderController.text.trim() : '',
      accountNumber: _paymentMethod == 'Bank Transfer' ? _accountNumberController.text.trim() : '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 520,
        height: 800,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // â”€â”€ Title bar (blue) â”€â”€
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: AppColors.tableHeaderBg,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'Edit Customer' : 'Create Customer',
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
              // â”€â”€ Form body â”€â”€
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name
                      _label('Customer Name *'),
                      const SizedBox(height: 4),
                      _field(_nameController, 'Full name',
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),

                      // Row 2: Phone | Address
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('Phone'), const SizedBox(height: 4), _field(_phoneController, 'Phone number')],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('Address'), const SizedBox(height: 4), _field(_addressController, 'Address')],
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 3: Email | VAT/PAN
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('Email'), const SizedBox(height: 4), _field(_emailController, 'Email')],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('VAT/PAN'), const SizedBox(height: 4), _field(_vatController, 'Optional')],
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 4: Opening Balance | Rate Type
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Opening Balance (Rs)'),
                              const SizedBox(height: 4),
                              _field(_openingBalanceController, '0.00',
                                enabled: !_isEditing,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                            ],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Rate Type'),
                              const SizedBox(height: 4),
                              _dropdown(
                                value: _rateType,
                                items: ['Standard', 'Wholesale', 'Retail', 'VAT (13%)'],
                                onChanged: (v) { if (v != null) setState(() => _rateType = v); },
                              ),
                            ],
                          )),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // â”€â”€ Selling Info Section â”€â”€
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0E8),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.storefront, size: 14, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text('Selling Information',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Preferred Selling Unit
                            _label('Preferred Selling Unit'),
                            const SizedBox(height: 4),
                            _dropdown(
                              value: _preferredUnit,
                              items: _preferredUnits,
                              onChanged: (v) { if (v != null) setState(() => _preferredUnit = v); },
                            ),
                            const SizedBox(height: 12),

                            // Items Purchased (Product Search with Stock)
                            _label('Items Purchased'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 34,
                              child: Autocomplete<ProductModel>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  final q = textEditingValue.text.toLowerCase();
                                  if (q.isEmpty) return _appData.products;
                                  return _appData.products.where((p) => p.name.toLowerCase().contains(q));
                                },
                                displayStringForOption: (p) => p.name,
                                onSelected: (ProductModel p) {
                                  final current = _purchasedItemsController.text.trim();
                                  if (current.isEmpty) {
                                    _purchasedItemsController.text = p.name;
                                  } else {
                                    _purchasedItemsController.text = '$current, ${p.name}';
                                  }
                                },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 6,
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.white,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 220),
                                        child: Container(
                                          width: 420,
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
                                              final p = options.elementAt(index);
                                              final stock = p.currentStock;
                                              final Color stockColor = stock <= 0
                                                  ? AppColors.error
                                                  : stock <= p.reorderLevel
                                                      ? Colors.orange.shade700
                                                      : AppColors.success;
                                              return InkWell(
                                                hoverColor: const Color(0xFFEBF3FA),
                                                onTap: () => onSelected(p),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withAlpha(20),
                                                          borderRadius: BorderRadius.circular(3),
                                                        ),
                                                        child: const Icon(Icons.inventory_2, size: 14, color: AppColors.primary),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              p.name,
                                                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              '${p.sellingUnit.isNotEmpty ? p.sellingUnit : "Kg"}  |  Rs. ${p.sellingPrice.toStringAsFixed(2)}/${p.sellingUnit.isNotEmpty ? p.sellingUnit : "Kg"}',
                                                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: stockColor.withAlpha(20),
                                                          borderRadius: BorderRadius.circular(3),
                                                          border: Border.all(color: stockColor.withAlpha(60)),
                                                        ),
                                                        child: Text(
                                                          'Stock: ${stock.toStringAsFixed(0)}',
                                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: stockColor),
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
                                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                  if (_purchasedItemsController.text.isNotEmpty && controller.text.isEmpty) {
                                    controller.text = _purchasedItemsController.text;
                                  }
                                  controller.addListener(() {
                                    _purchasedItemsController.text = controller.text;
                                  });
                                  return SizedBox(
                                    height: 34,
                                    child: TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Type product name to search...',
                                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Typical Quantity | Rate per Unit (side by side)
                            Row(
                              children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Typical Order Qty'),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 34,
                                      child: TextField(
                                        controller: _typicalQtyController,
                                        onChanged: (_) => setState(() {}),
                                        style: const TextStyle(fontSize: 13),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                                        decoration: InputDecoration(
                                          hintText: 'e.g. 10',
                                          hintStyle: const TextStyle(fontSize: 12),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Selling Rate (Rs/Unit)'),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 34,
                                      child: TextField(
                                        controller: _sellingRateController,
                                        onChanged: (_) => setState(() {}),
                                        style: const TextStyle(fontSize: 13),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                                        decoration: InputDecoration(
                                          hintText: 'e.g. 45.00',
                                          hintStyle: const TextStyle(fontSize: 12),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Auto-calculated Amount
                            _label('Amount (Qty x Rate)'),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (_) {
                                final qty = double.tryParse(_typicalQtyController.text) ?? 0;
                                final rate = double.tryParse(_sellingRateController.text) ?? 0;
                                final amount = qty * rate;
                                return Container(
                                  width: double.infinity,
                                  height: 34,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: amount > 0 ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(color: amount > 0 ? AppColors.success : AppColors.surfaceBorder),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    amount > 0 ? 'Rs. ${amount.toStringAsFixed(2)}' : 'Rs. 0.00',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: amount > 0 ? AppColors.success : AppColors.textHint,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // Info box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.cardBlue,
                                border: Border.all(color: AppColors.info.withAlpha(60)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 12, color: AppColors.info),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(
                                    'Sells to this customer at Rs${_sellingRateController.text.isEmpty ? '0.00' : _sellingRateController.text}/$_preferredUnit. '
                                    'Typical order: ${_typicalQtyController.text.isEmpty ? '0' : _typicalQtyController.text} $_preferredUnit.',
                                    style: const TextStyle(fontSize: 10, color: AppColors.info),
                                  )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // â”€â”€ Payment Section (EXACT MATCH to AddSupplierDialog) â”€â”€
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.payment, size: 14, color: AppColors.secondary),
                                      SizedBox(width: 6),
                                      Text('Payment Preference & Mode',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _label('Receive Via'),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 160,
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
                                            DropdownMenuItem(value: 'Online', child: Text('Online', style: TextStyle(fontSize: 13))),
                                          ],
                                          onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _label('Amount (Rs)'),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: SizedBox(
                                          height: 34,
                                          child: TextField(
                                            controller: _paidAmountController,
                                            style: const TextStyle(fontSize: 13),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: InputDecoration(
                                              hintText: 'e.g. 10000',
                                              hintStyle: const TextStyle(fontSize: 12),
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (_paymentMethod == 'Bank Transfer') ...[
                                    const SizedBox(height: 10),
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
                                              Icon(Icons.account_balance, size: 16, color: AppColors.primary),
                                              SizedBox(width: 6),
                                              Text('Bank Account & Deposit Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          _label('Select Bank Name *'),
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
                                                   child: Container(
                                                     width: 320,
                                                     constraints: const BoxConstraints(maxHeight: 180),
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
                                               return _field(controller, 'Type initial letter (e.g. Nabil, NIC Asia)', focusNode: focusNode);
                                             },
                                           ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _label('Account Holder Name *'),
                                                    const SizedBox(height: 4),
                                                    _field(_accountHolderController, 'Full name on bank account'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _label('Account Number *'),
                                                    const SizedBox(height: 4),
                                                    _field(_accountNumberController, 'Bank account number'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
              // â”€â”€ Footer â”€â”€
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
                        label: Text(_isEditing ? 'Save' : 'Create Customer', style: const TextStyle(fontSize: 12)),
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
    FocusNode? focusNode,
  }) {
    return SizedBox(
      height: 34,
      child: TextFormField(
        controller: ctrl,
        focusNode: focusNode,
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
        initialValue: value,
        isDense: true,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
        ),
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
