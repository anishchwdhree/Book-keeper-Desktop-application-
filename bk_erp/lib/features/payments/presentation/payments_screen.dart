import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/payment_model.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<PaymentModel> get _filtered {
    if (_searchQuery.isEmpty) return _appData.payments;
    final q = _searchQuery.toLowerCase();
    return _appData.payments.where((p) =>
      p.paymentNumber.toLowerCase().contains(q) ||
      p.supplierName.toLowerCase().contains(q) ||
      p.paymentMethod.toLowerCase().contains(q)
    ).toList();
  }

  void _addPayment() {
    if (_appData.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add suppliers first!')));
      return;
    }
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    int? selectedSupplierId;
    String selectedSupplierName = '';
    String paymentMethod = 'Cash';
    int? selectedBankAccountId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Container(
            width: 450,
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
                      Icon(Icons.call_made, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Record Payment (Money Out)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Supplier *'),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 34,
                        child: DropdownButtonFormField<int>(
                          isDense: true,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Select Supplier',
                            hintStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                          items: _appData.suppliers.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} (Bal: Rs.${s.outstandingBalance.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12)),
                          )).toList(),
                          onChanged: (v) {
                            setDialogState(() {
                              selectedSupplierId = v;
                              selectedSupplierName = _appData.suppliers.firstWhere((s) => s.id == v).name;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _label('Amount Paid (Rs.) *'),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 34,
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _label('Payment Method'),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 34,
                        child: DropdownButtonFormField<String>(
                           initialValue: paymentMethod,
                          isDense: true,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Cheque', child: Text('Cheque', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (v) => setDialogState(() => paymentMethod = v!),
                        ),
                      ),
                      if (paymentMethod != 'Cash') ...[
                        const SizedBox(height: 12),
                        _label('Bank Account *'),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 34,
                          child: DropdownButtonFormField<int>(
                             initialValue: selectedBankAccountId,
                            isDense: true,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            dropdownColor: AppColors.surface,
                            decoration: InputDecoration(
                              hintText: 'Select Bank Account',
                              hintStyle: const TextStyle(fontSize: 12),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                            items: _appData.bankAccounts.map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.bankName, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                            )).toList(),
                            onChanged: (v) => setDialogState(() => selectedBankAccountId = v),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _label('Reference'),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 34,
                        child: TextField(
                          controller: refCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'e.g. Paid for seeds delivery',
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
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
                        child: ElevatedButton(
                          onPressed: () {
                            final amount = double.tryParse(amountCtrl.text) ?? 0;
                            if (selectedSupplierId == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select supplier and enter valid amount.')),
                              );
                              return;
                            }
                            if (paymentMethod != 'Cash' && selectedBankAccountId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select a bank account.')),
                              );
                              return;
                            }
                            final payment = PaymentModel(
                              paymentNumber: _appData.nextPaymentNumber,
                              supplierId: selectedSupplierId,
                              supplierName: selectedSupplierName,
                              amount: amount,
                              paymentMethod: paymentMethod,
                              description: refCtrl.text,
                              bankAccountId: paymentMethod != 'Cash' ? selectedBankAccountId : null,
                            );
                            setState(() => _appData.addPayment(payment));
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save Payment', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deletePayment(PaymentModel p) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Container(
          width: 400,
          decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppColors.error,
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Delete Payment', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete payment ${p.paymentNumber}?', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supplier: ${p.supplierName}', style: const TextStyle(fontSize: 12)),
                          Text('Amount: Rs. ${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                          Text('Method: ${p.paymentMethod}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will reverse the outstanding balance. This action cannot be undone.',
                      style: TextStyle(fontSize: 11, color: AppColors.error),
                    ),
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
                        onPressed: () => Navigator.pop(ctx),
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
                      child: ElevatedButton(
                        onPressed: () {
                          _appData.deletePayment(p);
                          setState(() {});
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${p.paymentNumber} deleted. Balance restored.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Delete Payment', style: TextStyle(fontSize: 12, color: Colors.white)),
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

  static const _borderSide = BorderSide(color: Color(0xFFD0D0D0), width: 0.5);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final displayed = _filtered.reversed.toList();
        final totalAmount = displayed.fold(0.0, (sum, p) => sum + p.amount);

        return Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Action Bar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.call_made, color: AppColors.error, size: 22),
                    const SizedBox(width: 8),
                    const Text('Payments (Money Out)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const Spacer(),
                    Text('Total: Rs.${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: _addPayment,
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text('New Payment', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search ──
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFB0B0B0))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 30,
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search by payment #, supplier, method...',
                          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                          prefixIconConstraints: const BoxConstraints(minWidth: 30),
                          filled: true,
                          fillColor: AppColors.searchBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _borderSide),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _borderSide),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Showing ${displayed.length} of ${_appData.payments.length}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),

              // ── Excel Header ──
              Container(
                height: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFE8E8E0), Color(0xFFD8D8D0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Row(
                  children: [
                    _excelHeader('S.No', 50),
                    _excelHeader('Payment #', 120),
                    _excelHeader('Date', 110),
                    _excelHeader('Supplier', null, isExpanded: true),
                    _excelHeader('Method', 110),
                    _excelHeader('Amount (Rs)', 120, isNum: true),
                    _excelHeader('Actions', 70, isNum: true),
                  ],
                ),
              ),

              // ── Excel Rows ──
              Expanded(
                child: displayed.isEmpty
                    ? _buildEmpty('No payments recorded', Icons.inbox_outlined, _addPayment, 'Record First Payment')
                    : ListView.builder(
                        itemCount: displayed.length,
                        itemBuilder: (ctx, i) {
                          final p = displayed[i];
                          return Container(
                            height: 30,
                            color: i.isEven ? Colors.white : const Color(0xFFF5F5F0),
                            child: Row(
                              children: [
                                _excelCell('${i + 1}', 50, isNum: true, textColor: AppColors.textHint),
                                _excelCell(p.paymentNumber, 120, isBold: true, textColor: AppColors.primary),
                                _excelCell(DateFormat('yyyy-MM-dd').format(p.date), 110),
                                _excelCell(p.supplierName, null, isExpanded: true),
                                _excelCell(p.paymentMethod, 110),
                                _excelCell('Rs.${p.amount.toStringAsFixed(0)}', 120, isNum: true, isBold: true, textColor: AppColors.error),
                                SizedBox(
                                  width: 70,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () => _deletePayment(p),
                                      child: const Icon(Icons.delete, size: 13, color: AppColors.error),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // ── Status Bar ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Text(
                  'Payments: ${_appData.payments.length}  |  Amount: Rs.${totalAmount.toStringAsFixed(0)}  |  This Month: Rs.${_appData.monthlyPayments.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary));

  Widget _buildEmpty(String message, IconData icon, VoidCallback onPressed, String btnLabel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint.withAlpha(80)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 30,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add, size: 15),
              label: Text(btnLabel, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _excelHeader(String text, double? width, {bool isNum = false, bool isExpanded = false}) {
    Widget child = Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _borderSide, bottom: _borderSide)),
      child: Align(
        alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF333333)), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
    return isExpanded ? Expanded(child: child) : child;
  }

  Widget _excelCell(String text, double? width, {bool isNum = false, bool isBold = false, Color? textColor, bool isExpanded = false}) {
    Widget child = Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _borderSide)),
      child: Align(
        alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.w600 : FontWeight.w400, color: textColor ?? AppColors.textPrimary),
        ),
      ),
    );
    return isExpanded ? Expanded(child: child) : child;
  }
}
