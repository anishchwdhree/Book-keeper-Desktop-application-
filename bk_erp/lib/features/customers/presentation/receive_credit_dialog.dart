import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../billing/models/sale_model.dart';

class ReceiveCreditDialog extends StatefulWidget {
  final SaleModel sale;

  const ReceiveCreditDialog({
    super.key,
    required this.sale,
  });

  @override
  State<ReceiveCreditDialog> createState() => _ReceiveCreditDialogState();
}

class _ReceiveCreditDialogState extends State<ReceiveCreditDialog> {
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
      text: widget.sale.dueAmount.toStringAsFixed(2),
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

    _appData.paySaleCredit(
      sale: widget.sale,
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
    final due = widget.sale.dueAmount;

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
                      'Receive Customer Credit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Invoice #${widget.sale.invoiceNumber}',
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
                      _buildInfoRow('Customer Name:', widget.sale.customerName, isBold: true),
                      const SizedBox(height: 6),
                      _buildInfoRow('Total Invoice Amount:', 'Rs ${currencyFmt.format(widget.sale.grandTotal)}'),
                      const SizedBox(height: 6),
                      _buildInfoRow('Previously Received:', 'Rs ${currencyFmt.format(widget.sale.paidAmount)}'),
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
                    labelText: 'Received Amount (Rs)',
                    hintText: 'Enter amount received',
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final amt = double.tryParse(val);
                    if (amt == null || amt <= 0) return 'Invalid amount';
                    if (amt > due) return 'Amount cannot exceed due Rs ${due.toStringAsFixed(2)}';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Payment Method
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                    DropdownMenuItem(value: 'Online / QR', child: Text('Online / QR')),
                  ],
                  onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash'),
                ),

                if (_paymentMethod == 'Bank Transfer' && _appData.bankAccounts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBankAccountId,
                    decoration: InputDecoration(
                      labelText: 'Deposit To Bank Account',
                      prefixIcon: const Icon(Icons.account_balance),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _appData.bankAccounts.map((b) => DropdownMenuItem(
                      value: b.id,
                      child: Text('${b.bankName} - ${b.accountNumber}'),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedBankAccountId = v),
                    validator: (v) => _paymentMethod == 'Bank Transfer' && v == null ? 'Required for bank transfer' : null,
                  ),
                ],
                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes / Reference',
                    hintText: 'Any reference number or note...',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Record Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
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
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 14 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 14 : 13,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
