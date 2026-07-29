import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';

class TransactionItem {
  final DateTime date;
  final String type;
  final String ref;
  final String contact;
  final double amountIn;
  final double amountOut;

  TransactionItem(this.date, this.type, this.ref, this.contact, this.amountIn, this.amountOut);
}

class DayBookScreen extends StatefulWidget {
  const DayBookScreen({super.key});

  @override
  State<DayBookScreen> createState() => _DayBookScreenState();
}

class _DayBookScreenState extends State<DayBookScreen> {
  final AppData _appData = AppData();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<TransactionItem> get _transactions {
    List<TransactionItem> items = [];

    for (var s in _appData.sales) {
      if (s.paymentMethod != 'Credit') {
        items.add(TransactionItem(s.date, 'Cash Sale', s.invoiceNumber, s.customerName, s.grandTotal, 0));
      } else {
        items.add(TransactionItem(s.date, 'Credit Sale', s.invoiceNumber, s.customerName, 0, 0));
      }
    }
    for (var p in _appData.purchases) {
      items.add(TransactionItem(p.date, 'Purchase', p.invoiceNumber, p.supplierName, 0, p.grandTotal));
    }
    for (var r in _appData.receipts) {
      items.add(TransactionItem(r.date, 'Receipt', r.receiptNumber, r.customerName, r.amount, 0));
    }
    for (var p in _appData.payments) {
      items.add(TransactionItem(p.date, 'Payment', p.paymentNumber, p.supplierName, 0, p.amount));
    }
    for (var e in _appData.expenses) {
      items.add(TransactionItem(e.date, 'Expense', e.expenseNumber, e.category, 0, e.amount));
    }

    items = items.where((i) {
      final d = DateTime(i.date.year, i.date.month, i.date.day);
      final s = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final e = DateTime(_endDate.year, _endDate.month, _endDate.day);
      return d.isAfter(s.subtract(const Duration(days: 1))) && d.isBefore(e.add(const Duration(days: 1)));
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) => i.contact.toLowerCase().contains(q) || i.ref.toLowerCase().contains(q) || i.type.toLowerCase().contains(q)).toList();
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _exportCsv() {
    final filtered = _transactions;
    final buffer = StringBuffer();
    buffer.writeln('Date,Type,Reference,Contact,Money In,Money Out');
    for (var tx in filtered) {
      buffer.writeln('${DateFormat('yyyy-MM-dd HH:mm').format(tx.date)},${tx.type},${tx.ref},${tx.contact},${tx.amountIn.toStringAsFixed(2)},${tx.amountOut.toStringAsFixed(2)}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV data copied to clipboard!')));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _transactions;
    final totalIn = filtered.fold(0.0, (sum, i) => sum + i.amountIn);
    final totalOut = filtered.fold(0.0, (sum, i) => sum + i.amountOut);

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.tableHeaderBg,
            child: Row(
              children: [
                const Icon(Icons.book, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Day Book', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                const Spacer(),
                Text(
                  '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
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
                        hintText: 'Search by reference, contact, type...',
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
                SizedBox(
                  height: 30,
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range, size: 14),
                    label: const Text('Date Range', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 30,
                  child: OutlinedButton.icon(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.file_download, size: 14),
                    label: const Text('CSV', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
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
                        _hdr('Date', flex: 2),
                        _hdr('Type', flex: 2),
                        _hdr('Ref. No.', flex: 2),
                        _hdr('Account / Contact', flex: 3),
                        _hdr('Money In (Rs)', flex: 2, numeric: true),
                        _hdr('Money Out (Rs)', flex: 2, numeric: true),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No transactions found in this period.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.surfaceBorder),
                            itemBuilder: (context, index) {
                              final tx = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                child: Row(
                                  children: [
                                    _cell(DateFormat('MMM d, yyyy').format(tx.date), flex: 2),
                                    _cell(tx.type, flex: 2, bold: true),
                                    _cell(tx.ref, flex: 2, color: AppColors.primary),
                                    _cell(tx.contact, flex: 3),
                                    _cell(tx.amountIn > 0 ? tx.amountIn.toStringAsFixed(2) : '-', flex: 2, numeric: true, color: tx.amountIn > 0 ? AppColors.success : AppColors.textHint, bold: tx.amountIn > 0),
                                    _cell(tx.amountOut > 0 ? tx.amountOut.toStringAsFixed(2) : '-', flex: 2, numeric: true, color: tx.amountOut > 0 ? AppColors.error : AppColors.textHint, bold: tx.amountOut > 0),
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
            child: Row(
              children: [
                Text('Records: ${filtered.length}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('In: Rs.${totalIn.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                const SizedBox(width: 16),
                Text('Out: Rs.${totalOut.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hdr(String t, {required int flex, bool numeric = false}) => Expanded(flex: flex, child: Text(t, textAlign: numeric ? TextAlign.right : TextAlign.left, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText, fontSize: 12)));
  Widget _cell(String t, {required int flex, bool numeric = false, bool bold = false, Color? color}) => Expanded(flex: flex, child: Text(t, textAlign: numeric ? TextAlign.right : TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: color ?? AppColors.textPrimary)));
}
