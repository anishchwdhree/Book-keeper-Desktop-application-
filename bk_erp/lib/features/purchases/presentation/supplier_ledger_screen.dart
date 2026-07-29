import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/supplier_model.dart';

class SupplierLedgerScreen extends StatefulWidget {
  final SupplierModel supplier;
  const SupplierLedgerScreen({super.key, required this.supplier});

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen> {
  final _appData = AppData();
  late List<Map<String, dynamic>> _ledger;

  @override
  void initState() {
    super.initState();
    _buildDetailedLedger();
  }

  void _buildDetailedLedger() {
    _ledger = [];
    final supplier = widget.supplier;

    // Opening balance
    if (supplier.openingBalance > 0) {
      _ledger.add({
        'date': DateTime(2020),
        'type': 'Opening Balance',
        'ref': '-',
        'product': '-',
        'qty': 0.0,
        'unit': '-',
        'rate': 0.0,
        'debit': 0.0,
        'credit': supplier.openingBalance,
      });
    }

    // Purchases with item details
    for (var p in _appData.purchases) {
      if (p.supplierId == supplier.id || p.supplierName == supplier.name) {
        String productNames;
        double totalQty;
        String unit;
        double avgRate;

        if (p.items.length == 1) {
          final item = p.items.first;
          productNames = item.product.name;
          totalQty = item.quantity;
          unit = item.unit;
          avgRate = item.unitCost;
        } else if (p.items.isEmpty) {
          productNames = '-';
          totalQty = 0.0;
          unit = '-';
          avgRate = 0.0;
        } else {
          productNames = p.items.map((i) => i.product.name).join(', ');
          totalQty = p.items.fold(0.0, (sum, i) => sum + i.quantity);
          unit = p.items.first.unit;
          final totalCost = p.items.fold(
            0.0,
            (sum, i) => sum + i.unitCost * i.quantity,
          );
          avgRate = totalQty > 0 ? totalCost / totalQty : 0.0;
        }

        _ledger.add({
          'date': p.date,
          'type': 'Purchase',
          'ref': p.invoiceNumber,
          'product': productNames,
          'qty': totalQty,
          'unit': unit,
          'rate': avgRate,
          'debit': 0.0,
          'credit': p.grandTotal,
        });
      }
    }

    // Payments
    for (var p in _appData.payments) {
      if (p.supplierId == supplier.id) {
        _ledger.add({
          'date': p.date,
          'type': 'Payment',
          'ref': p.paymentNumber,
          'product': '-',
          'qty': 0.0,
          'unit': '-',
          'rate': 0.0,
          'debit': p.amount,
          'credit': 0.0,
        });
      }
    }

    // Purchase Returns
    for (var r in _appData.purchaseReturns) {
      if (r.supplierId == supplier.id) {
        String productNames;
        double totalQty;
        String unit;
        double avgRate;

        if (r.items.length == 1) {
          final item = r.items.first;
          productNames = item.product.name;
          totalQty = item.quantity;
          unit = item.unit;
          avgRate = item.unitCost;
        } else if (r.items.isEmpty) {
          productNames = '-';
          totalQty = 0.0;
          unit = '-';
          avgRate = 0.0;
        } else {
          productNames = r.items.map((i) => i.product.name).join(', ');
          totalQty = r.items.fold(0.0, (sum, i) => sum + i.quantity);
          unit = r.items.first.unit;
          final totalCost = r.items.fold(
            0.0,
            (sum, i) => sum + i.unitCost * i.quantity,
          );
          avgRate = totalQty > 0 ? totalCost / totalQty : 0.0;
        }

        _ledger.add({
          'date': r.date,
          'type': 'Purchase Return',
          'ref': r.returnNumber,
          'product': productNames,
          'qty': totalQty,
          'unit': unit,
          'rate': avgRate,
          'debit': r.grandTotal,
          'credit': 0.0,
        });
      }
    }

    _ledger.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: 1000,
        height: 640,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: ListenableBuilder(
          listenable: _appData,
          builder: (context, _) {
            _buildDetailedLedger();

            double totalPurchasedQty = 0;
            double totalPurchaseAmount = 0;
            for (var e in _ledger) {
              if (e['type'] == 'Purchase') {
                totalPurchasedQty += (e['qty'] as double);
                totalPurchaseAmount += (e['credit'] as double);
              }
            }

            return Column(
              children: [
                // ── Title bar (blue) ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  color: AppColors.tableHeaderBg,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.library_books,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Supplier Ledger: ${widget.supplier.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.supplier.outstandingBalance > 0
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.success.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'Balance: Rs.${widget.supplier.outstandingBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Supplier info bar ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  color: AppColors.statusBarBg,
                  child: Row(
                    children: [
                      if (widget.supplier.phone.isNotEmpty) ...[
                        _infoChip(Icons.phone, widget.supplier.phone),
                        const SizedBox(width: 12),
                      ],
                      if (widget.supplier.address.isNotEmpty) ...[
                        _infoChip(Icons.location_on, widget.supplier.address),
                        const SizedBox(width: 12),
                      ],
                      if (widget.supplier.rateType.isNotEmpty) ...[
                        _infoChip(Icons.category, widget.supplier.rateType),
                        const SizedBox(width: 12),
                      ],
                      if (widget.supplier.safeBankName.isNotEmpty) ...[
                        _infoChip(
                          Icons.account_balance,
                          '${widget.supplier.safeBankName}${widget.supplier.safeAccountNumber.isNotEmpty ? " (${widget.supplier.safeAccountNumber})" : ""}',
                        ),
                      ],
                    ],
                  ),
                ),
                // ── Table header ──
                Container(
                  color: AppColors.tableHeaderBg,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                  child: Row(
                    children: [
                      _headerCell('Date', flex: 2),
                      _headerCell('Type', flex: 2),
                      _headerCell('Reference', flex: 2),
                      _headerCell('Product', flex: 3),
                      _headerCell('Qty', flex: 1, isNumeric: true),
                      _headerCell('Unit', flex: 1),
                      _headerCell('Rate', flex: 2, isNumeric: true),
                      _headerCell('Amount', flex: 2, isNumeric: true),
                      _headerCell('Balance', flex: 2, isNumeric: true),
                    ],
                  ),
                ),
                // ── Ledger rows ──
                Expanded(
                  child: _ledger.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _ledger.length,
                          itemBuilder: (context, index) {
                            final item = _ledger[index];
                            final debit = item['debit'] as double;
                            final credit = item['credit'] as double;

                            double runningBalance = 0;
                            for (int i = 0; i <= index; i++) {
                              runningBalance +=
                                  (_ledger[i]['credit'] as double) -
                                  (_ledger[i]['debit'] as double);
                            }

                            final isLast = index == _ledger.length - 1;

                            return Container(
                              color: index.isEven
                                  ? AppColors.surface
                                  : const Color(0xFFF5F5F0),
                              height: 26,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                children: [
                                  _dataCell(
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(item['date'] as DateTime),
                                    flex: 2,
                                  ),
                                  _dataCell(item['type'] as String, flex: 2),
                                  _dataCell(item['ref'] as String, flex: 2),
                                  _dataCell(item['product'] as String, flex: 3),
                                  _dataCell(
                                    (item['qty'] as double) > 0
                                        ? (item['qty'] as double)
                                              .toStringAsFixed(2)
                                        : '-',
                                    flex: 1,
                                    isNumeric: true,
                                  ),
                                  _dataCell(item['unit'] as String, flex: 1),
                                  _dataCell(
                                    (item['rate'] as double) > 0
                                        ? (item['rate'] as double)
                                              .toStringAsFixed(2)
                                        : '-',
                                    flex: 2,
                                    isNumeric: true,
                                  ),
                                  _dataCell(
                                    debit > 0
                                        ? debit.toStringAsFixed(2)
                                        : credit > 0
                                        ? credit.toStringAsFixed(2)
                                        : '',
                                    flex: 2,
                                    isNumeric: true,
                                    textColor: credit > 0
                                        ? AppColors.error
                                        : debit > 0
                                        ? AppColors.success
                                        : null,
                                  ),
                                  _dataCell(
                                    runningBalance.toStringAsFixed(2),
                                    flex: 2,
                                    isNumeric: true,
                                    isBold: isLast,
                                    textColor: isLast
                                        ? (runningBalance > 0
                                              ? AppColors.error
                                              : AppColors.success)
                                        : AppColors.textPrimary,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // ── Summary bar ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  color: AppColors.cardBlue,
                  child: Row(
                    children: [
                      Text(
                        'Total Purchases: Rs.${totalPurchaseAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Total Qty Bought: ${totalPurchasedQty.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Transactions: ${_ledger.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Footer status bar ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.surfaceBorder),
                    ),
                    color: AppColors.statusBarBg,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Closing Balance: Rs.${widget.supplier.outstandingBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.supplier.outstandingBalance > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _headerCell(String text, {required int flex, bool isNumeric = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _dataCell(
    String text, {
    required int flex,
    bool isNumeric = false,
    bool isBold = false,
    Color? textColor,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
