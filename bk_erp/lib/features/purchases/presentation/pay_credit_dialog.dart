import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../../../core/theme/app_theme.dart';
import '../models/purchase_model.dart';

class PayCreditDialog extends StatefulWidget {
  final PurchaseModel purchase;

  const PayCreditDialog({
    super.key,
    required this.purchase,
  });

  @override
  State<PayCreditDialog> createState() => _PayCreditDialogState();
}

class _PayCreditDialogState extends State<PayCreditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appData = AppData();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  String _paymentMethod = 'Cash';
  int? _selectedBankAccountId;

  @override
  void initState() {
    super.initState();
    // Default amount to full remaining due amount
    _amountController = TextEditingController(
      text: widget.purchase.dueAmount.toStringAsFixed(2),
    );
    _notesController = TextEditingController();

    if (_appData.bankAccounts.isNotEmpty) {
      _selectedBankAccountId = _appData.bankAccounts.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final payAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (payAmount <= 0) return;

    _appData.payPurchaseCredit(
      purchase: widget.purchase,
      amount: payAmount,
      paymentMethod: _paymentMethod,
      bankAccountId: _paymentMethod == 'Bank Transfer' ? _selectedBankAccountId : null,
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_US');
    final due = widget.purchase.dueAmount;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay Supplier Credit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Bill #${widget.purchase.invoiceNumber}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bill Summary Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Supplier Name:', widget.purchase.supplierName, isBold: true),
                      const SizedBox(height: 6),
                      _buildInfoRow('Total Bill Amount:', 'Rs ${currencyFmt.format(widget.purchase.grandTotal)}'),
                      const SizedBox(height: 6),
                      _buildInfoRow('Previously Paid:', 'Rs ${currencyFmt.format(widget.purchase.paidAmount)}'),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Remaining Credit Due:',
                        'Rs ${currencyFmt.format(due)}',
                        isBold: true,
                        color: Colors.red.shade700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Payment Amount (Rs)',
                    hintText: 'Enter amount to pay',
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter payment amount';
                    }
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    if (parsed > due + 0.01) {
                      return 'Amount cannot exceed remaining due (Rs ${currencyFmt.format(due)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Payment Method Selector
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payments, size: 18),
                            SizedBox(width: 6),
                            Text('Cash'),
                          ],
                        ),
                        selected: _paymentMethod == 'Cash',
                        onSelected: (selected) {
                          if (selected) setState(() => _paymentMethod = 'Cash');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance, size: 18),
                            SizedBox(width: 6),
                            Text('Bank Transfer'),
                          ],
                        ),
                        selected: _paymentMethod == 'Bank Transfer',
                        onSelected: (selected) {
                          if (selected) setState(() => _paymentMethod = 'Bank Transfer');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bank Account Dropdown (if Bank Transfer)
                if (_paymentMethod == 'Bank Transfer') ...[
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBankAccountId,
                    decoration: InputDecoration(
                      labelText: 'Select Bank Account',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _appData.bankAccounts.map((acc) {
                      return DropdownMenuItem<int>(
                        value: acc.id,
                        child: Text('${acc.bankName} - ${acc.accountNumber}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedBankAccountId = val),
                    validator: (val) {
                      if (_paymentMethod == 'Bank Transfer' && val == null) {
                        return 'Please select a bank account';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Payment Note / Cheque Ref (Optional)',
                    hintText: 'e.g. Paid via Chq #1042',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm & Save Payment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.grey.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}
