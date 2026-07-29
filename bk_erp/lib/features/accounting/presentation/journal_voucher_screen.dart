import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/journal_entry_model.dart';

class JournalVoucherScreen extends StatefulWidget {
  const JournalVoucherScreen({super.key});

  @override
  State<JournalVoucherScreen> createState() => _JournalVoucherScreenState();
}

class _JournalVoucherScreenState extends State<JournalVoucherScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<JournalEntryModel> get _filtered {
    var list = _appData.journalEntries.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) => e.journalNumber.toLowerCase().contains(q) || e.narration.toLowerCase().contains(q) || e.debitAccount.toLowerCase().contains(q) || e.creditAccount.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _createJournal() {
    final debitCtrl = TextEditingController();
    final creditCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final narrationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('New Journal Voucher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Debit Account (Dr)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(controller: debitCtrl, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: 'e.g. Purchase Account', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
                  const SizedBox(height: 12),
                  const Text('Credit Account (Cr)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(controller: creditCtrl, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: 'e.g. Cash Account', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
                  const SizedBox(height: 12),
                  const Text('Amount (Rs)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: '0.00', prefixText: 'Rs. ', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
                  const SizedBox(height: 12),
                  const Text('Narration', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(controller: narrationCtrl, maxLines: 2, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: 'Description', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0 || debitCtrl.text.isEmpty || creditCtrl.text.isEmpty) return;
                _appData.addJournalEntry(JournalEntryModel(
                  journalNumber: _appData.nextJournalNumber,
                  date: DateTime.now(),
                  debitAccount: debitCtrl.text.trim(),
                  creditAccount: creditCtrl.text.trim(),
                  amount: amount,
                  narration: narrationCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Save Voucher'),
            ),
          ],
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
        return Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.tableHeaderBg,
                child: const Row(
                  children: [
                    Icon(Icons.book, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Journal Vouchers', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(bottom: BorderSide(color: AppColors.surfaceBorder))),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search journal vouchers...',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF666600)),
                            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF666600)),
                            prefixIconConstraints: const BoxConstraints(minWidth: 36),
                            fillColor: AppColors.searchBg,
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.surfaceBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.surfaceBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _createJournal,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Journal', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: AppColors.tableHeaderBg,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            _hdr('JV #', flex: 2),
                            _hdr('Date', flex: 2),
                            _hdr('Debit Account', flex: 3),
                            _hdr('Credit Account', flex: 3),
                            _hdr('Amount', flex: 2, numeric: true),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      Expanded(
                        child: displayed.isEmpty
                            ? const Center(child: Text('No journal vouchers yet.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                            : ListView.separated(
                                itemCount: displayed.length,
                                separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.surfaceBorder),
                                itemBuilder: (context, index) {
                                  final e = displayed[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        _cell(e.journalNumber, flex: 2, bold: true),
                                        _cell(DateFormat('MMM dd, yyyy').format(e.date), flex: 2),
                                        _cell(e.debitAccount, flex: 3),
                                        _cell(e.creditAccount, flex: 3),
                                        _cell('Rs.${e.amount.toStringAsFixed(2)}', flex: 2, numeric: true, color: AppColors.primary, bold: true),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
                child: Text(
                  'Total Vouchers: ${_appData.journalEntries.length}  |  Filtered: ${displayed.length}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hdr(String t, {required int flex, bool numeric = false}) => Expanded(flex: flex, child: Text(t, textAlign: numeric ? TextAlign.right : TextAlign.left, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText, fontSize: 12)));
  Widget _cell(String t, {required int flex, bool numeric = false, bool bold = false, Color? color}) => Expanded(flex: flex, child: Text(t, textAlign: numeric ? TextAlign.right : TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: color ?? AppColors.textPrimary)));
}
