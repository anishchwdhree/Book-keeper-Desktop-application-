import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/expense_model.dart';
import '../../bank_accounts/models/bank_account_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _methodFilter = 'All';

  static const _categories = [
    'General',
    'Rent',
    'Electricity',
    'Transport',
    'Salary',
    'Tea / Food',
    'Stationery',
    'Repair & Maintenance',
    'Phone / Internet',
    'Miscellaneous',
  ];

  static const _gridBorder = BorderSide(color: Color(0xFFD0D5DD), width: 0.75);

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ExpenseModel> get _filtered {
    var list = List<ExpenseModel>.from(_appData.expenses);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) {
        final bank = _appData.bankAccounts.firstWhere(
          (b) => b.id == e.bankAccountId,
          orElse: () => BankAccountModel(bankName: '', accountNumber: ''),
        );
        return e.expenseNumber.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.paidTo.toLowerCase().contains(q) ||
            e.paymentMethod.toLowerCase().contains(q) ||
            e.chequeNumber.toLowerCase().contains(q) ||
            bank.bankName.toLowerCase().contains(q) ||
            bank.accountNumber.toLowerCase().contains(q) ||
            bank.accountHolderName.toLowerCase().contains(q);
      }).toList();
    }

    if (_categoryFilter != 'All') {
      list = list.where((e) => e.category == _categoryFilter).toList();
    }

    if (_methodFilter != 'All') {
      list = list.where((e) => e.paymentMethod == _methodFilter).toList();
    }

    return list;
  }

  void _openExpenseDialog([ExpenseModel? existingExpense]) {
    final isEdit = existingExpense != null;
    final amountCtrl = TextEditingController(
      text: isEdit ? existingExpense.amount.toStringAsFixed(2) : '',
    );
    final descCtrl = TextEditingController(
      text: isEdit ? existingExpense.description : '',
    );
    final paidToCtrl = TextEditingController(
      text: isEdit ? existingExpense.paidTo : '',
    );
    final chequeCtrl = TextEditingController(
      text: isEdit ? existingExpense.chequeNumber : '',
    );
    final customCategoryCtrl = TextEditingController();

    String category = isEdit
        ? (_categories.contains(existingExpense.category)
              ? existingExpense.category
              : 'Custom')
        : 'General';
    if (isEdit && category == 'Custom') {
      customCategoryCtrl.text = existingExpense.category;
    }

    String paymentMethod = isEdit ? existingExpense.paymentMethod : 'Cash';

    final bankNameCtrl = TextEditingController();
    final bankHolderCtrl = TextEditingController();
    final bankNumberCtrl = TextEditingController();

    if (isEdit && existingExpense.bankAccountId != null) {
      final bank = _appData.bankAccounts.firstWhere(
        (b) => b.id == existingExpense.bankAccountId,
        orElse: () => BankAccountModel(bankName: '', accountNumber: ''),
      );
      bankNameCtrl.text = bank.bankName;
      bankHolderCtrl.text = bank.accountHolderName;
      bankNumberCtrl.text = bank.accountNumber;
    }

    DateTime selectedDate = isEdit ? existingExpense.date : DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              width: 540,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isEdit ? Icons.edit_note : Icons.add_card,
                          color: Colors.amberAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEdit
                              ? 'Edit Expense (${existingExpense.expenseNumber})'
                              : 'Record New Expense',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Expense Date *'),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: ctx,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                        );
                                        if (picked != null) {
                                          setDialogState(
                                            () => selectedDate = picked,
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.surfaceBorder,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          color: const Color(0xFFF9FAFB),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat(
                                                'dd-MMM-yyyy',
                                              ).format(selectedDate),
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Category *'),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.surfaceBorder,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                        color: const Color(0xFFF9FAFB),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: category,
                                          isExpanded: true,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.textPrimary,
                                          ),
                                          items: [
                                            ..._categories.map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(
                                                  c,
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const DropdownMenuItem(
                                              value: 'Custom',
                                              child: Text(
                                                '+ Other / Custom Category',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => setDialogState(
                                            () => category = v!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (category == 'Custom') ...[
                            const SizedBox(height: 10),
                            _label('Custom Category Name *'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 36,
                              child: TextField(
                                controller: customCategoryCtrl,
                                style: const TextStyle(fontSize: 12.5),
                                decoration: InputDecoration(
                                  hintText: 'Enter expense category name...',
                                  hintStyle: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textHint,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Paid To (Recipient)'),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 36,
                                      child: TextField(
                                        controller: paidToCtrl,
                                        style: const TextStyle(fontSize: 12.5),
                                        decoration: InputDecoration(
                                          hintText:
                                              'e.g. NEA, Landlord, Staff...',
                                          hintStyle: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.textHint,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Amount (Rs.) *'),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 36,
                                      child: TextField(
                                        controller: amountCtrl,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '0.00',
                                          prefixText: 'Rs. ',
                                          prefixStyle: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _label('Payment Method *'),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.surfaceBorder),
                              borderRadius: BorderRadius.circular(3),
                              color: const Color(0xFFF9FAFB),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: paymentMethod,
                                isExpanded: true,
                                menuMaxHeight: 260,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Cash',
                                    child: Row(children: [
                                      Icon(Icons.payments, size: 15, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('Cash', style: TextStyle(fontSize: 12.5)),
                                    ]),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Bank',
                                    child: Row(children: [
                                      Icon(Icons.account_balance, size: 15, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('Bank Transfer', style: TextStyle(fontSize: 12.5)),
                                    ]),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Online',
                                    child: Row(children: [
                                      Icon(Icons.qr_code_2, size: 15, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('Online / QR', style: TextStyle(fontSize: 12.5)),
                                    ]),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cheque',
                                    child: Row(children: [
                                      Icon(Icons.article, size: 15, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('Cheque', style: TextStyle(fontSize: 12.5)),
                                    ]),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Credit',
                                    child: Row(children: [
                                      Icon(Icons.credit_score, size: 15, color: Color(0xFFD32F2F)),
                                      SizedBox(width: 8),
                                      Text('Credit (Unpaid)', style: TextStyle(fontSize: 12.5, color: Color(0xFFD32F2F))),
                                    ]),
                                  ),
                                ],
                                onChanged: (v) => setDialogState(() {
                                  paymentMethod = v ?? 'Cash';
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (paymentMethod == 'Bank' ||
                              paymentMethod == 'Cheque' ||
                              paymentMethod == 'Online') ...[
                            const SizedBox(height: 12),
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
                                            _label('Select / Type Bank Name *'),
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
                                                bankNameCtrl.text = selectedBank;
                                              },
                                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                                if (bankNameCtrl.text.isNotEmpty && controller.text.isEmpty) {
                                                  controller.text = bankNameCtrl.text;
                                                }
                                                controller.addListener(() {
                                                  bankNameCtrl.text = controller.text;
                                                });
                                                return SizedBox(
                                                  height: 36,
                                                  child: TextField(
                                                    controller: controller,
                                                    focusNode: focusNode,
                                                    style: const TextStyle(fontSize: 12.5),
                                                    decoration: InputDecoration(
                                                      hintText: 'Type initial letter (e.g. Nabil)',
                                                      hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                                                    ),
                                                  ),
                                                );
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
                                            _label('Account Holder Name *'),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 36,
                                              child: TextField(
                                                controller: bankHolderCtrl,
                                                style: const TextStyle(fontSize: 12.5),
                                                decoration: InputDecoration(
                                                  hintText: 'Full name on bank account',
                                                  hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _label('Account Number *'),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              height: 36,
                                              child: TextField(
                                                controller: bankNumberCtrl,
                                                style: const TextStyle(fontSize: 12.5),
                                                decoration: InputDecoration(
                                                  hintText: 'e.g. 012345678901',
                                                  hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (paymentMethod == 'Cheque') ...[
                            const SizedBox(height: 12),
                            _label('Cheque Number *'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 36,
                              child: TextField(
                                controller: chequeCtrl,
                                style: const TextStyle(fontSize: 12.5),
                                decoration: InputDecoration(
                                  hintText: 'Enter cheque number...',
                                  hintStyle: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textHint,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          _label('Description / Notes'),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 60,
                            child: TextField(
                              controller: descCtrl,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(fontSize: 12.5),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. Electricity bill for Falgun month...',
                                hintStyle: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textHint,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: AppColors.surfaceBorder),
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            side: const BorderSide(
                              color: AppColors.surfaceBorder,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final double? amount = double.tryParse(
                              amountCtrl.text.trim(),
                            );
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a valid expense amount (> 0).',
                                  ),
                                ),
                              );
                              return;
                            }

                            final String finalCategory = category == 'Custom'
                                ? (customCategoryCtrl.text.trim().isNotEmpty
                                      ? customCategoryCtrl.text.trim()
                                      : 'General')
                                : category;

                            int? targetBankId;
                            if (paymentMethod == 'Bank' ||
                                paymentMethod == 'Cheque' ||
                                paymentMethod == 'Online') {
                              if (bankNameCtrl.text.trim().isEmpty || bankNumberCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter bank name and account number.'),
                                  ),
                                );
                                return;
                              }
                              
                              final name = bankNameCtrl.text.trim();
                              final number = bankNumberCtrl.text.trim();
                              final holder = bankHolderCtrl.text.trim();
                              
                              final existingBank = _appData.bankAccounts.cast<BankAccountModel?>().firstWhere(
                                (b) => b!.bankName == name && b.accountNumber == number,
                                orElse: () => null,
                              );
                              
                              if (existingBank != null) {
                                targetBankId = existingBank.id;
                                if (holder.isNotEmpty && existingBank.accountHolderName != holder) {
                                    _appData.updateBankAccount(existingBank.copyWith(accountHolderName: holder));
                                }
                              } else {
                                final newBank = BankAccountModel(
                                  bankName: name,
                                  accountNumber: number,
                                  accountHolderName: holder,
                                  branch: '',
                                );
                                _appData.addBankAccount(newBank);
                                targetBankId = _appData.bankAccounts.last.id;
                              }
                            }

                            if (paymentMethod == 'Cheque' &&
                                chequeCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter cheque number.'),
                                ),
                              );
                              return;
                            }

                            if (isEdit) {
                              final updated = existingExpense.copyWith(
                                date: selectedDate,
                                category: finalCategory,
                                description: descCtrl.text.trim(),
                                amount: amount,
                                paymentMethod: paymentMethod,
                                bankAccountId: targetBankId,
                                paidTo: paidToCtrl.text.trim(),
                                chequeNumber: paymentMethod == 'Cheque'
                                    ? chequeCtrl.text.trim()
                                    : '',
                              );
                              setState(() => _appData.updateExpense(updated));
                            } else {
                              final newExpense = ExpenseModel(
                                expenseNumber: _appData.nextExpenseNumber,
                                date: selectedDate,
                                category: finalCategory,
                                description: descCtrl.text.trim(),
                                amount: amount,
                                paymentMethod: paymentMethod,
                                bankAccountId: targetBankId,
                                paidTo: paidToCtrl.text.trim(),
                                chequeNumber: paymentMethod == 'Cheque'
                                    ? chequeCtrl.text.trim()
                                    : '',
                              );
                              setState(() => _appData.addExpense(newExpense));
                            }

                            Navigator.pop(ctx);
                          },
                          icon: Icon(isEdit ? Icons.check : Icons.save, size: 15),
                          label: Text(
                            isEdit ? 'Update Expense' : 'Save Expense',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
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
        },
      ),
    );
  }

  void _deleteExpense(ExpenseModel e) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: AppColors.error,
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Delete Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete expense ${e.expenseNumber}?',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e.paidTo.isNotEmpty)
                            Text(
                              'Paid To: ${e.paidTo}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            'Category: ${e.category}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Amount: Rs. ${e.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            'Payment Method: ${e.paymentMethod}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This action will permanently delete this expense record.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _appData.deleteExpense(e.id!));
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete_forever, size: 15),
                      label: const Text(
                        'Delete Expense',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final displayed = _filtered.reversed.toList();
        final totalAmount = displayed.fold(0.0, (sum, e) => sum + e.amount);

        final cashExpenses = displayed
            .where((e) => e.paymentMethod == 'Cash')
            .fold(0.0, (sum, e) => sum + e.amount);

        final bankExpenses = displayed
            .where(
              (e) => e.paymentMethod == 'Bank' || e.paymentMethod == 'Cheque',
            )
            .fold(0.0, (sum, e) => sum + e.amount);

        return Container(
          color: const Color(0xFFEBEBE4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: const Color(0xFFF4F4EE),
                child: Row(
                  children: [
                    Expanded(
                      child: _kpiCard(
                        'TOTAL EXPENSES',
                        'Rs. ${totalAmount.toStringAsFixed(0)}',
                        Icons.money_off,
                        AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        'THIS MONTH',
                        'Rs. ${_appData.monthlyExpenses.toStringAsFixed(0)}',
                        Icons.calendar_month,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        'CASH SPENT',
                        'Rs. ${cashExpenses.toStringAsFixed(0)}',
                        Icons.payments,
                        AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kpiCard(
                        'BANK / CHEQUE SPENT',
                        'Rs. ${bankExpenses.toStringAsFixed(0)}',
                        Icons.account_balance,
                        const Color(0xFF003399),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                color: const Color(0xFFE0E2E5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 320,
                      height: 30,
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search expense #, paid to, category...',
                          hintStyle: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 30,
                          ),
                          filled: true,
                          fillColor: AppColors.searchBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ],
                    const SizedBox(width: 10),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFFB0B4BE)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _categoryFilter,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'All',
                              child: Text('All Categories'),
                            ),
                            ..._categories.map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _categoryFilter = v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFFB0B4BE)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _methodFilter,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All Methods'),
                            ),
                            DropdownMenuItem(
                              value: 'Cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'Bank',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'Cheque',
                              child: Text('Cheque'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _methodFilter = v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Showing ${displayed.length} of ${_appData.expenses.length} expenses',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: () => _openExpenseDialog(),
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text(
                          'New Expense',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const minWidth = 1100.0;
                    final gridWidth = constraints.maxWidth > minWidth
                        ? constraints.maxWidth
                        : minWidth;
                    final extra = gridWidth - minWidth;
                    final numWidth = 110.0 + (extra * 0.15);
                    final catWidth = 130.0 + (extra * 0.15);
                    final paidWidth = 150.0 + (extra * 0.25);
                    final descWidth = 190.0 + (extra * 0.25);
                    final payWidth = 170.0 + (extra * 0.20);

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: gridWidth,
                        height: constraints.maxHeight,
                        child: Column(
                          children: [
                            Container(
                              height: 32,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE4E6EA),
                                    Color(0xFFD5D8DF),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFB0B4BE),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _excelHeader('S.NO', 45),
                                  _excelHeader('EXPENSE #', numWidth),
                                  _excelHeader('DATE', 100),
                                  _excelHeader('CATEGORY', catWidth),
                                  _excelHeader('PAID TO', paidWidth),
                                  _excelHeader('DESCRIPTION', descWidth),
                                  _excelHeader(
                                    'PAYMENT METHOD & BANK',
                                    payWidth,
                                  ),
                                  _excelHeader('AMOUNT (RS)', 110, isNum: true),
                                  _excelHeader('ACTIONS', 85),
                                ],
                              ),
                            ),
                            Expanded(
                              child: displayed.isEmpty
                                  ? _buildEmpty(
                                      'No expense records found matching criteria',
                                      Icons.money_off_outlined,
                                      () => _openExpenseDialog(),
                                      'Record First Expense',
                                    )
                                  : ListView.builder(
                                      itemCount: displayed.length,
                                      itemBuilder: (ctx, i) {
                                        final e = displayed[i];
                                        final bool isBank =
                                            e.paymentMethod == 'Bank' ||
                                            e.paymentMethod == 'Cheque';

                                        final bank = e.bankAccountId != null
                                            ? _appData.bankAccounts.firstWhere(
                                                (b) => b.id == e.bankAccountId,
                                                orElse: () => BankAccountModel(
                                                  bankName: '',
                                                  accountNumber: '',
                                                ),
                                              )
                                            : null;

                                        return InkWell(
                                          hoverColor: const Color(0xFFEBF3FA),
                                          child: Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: i.isEven
                                                  ? Colors.white
                                                  : const Color(0xFFF9FAFB),
                                              border: const Border(
                                                bottom: _gridBorder,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                _excelCell(
                                                  '${i + 1}',
                                                  45,
                                                  isNum: true,
                                                  textColor: AppColors.textHint,
                                                ),
                                                _excelCell(
                                                  e.expenseNumber,
                                                  numWidth,
                                                  isBold: true,
                                                  textColor: AppColors.primary,
                                                ),
                                                _excelCell(
                                                  DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(e.date),
                                                  100,
                                                ),
                                                _excelCell(
                                                  e.category,
                                                  catWidth,
                                                  isBold: true,
                                                ),
                                                _excelCell(
                                                  e.paidTo.isNotEmpty
                                                      ? e.paidTo
                                                      : '-',
                                                  paidWidth,
                                                ),
                                                _excelCell(
                                                  e.description.isNotEmpty
                                                      ? e.description
                                                      : '-',
                                                  descWidth,
                                                ),
                                                SizedBox(
                                                  width: payWidth,
                                                  child: isBank && bank != null
                                                      ? Tooltip(
                                                          richMessage: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    'Bank: ${bank.bankName}\n',
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    'Account Holder: ${bank.accountHolderName.isNotEmpty ? bank.accountHolderName : "N/A"}\n',
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    'Account #: ${bank.accountNumber}\n',
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .amberAccent,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              if (bank
                                                                  .branch
                                                                  .isNotEmpty)
                                                                TextSpan(
                                                                  text:
                                                                      'Branch: ${bank.branch} (${bank.accountType})\n',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .white70,
                                                                  ),
                                                                ),
                                                              if (e
                                                                  .chequeNumber
                                                                  .isNotEmpty)
                                                                TextSpan(
                                                                  text:
                                                                      'Cheque #: ${e.chequeNumber}',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .lightBlueAccent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF1E293B,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 4,
                                                                offset: Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                10,
                                                              ),
                                                          child: Container(
                                                            height: 32,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            decoration:
                                                                const BoxDecoration(
                                                                  border: Border(
                                                                    right:
                                                                        _gridBorder,
                                                                  ),
                                                                ),
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .account_balance,
                                                                  size: 13,
                                                                  color: AppColors
                                                                      .primary,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '${e.paymentMethod} (${bank.bankName})',
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: AppColors
                                                                          .primary,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 32,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                              ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                border: Border(
                                                                  right:
                                                                      _gridBorder,
                                                                ),
                                                              ),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.payments,
                                                                size: 13,
                                                                color: AppColors
                                                                    .secondary,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  e.paymentMethod,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColors
                                                                        .textPrimary,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                ),
                                                _excelCell(
                                                  'Rs. ${e.amount.toStringAsFixed(0)}',
                                                  110,
                                                  isNum: true,
                                                  isBold: true,
                                                  textColor: AppColors.error,
                                                ),
                                                SizedBox(
                                                  width: 85,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Tooltip(
                                                        message: 'Edit Expense',
                                                        child: InkWell(
                                                          onTap: () =>
                                                              _openExpenseDialog(
                                                                e,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .primary
                                                                  .withAlpha(
                                                                    20,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons.edit,
                                                              size: 14,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Tooltip(
                                                        message:
                                                            'Delete Expense',
                                                        child: InkWell(
                                                          onTap: () =>
                                                              _deleteExpense(e),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .error
                                                                  .withAlpha(
                                                                    20,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              size: 14,
                                                              color: AppColors
                                                                  .error,
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
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_chart,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ready  |  Total Expenses: ${_appData.expenses.length}  |  Filtered: ${displayed.length}  |  Total Amount: Rs. ${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'This Month Total: Rs. ${_appData.monthlyExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFD5D8DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );

  Widget _buildEmpty(
    String message,
    IconData icon,
    VoidCallback onPressed,
    String btnLabel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint.withAlpha(80)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
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

  Widget _excelHeader(String text, double width, {bool isNum = false}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF333333),
          letterSpacing: 0.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _excelCell(
    String text,
    double width, {
    bool isNum = false,
    bool isBold = false,
    Color? textColor,
  }) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
