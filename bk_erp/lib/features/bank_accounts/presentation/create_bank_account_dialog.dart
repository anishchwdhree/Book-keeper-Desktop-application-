import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/bank_account_model.dart';

class CreateBankAccountDialog extends StatefulWidget {
  final BankAccountModel? account;
  const CreateBankAccountDialog({super.key, this.account});

  @override
  State<CreateBankAccountDialog> createState() => _CreateBankAccountDialogState();
}

class _CreateBankAccountDialogState extends State<CreateBankAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _holderNameController;
  late final TextEditingController _branchController;
  late final TextEditingController _openingBalanceController;
  String _accountType = 'Current';
  bool _isDefault = false;

  bool get _isEditing => widget.account != null;

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
    final a = widget.account;
    _bankNameController = TextEditingController(text: a?.bankName ?? '');
    _accountNumberController = TextEditingController(text: a?.accountNumber ?? '');
    _holderNameController = TextEditingController(text: a?.accountHolderName ?? '');
    _branchController = TextEditingController(text: a?.branch ?? '');
    _openingBalanceController = TextEditingController(
      text: a != null ? a.openingBalance.toStringAsFixed(2) : '',
    );
    _accountType = a?.accountType ?? 'Current';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _holderNameController.dispose();
    _branchController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(BankAccountModel(
      id: widget.account?.id,
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountHolderName: _holderNameController.text.trim(),
      branch: _branchController.text.trim(),
      accountType: _accountType,
      openingBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
      isDefault: _isDefault,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 480,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: AppColors.tableHeaderBg,
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'Edit Bank Account' : 'Add Bank Account',
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
                    _label('Bank Name *'),
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
                              width: 320,
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
                        return _field(controller, 'Type initial letter (e.g. Nabil, NIC Asia)', focusNode: focusNode,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null);
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Account Number *'),
                            const SizedBox(height: 4),
                            _field(_accountNumberController, 'Account number',
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                          ],
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Account Type'),
                            const SizedBox(height: 4),
                            _dropdown(
                              value: _accountType,
                              items: const ['Current', 'Savings'],
                              onChanged: (v) { if (v != null) setState(() => _accountType = v); },
                            ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _label('Account Holder Name'),
                    const SizedBox(height: 4),
                    _field(_holderNameController, 'Name on account'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Branch'),
                            const SizedBox(height: 4),
                            _field(_branchController, 'Branch name'),
                          ],
                        )),
                        const SizedBox(width: 12),
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
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        SizedBox(
                          height: 34,
                          child: Checkbox(
                            value: _isDefault,
                            onChanged: (v) => setState(() => _isDefault = v ?? false),
                            activeColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('Set as default bank account', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
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
                        label: Text(_isEditing ? 'Save' : 'Add Account', style: const TextStyle(fontSize: 12)),
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
