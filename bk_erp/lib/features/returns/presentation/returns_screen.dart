import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/return_model.dart';
import 'package:printing/printing.dart';
import '../utils/credit_note_pdf_generator.dart';
import 'create_return_dialog.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<ReturnModel> get _filtered {
    if (_searchQuery.isEmpty) return _appData.returns;
    final q = _searchQuery.toLowerCase();
    return _appData.returns.where((r) =>
      r.returnNumber.toLowerCase().contains(q) ||
      r.customerName.toLowerCase().contains(q) ||
      r.originalInvoiceNumber.toLowerCase().contains(q)
    ).toList();
  }

  void _createNewReturn() async {
    final result = await showDialog<ReturnModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateReturnDialog(),
    );
    if (result != null) {
      setState(() => _appData.addReturn(result));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Return ${result.returnNumber} processed. Stock restored.')),
        );
      }
    }
  }

  Future<void> _printReturn(ReturnModel r) async {
    final pdfBytes = await CreditNotePdfGenerator.generate(r);
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes, name: 'CreditNote_${r.returnNumber}');
  }

  static const _borderSide = BorderSide(color: Color(0xFFD0D0D0), width: 0.5);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final displayed = _filtered.reversed.toList();
        final totalRefund = displayed.fold(0.0, (sum, r) => sum + r.grandTotal);

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
                    const Icon(Icons.assignment_return, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Text('Sales Returns (Credit Notes)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const Spacer(),
                    Text('Total Refund: Rs.${totalRefund.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: _createNewReturn,
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text('New Return', style: TextStyle(fontSize: 12)),
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
                          hintText: 'Search by return #, customer, invoice #...',
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
                    Text('Showing ${displayed.length} of ${_appData.returns.length}',
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
                    _excelHeader('Return #', 120),
                    _excelHeader('Date', 110),
                    _excelHeader('Customer', 200),
                    _excelHeader('Orig Inv #', 120),
                    _excelHeader('Refund (Rs)', 120, isNum: true),
                    _excelHeader('Actions', 60, isNum: true),
                  ],
                ),
              ),

              // ── Excel Rows ──
              Expanded(
                child: displayed.isEmpty
                    ? _buildEmpty('No returns processed yet', Icons.inbox_outlined, _createNewReturn, 'Create First Return')
                    : ListView.builder(
                        itemCount: displayed.length,
                        itemBuilder: (ctx, i) {
                          final r = displayed[i];
                          return Container(
                            height: 30,
                            color: i.isEven ? Colors.white : const Color(0xFFF5F5F0),
                            child: Row(
                              children: [
                                _excelCell('${i + 1}', 50, isNum: true, textColor: AppColors.textHint),
                                _excelCell(r.returnNumber, 120, isBold: true, textColor: AppColors.primary),
                                _excelCell(DateFormat('yyyy-MM-dd').format(r.date), 110),
                                _excelCell(r.customerName, 200),
                                _excelCell(r.originalInvoiceNumber, 120, textColor: AppColors.secondary),
                                _excelCell('Rs.${r.grandTotal.toStringAsFixed(0)}', 120, isNum: true, isBold: true, textColor: AppColors.error),
                                SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () => _printReturn(r),
                                      child: const Icon(Icons.print, size: 13, color: AppColors.primary),
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
                  'Returns: ${_appData.returns.length}  |  Total Refund: Rs.${totalRefund.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

  Widget _excelHeader(String text, double width, {bool isNum = false}) {
    return Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _borderSide, bottom: _borderSide)),
      child: Align(
        alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF333333)), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _excelCell(String text, double width, {bool isNum = false, bool isBold = false, Color? textColor}) {
    return Container(
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
  }
}
