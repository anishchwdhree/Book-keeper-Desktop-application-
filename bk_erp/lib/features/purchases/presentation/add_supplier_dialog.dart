import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/supplier_model.dart';

class AddSupplierDialog extends StatefulWidget {
  final SupplierModel? supplier;
  const AddSupplierDialog({super.key, this.supplier});

  @override
  State<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emailController;
  late final TextEditingController _vatController;
  late final TextEditingController _openingBalanceController;
  String _selectedRateType = 'Wholesale';
  final List<String> _rateTypes = ['Wholesale', 'Retail', 'Standard', 'VAT (13%)'];
  String _selectedDefaultUnit = 'Quintal';
  final List<String> _defaultUnits = ['Quintal', 'Kuntal', 'Bag', 'Kg'];
  late final TextEditingController _defaultRateController;
  late final TextEditingController _defaultQtyController;
  late final TextEditingController _suppliedItemsController;
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

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameController = TextEditingController(text: s?.name ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _vatController = TextEditingController(text: s?.vatNumber ?? '');
    _openingBalanceController = TextEditingController(
      text: isEditing ? s!.openingBalance.toStringAsFixed(2) : '',
    );
    _selectedRateType = _rateTypes.contains(s?.rateType) ? s!.rateType : 'Wholesale';
    _selectedDefaultUnit = _defaultUnits.contains(s?.defaultUnit) ? s!.defaultUnit : 'Quintal';
    _defaultRateController = TextEditingController(
      text: isEditing && s!.defaultRate > 0 ? s.defaultRate.toStringAsFixed(2) : '',
    );
    _defaultQtyController = TextEditingController(
      text: isEditing && s!.defaultQty > 0 ? s.defaultQty.toStringAsFixed(0) : '',
    );
    _suppliedItemsController = TextEditingController(text: s?.suppliedItems ?? '');
    _paymentMethod = s?.paymentMethod ?? 'Cash';
    _paidAmountController = TextEditingController(
      text: isEditing && s!.paidAmount > 0 ? s.paidAmount.toStringAsFixed(2) : '',
    );
    _bankNameController = TextEditingController(text: s?.bankName ?? '');
    _accountHolderController = TextEditingController(text: s?.accountHolder ?? '');
    _accountNumberController = TextEditingController(text: s?.accountNumber ?? '');

    _defaultRateController.addListener(_calculateAmount);
    _defaultQtyController.addListener(_calculateAmount);
  }

  void _calculateAmount() {
    final rate = double.tryParse(_defaultRateController.text) ?? 0;
    final qty = double.tryParse(_defaultQtyController.text) ?? 0;
    _paidAmountController.text = (rate * qty) > 0 ? (rate * qty).toStringAsFixed(2) : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _vatController.dispose();
    _openingBalanceController.dispose();
    _defaultRateController.removeListener(_calculateAmount);
    _defaultQtyController.removeListener(_calculateAmount);
    _defaultRateController.dispose();
    _defaultQtyController.dispose();
    _suppliedItemsController.dispose();
    _paidAmountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(SupplierModel(
      id: widget.supplier?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      vatNumber: _vatController.text.trim(),
      email: _emailController.text.trim(),
      openingBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
      outstandingBalance: isEditing
          ? widget.supplier!.outstandingBalance
          : (double.tryParse(_openingBalanceController.text) ?? 0.0),
      rateType: _selectedRateType,
      defaultUnit: _selectedDefaultUnit,
      defaultRate: double.tryParse(_defaultRateController.text) ?? 0.0,
      defaultQty: double.tryParse(_defaultQtyController.text) ?? 0.0,
      suppliedItems: _suppliedItemsController.text.trim(),
      paymentMethod: _paymentMethod,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,
      bankName: _bankNameController.text.trim(),
      accountHolder: _accountHolderController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 500,
        height: 780,
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
                    const Icon(Icons.local_shipping, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Edit Supplier' : 'Add Supplier',
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
                      _label('Supplier Name *'),
                      const SizedBox(height: 4),
                      _field(_nameController, 'Company or person name', validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),

                      // Row 2: Phone | VAT/PAN
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('Phone'), const SizedBox(height: 4), _field(_phoneController, 'Phone number')],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('VAT/PAN'), const SizedBox(height: 4), _field(_vatController, 'Optional')],
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 3: Address
                      _label('Address'),
                      const SizedBox(height: 4),
                      _field(_addressController, 'Address'),
                      const SizedBox(height: 12),

                      // Row 4: Email | Opening Balance
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('Email'), const SizedBox(height: 4), _field(_emailController, 'Email')],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_label('Opening Balance (Rs)'), const SizedBox(height: 4),
                              _field(_openingBalanceController, '0.00',
                                enabled: !isEditing,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true))],
                          )),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // â”€â”€ Purchase Info Section â”€â”€
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
                            Row(
                              children: [
                                const Icon(Icons.shopping_cart, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                const Text('Purchase Information',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Rate Type
                            _label('Rate Type'),
                            const SizedBox(height: 4),
                            _dropdown(
                              value: _selectedRateType,
                              items: _rateTypes,
                              onChanged: (v) { if (v != null) setState(() => _selectedRateType = v); },
                            ),
                            const SizedBox(height: 12),

                            // Supplied Items
                            _label('Items Supplied'),
                            const SizedBox(height: 4),
                            _field(_suppliedItemsController, 'e.g. Hybrid Seeds, Fertilizers, Pesticides'),
                            const SizedBox(height: 12),

                            // Default Unit | Default Rate
                            Row(
                              children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Buying Unit'),
                                    const SizedBox(height: 4),
                                    _dropdown(
                                      value: _selectedDefaultUnit,
                                      items: _defaultUnits,
                                      onChanged: (v) { if (v != null) setState(() => _selectedDefaultUnit = v); },
                                    ),
                                  ],
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Rate per Unit (Rs)'),
                                    const SizedBox(height: 4),
                                    _field(_defaultRateController, '0.00',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                                  ],
                                )),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Typical Order Quantity
                            _label('Typical Order Quantity'),
                            const SizedBox(height: 4),
                            _field(_defaultQtyController, 'e.g. 10, 50',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                            const SizedBox(height: 12),

                            const SizedBox(height: 12),

                            // â”€â”€ Payment Section â”€â”€
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
                                  Row(
                                    children: [
                                      const Icon(Icons.payment, size: 14, color: AppColors.secondary),
                                      const SizedBox(width: 6),
                                      const Text('Payment Mode',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      _label('Pay Via'),
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
                        icon: Icon(isEditing ? Icons.save : Icons.add, size: 15),
                        label: Text(isEditing ? 'Save' : 'Add Supplier', style: const TextStyle(fontSize: 12)),
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

  // â”€â”€ Compact form helpers â”€â”€
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
        items: items.map((t) =>
          DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))
        ).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
