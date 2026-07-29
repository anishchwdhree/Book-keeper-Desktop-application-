import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/customer_model.dart';
import '../utils/customer_statement_pdf.dart';

class CustomerLedgerScreen extends StatefulWidget {
  final CustomerModel customer;
  const CustomerLedgerScreen({super.key, required this.customer});

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  final _appData = AppData();
  late List<Map<String, dynamic>> _ledger;

  @override
  void initState() {
    super.initState();
    _buildDetailedLedger();
  }

  void _buildDetailedLedger() {
    _ledger = [];
    final customer = widget.customer;

    // Opening balance
    if (customer.openingBalance > 0) {
      _ledger.add({
        'date': DateTime(2020),
        'type': 'Opening Balance',
        'ref': '-',
        'product': '-',
        'qty': 0.0,
        'unit': '-',
        'rate': 0.0,
        'debit': customer.openingBalance,
        'credit': 0.0,
      });
    }

    // Sales (invoices) with item details
    for (var s in _appData.sales) {
      if (s.customerName == customer.name || s.customerId == customer.id) {
        String productNames;
        double totalQty;
        String unit;
        double avgRate;

        if (s.items.length == 1) {
          final item = s.items.first;
          productNames = item.product.name;
          totalQty = item.quantity;
          unit = item.unit;
          avgRate = item.unitPrice;
        } else if (s.items.isEmpty) {
          productNames = '-';
          totalQty = 0.0;
          unit = '-';
          avgRate = 0.0;
        } else {
          productNames = s.items.map((i) => i.product.name).join(', ');
          totalQty = s.items.fold(0.0, (sum, i) => sum + i.quantity);
          unit = s.items.first.unit;
          final totalRevenue = s.items.fold(0.0, (sum, i) => sum + i.unitPrice * i.quantity);
          avgRate = totalQty > 0 ? totalRevenue / totalQty : 0.0;
        }

        _ledger.add({
          'date': s.date,
          'type': 'Invoice',
          'ref': s.invoiceNumber,
          'product': productNames,
          'qty': totalQty,
          'unit': unit,
          'rate': avgRate,
          'debit': s.grandTotal,
          'credit': 0.0,
        });
      }
    }

    // Receipts
    for (var r in _appData.receipts) {
      if (r.customerId == customer.id) {
        _ledger.add({
          'date': r.date,
          'type': 'Receipt',
          'ref': r.receiptNumber,
          'product': '-',
          'qty': 0.0,
          'unit': '-',
          'rate': 0.0,
          'debit': 0.0,
          'credit': r.amount,
        });
      }
    }

    // Sales Returns
    for (var r in _appData.returns) {
      if (r.customerId == customer.id) {
        String productNames;
        double totalQty;
        String unit;
        double avgRate;

        if (r.items.length == 1) {
          final item = r.items.first;
          productNames = item.product.name;
          totalQty = item.quantity;
          unit = item.unit;
          avgRate = item.unitPrice;
        } else if (r.items.isEmpty) {
          productNames = '-';
          totalQty = 0.0;
          unit = '-';
          avgRate = 0.0;
        } else {
          productNames = r.items.map((i) => i.product.name).join(', ');
          totalQty = r.items.fold(0.0, (sum, i) => sum + i.quantity);
          unit = r.items.first.unit;
          final totalRevenue = r.items.fold(0.0, (sum, i) => sum + i.unitPrice * i.quantity);
          avgRate = totalQty > 0 ? totalRevenue / totalQty : 0.0;
        }

        _ledger.add({
          'date': r.date,
          'type': 'Sales Return',
          'ref': r.returnNumber,
          'product': productNames,
          'qty': totalQty,
          'unit': unit,
          'rate': avgRate,
          'debit': 0.0,
          'credit': r.grandTotal,
        });
      }
    }

    _ledger.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  void _printStatement() {
    CustomerStatementPdfGenerator.printStatement(
      context,
      widget.customer,
      _appData.settings,
      _ledger,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 1050,
        height: 660,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            // ── Title Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.tableHeaderBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Ledger: ${widget.customer.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _printStatement,
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print Statement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.tableHeaderBg,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            ),

            // ── Customer Info Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.cardBlue,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.customer.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        'Phone: ${widget.customer.phone.isEmpty ? "N/A" : widget.customer.phone}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Outstanding Balance', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${widget.customer.outstandingBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: widget.customer.outstandingBalance > 0 ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Ledger Table Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: const BoxDecoration(color: AppColors.tableHeaderBg),
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    _ledgerHeaderCell('Date', flex: 2),
                    _ledgerHeaderCell('Type', flex: 2),
                    _ledgerHeaderCell('Reference', flex: 2),
                    _ledgerHeaderCell('Product', flex: 3),
                    _ledgerHeaderCell('Qty', flex: 1, isNumeric: true),
                    _ledgerHeaderCell('Unit', flex: 1),
                    _ledgerHeaderCell('Rate', flex: 2, isNumeric: true),
                    _ledgerHeaderCell('Amount', flex: 2, isNumeric: true),
                    _ledgerHeaderCell('Balance', flex: 2, isNumeric: true),
                  ],
                ),
              ),
            ),

            // ── Ledger Data ──
            Expanded(
              child: ListenableBuilder(
                listenable: _appData,
                builder: (context, _) {
                  _buildDetailedLedger();

                  double totalSoldQty = 0;
                  double totalSalesAmount = 0;
                  for (var e in _ledger) {
                    if (e['type'] == 'Invoice') {
                      totalSoldQty += (e['qty'] as double);
                      totalSalesAmount += (e['debit'] as double);
                    }
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: _ledger.isEmpty
                            ? const Center(
                                child: Text('No transactions found', style: TextStyle(color: AppColors.textSecondary)),
                              )
                            : ListView.builder(
                                itemCount: _ledger.length,
                                itemBuilder: (ctx, index) {
                                  final item = _ledger[index];
                                  final debit = item['debit'] as double;
                                  final credit = item['credit'] as double;

                                  double runningBalance = 0;
                                  for (int i = 0; i <= index; i++) {
                                    runningBalance += (_ledger[i]['debit'] as double) - (_ledger[i]['credit'] as double);
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.white : const Color(0xFFF8F8F5),
                                      border: const Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.5)),
                                    ),
                                    child: SizedBox(
                                      height: 26,
                                      child: Row(
                                        children: [
                                          _ledgerDataCell(
                                            DateFormat('yyyy-MM-dd').format(item['date'] as DateTime),
                                            flex: 2,
                                          ),
                                          _ledgerDataCell(item['type'] as String, flex: 2),
                                          _ledgerDataCell(item['ref'] as String, flex: 2),
                                          _ledgerDataCell(item['product'] as String, flex: 3),
                                          _ledgerDataCell(
                                            (item['qty'] as double) > 0 ? (item['qty'] as double).toStringAsFixed(2) : '-',
                                            flex: 1, isNumeric: true,
                                          ),
                                          _ledgerDataCell(item['unit'] as String, flex: 1),
                                          _ledgerDataCell(
                                            (item['rate'] as double) > 0 ? (item['rate'] as double).toStringAsFixed(2) : '-',
                                            flex: 2, isNumeric: true,
                                          ),
                                          _ledgerDataCell(
                                            debit > 0 ? debit.toStringAsFixed(2) : credit > 0 ? credit.toStringAsFixed(2) : '',
                                            flex: 2,
                                            isNumeric: true,
                                            textColor: debit > 0 ? AppColors.error : credit > 0 ? AppColors.success : null,
                                          ),
                                          _ledgerDataCell(
                                            runningBalance.toStringAsFixed(2),
                                            flex: 2,
                                            isNumeric: true,
                                            bold: index == _ledger.length - 1,
                                            textColor: runningBalance > 0 ? AppColors.error : AppColors.success,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      // ── Summary bar ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: AppColors.cardBlue,
                        child: Row(
                          children: [
                            Text(
                              'Total Sales: Rs.${totalSalesAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Total Qty Sold: ${totalSoldQty.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const Spacer(),
                            Text(
                              'Transactions: ${_ledger.length}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Closing Balance Footer ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                color: AppColors.statusBarBg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Closing Balance: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(
                    'Rs. ${widget.customer.outstandingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.customer.outstandingBalance > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ledgerHeaderCell(String text, {required int flex, bool isNumeric = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          textAlign: isNumeric ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12, fontFamily: 'Segoe UI'),
        ),
      ),
    );
  }

  Widget _ledgerDataCell(
    String text, {
    required int flex,
    bool isNumeric = false,
    bool bold = false,
    Color? textColor,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Text(
          text,
          textAlign: isNumeric ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
