import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../../core/utils/responsive.dart';
import '../models/bank_account_model.dart';
import 'create_bank_account_dialog.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final nf = NumberFormat.currency(locale: 'en_NP', symbol: 'Rs. ');

  List<BankAccountModel> get _filtered {
    if (_searchQuery.isEmpty) return _appData.bankAccounts;
    final q = _searchQuery.toLowerCase();
    return _appData.bankAccounts.where((a) =>
      a.bankName.toLowerCase().contains(q) ||
      a.accountNumber.toLowerCase().contains(q) ||
      a.accountHolderName.toLowerCase().contains(q) ||
      a.branch.toLowerCase().contains(q)
    ).toList();
  }

  void _openDialog([BankAccountModel? account]) async {
    final result = await showDialog<BankAccountModel>(
      context: context,
      builder: (_) => CreateBankAccountDialog(account: account),
    );
    if (result != null) {
      setState(() {
        if (account != null) {
          _appData.updateBankAccount(result);
        } else {
          _appData.addBankAccount(result);
        }
      });
    }
  }

  void _delete(BankAccountModel a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        title: const Text('Delete Bank Account'),
        content: Text('Delete "${a.bankName}" (${a.accountNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _appData.deleteBankAccount(a.id!));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.contentPadding;

    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final totalBalance = _appData.bankAccounts.fold(0.0, (sum, a) =>
          sum + _appData.getBankAccountBalance(a.id ?? 0));

        return Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    const Text('Bank Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: () => _openDialog(),
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text('Add Bank Account', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13, color: AppColors.searchText),
                              decoration: InputDecoration(
                                hintText: 'Search by bank name, account number...',
                                hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                                filled: true,
                                fillColor: AppColors.searchBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _searchQuery = v),
                            ),
                          ),
                        ),

                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(color: AppColors.tableHeaderBg),
                          child: Row(
                            children: [
                              _headerCell('Bank Name', flex: 3),
                              _headerCell('Account No.', flex: 2),
                              _headerCell('Holder Name', flex: 2),
                              _headerCell('Branch', flex: 2),
                              _headerCell('Type', flex: 1),
                              _headerCell('Balance (Rs)', flex: 2, isNumeric: true),
                              _headerCell('Default', flex: 1),
                              _headerCell('Actions', flex: 2, isNumeric: true),
                            ],
                          ),
                        ),

                        Expanded(
                          child: _appData.bankAccounts.isEmpty && _searchQuery.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.account_balance_outlined, size: 48, color: AppColors.textHint.withAlpha(80)),
                                      const SizedBox(height: 12),
                                      const Text('No bank accounts yet', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _openDialog(),
                                          icon: const Icon(Icons.add, size: 15),
                                          label: const Text('Add First Account', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _filtered.isEmpty
                                  ? const Center(child: Text('No matching accounts', style: TextStyle(color: AppColors.textSecondary)))
                                  : ListView.builder(
                                      itemCount: _filtered.length,
                                      itemBuilder: (ctx, i) {
                                        final a = _filtered[i];
                                        final balance = _appData.getBankAccountBalance(a.id ?? 0);
                                        return Container(
                                          height: 30,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: i.isEven ? AppColors.surface : const Color(0xFFF5F5F0),
                                            border: const Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  a.bankName,
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(a.accountNumber, style: const TextStyle(fontSize: 12)),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  a.accountHolderName.isEmpty ? '-' : a.accountHolderName,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  a.branch.isEmpty ? '-' : a.branch,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(a.accountType, style: const TextStyle(fontSize: 12)),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  nf.format(balance),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: balance >= 0 ? AppColors.success : AppColors.error,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: a.isDefault
                                                    ? const Icon(Icons.check_circle, size: 14, color: AppColors.success)
                                                    : const Icon(Icons.radio_button_unchecked, size: 14, color: AppColors.textHint),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      _actionButton(Icons.edit, AppColors.info, 'Edit', () => _openDialog(a)),
                                                      const SizedBox(width: 6),
                                                      _actionButton(Icons.delete, AppColors.error, 'Delete', () => _delete(a)),
                                                    ],
                                                  ),
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
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Total Accounts: ${_appData.bankAccounts.length}  |  Filtered: ${_filtered.length}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      'Total Bank Balance: ${nf.format(totalBalance)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700),
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

  Widget _headerCell(String text, {required int flex, bool isNumeric = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
