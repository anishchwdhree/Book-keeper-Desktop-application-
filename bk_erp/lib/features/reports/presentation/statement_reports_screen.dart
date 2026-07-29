import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/nepali_date.dart';
import '../utils/statement_pdf_generator.dart';

class StatementReportsScreen extends StatefulWidget {
  const StatementReportsScreen({super.key});

  @override
  State<StatementReportsScreen> createState() => _StatementReportsScreenState();
}

class _StatementReportsScreenState extends State<StatementReportsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _appData = AppData();
  DateTime? _fromDate;
  DateTime? _toDate;

  static const _gridBorder = BorderSide(color: Color(0xFFD5D8DF), width: 0.6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _appData.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appData.removeListener(_onStateChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _pickDate(bool isFrom) async {
    final currentBs = isFrom
        ? (_fromDate != null ? NepaliDate.fromDateTime(_fromDate!) : NepaliDate.today())
        : (_toDate != null ? NepaliDate.fromDateTime(_toDate!) : NepaliDate.today());

    int selYear = currentBs.year;
    int selMonth = currentBs.month;
    int selDay = currentBs.day;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            final maxDay = NepaliDate.bsDaysInMonth(selYear, selMonth);
            if (selDay > maxDay) selDay = maxDay;
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: AppColors.tableHeaderBg,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            isFrom ? 'Select Start Date (BS)' : 'Select End Date (BS)',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            child: const Icon(Icons.close, color: Colors.white70, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Year
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Year (BS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.surfaceBorder),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButton<int>(
                                  value: selYear,
                                  isDense: true,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  items: List.generate(21, (i) => 2070 + i).map((y) =>
                                    DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontSize: 13)))
                                  ).toList(),
                                  onChanged: (v) { if (v != null) setDlgState(() => selYear = v); },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Month
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.surfaceBorder),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButton<int>(
                                  value: selMonth,
                                  isDense: true,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  items: List.generate(12, (i) => i + 1).map((m) =>
                                    DropdownMenuItem(value: m, child: Text('$m - ${NepaliDate.monthNames[m - 1]}', style: const TextStyle(fontSize: 12)))
                                  ).toList(),
                                  onChanged: (v) { if (v != null) setDlgState(() => selMonth = v); },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Day
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.surfaceBorder),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButton<int>(
                                  value: selDay,
                                  isDense: true,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  items: List.generate(maxDay, (i) => i + 1).map((d) =>
                                    DropdownMenuItem(value: d, child: Text('$d', style: const TextStyle(fontSize: 13)))
                                  ).toList(),
                                  onChanged: (v) { if (v != null) setDlgState(() => selDay = v); },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        border: Border.all(color: AppColors.primary.withAlpha(60)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'Selected: $selYear/${selMonth.toString().padLeft(2, '0')}/${selDay.toString().padLeft(2, '0')} (${NepaliDate.monthNames[selMonth - 1]})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
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
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final bsDate = NepaliDate(selYear, selMonth, selDay);
                              Navigator.of(ctx).pop(bsDate.toDateTime());
                            },
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Select', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromDate = result;
        } else {
          _toDate = result;
        }
      });
    }
  }

  void _clearDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _downloadPdf(StatementType type, String title, Map<String, dynamic> data) async {
    final headers = (data['headers'] as List).cast<Map<String, String>>();
    final rows = (data['rows'] as List).cast<Map<String, String>>();
    final summary = (data['summary'] as Map<String, String>);
    await StatementPdfGenerator.printStatement(type, title, rows, headers, summary, _fromDate, _toDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEBE4),
      body: Column(
        children: [
          _buildHeader(),
          _buildDateFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesTab(),
                _buildSupplierTab(),
                _buildPurchaseTab(),
                _buildSoldOutTab(),
              ],
            ),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(Icons.description_rounded, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statement Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('View & Download Sales, Supplier, Purchase and Sold Out Statements', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(icon: Icon(Icons.receipt_long, size: 16), text: 'Sales Statement'),
              Tab(icon: Icon(Icons.business, size: 16), text: 'Supplier Statement'),
              Tab(icon: Icon(Icons.local_mall, size: 16), text: 'Purchase Statement'),
              Tab(icon: Icon(Icons.inventory, size: 16), text: 'Sold Out Statement'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFFF4F4EE),
      child: Row(
        children: [
          const Icon(Icons.date_range, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          const Text('From:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          _dateButton(_fromDate != null ? NepaliDate.fromDateTime(_fromDate!).format() : 'Start Date (BS)', true),
          const SizedBox(width: 10),
          const Text('To:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          _dateButton(_toDate != null ? NepaliDate.fromDateTime(_toDate!).format() : 'End Date (BS)', false),
          if (_fromDate != null || _toDate != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: _clearDates,
              tooltip: 'Clear dates',
            ),
          ],
          const Spacer(),
          _buildDownloadButton(),
          const SizedBox(width: 8),
          _buildSummaryChip(),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    final labels = ['Sales Statement', 'Supplier Statement', 'Purchase Statement', 'Sold Out Statement'];
    final types = StatementType.values;
    return SizedBox(
      height: 30,
      child: ElevatedButton.icon(
        onPressed: () {
          final idx = _tabController.index;
          final title = labels[idx];
          final type = types[idx];
          Map<String, dynamic> data;
          switch (type) {
            case StatementType.sales:
              data = StatementPdfGenerator.buildSalesData(_appData.sales, _fromDate, _toDate);
              break;
            case StatementType.supplier:
              data = StatementPdfGenerator.buildSupplierData(_appData.purchases, _fromDate, _toDate);
              break;
            case StatementType.purchase:
              data = StatementPdfGenerator.buildPurchaseSummaryData(_appData.purchases, _fromDate, _toDate);
              break;
            case StatementType.soldOut:
              data = StatementPdfGenerator.buildSoldOutData(_appData.sales, _fromDate, _toDate);
              break;
          }
          _downloadPdf(type, title, data);
        },
        icon: const Icon(Icons.download, size: 14),
        label: const Text('Download PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _buildSummaryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5D8DF)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'Sales: ${_appData.sales.length}  |  Purchases: ${_appData.purchases.length}',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _dateButton(String text, bool isFrom) {
    return InkWell(
      onTap: () => _pickDate(isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFF00).withAlpha(40),
          border: Border.all(color: const Color(0xFFD5D8DF)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(text, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFD5D8DF),
      child: const Row(
        children: [
          Icon(Icons.table_chart, size: 14, color: AppColors.primary),
          SizedBox(width: 6),
          Text('Ready  |  Statement Reports Sheet Mode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Spacer(),
          Text('BK ERP Sheet Engine', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TAB 1: Sales Statement
  // ═══════════════════════════════════════════
  Widget _buildSalesTab() {
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_US');
    final data = StatementPdfGenerator.buildSalesData(_appData.sales, _fromDate, _toDate);
    final rows = (data['rows'] as List<Map<String, String>>);
    final summary = data['summary'] as Map<String, String>;

    final totalSales = _appData.sales.where((s) {
      if (_fromDate != null && s.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && s.date.isAfter(_toDate!.add(const Duration(days: 1)))) return false;
      return true;
    }).fold(0.0, (sum, s) => sum + s.grandTotal);

    final totalPaid = _appData.sales.where((s) {
      if (_fromDate != null && s.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && s.date.isAfter(_toDate!.add(const Duration(days: 1)))) return false;
      return true;
    }).fold(0.0, (sum, s) => sum + s.paidAmount);

    final totalBalance = totalSales - totalPaid;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppColors.surface,
          child: Row(
            children: [
              _kpiCard('TOTAL SALES', 'Rs. ${currencyFmt.format(totalSales)}', Icons.receipt_long, Colors.blue.shade700),
              const SizedBox(width: 10),
              _kpiCard('TOTAL PAID', 'Rs. ${currencyFmt.format(totalPaid)}', Icons.check_circle, Colors.green.shade700),
              const SizedBox(width: 10),
              _kpiCard('OUTSTANDING', 'Rs. ${currencyFmt.format(totalBalance)}', Icons.pending, Colors.orange.shade800),
              const SizedBox(width: 10),
              _kpiCard('INVOICES', '${rows.length}', Icons.receipt, AppColors.primary),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 1280.0;
              final gridWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
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
                          gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                        ),
                        child: Row(
                          children: [
                            _excelHeader('S.NO', 45),
                            _excelHeader('DATE', 90),
                            _excelHeader('INVOICE #', 110),
                            _excelHeader('CUSTOMER', 160),
                            _excelHeader('ITEMS', 220),
                            _excelHeader('QTY', 70, isNum: true),
                            _excelHeader('TOTAL (RS)', 110, isNum: true),
                            _excelHeader('PAID (RS)', 100, isNum: true),
                            _excelHeader('BALANCE (RS)', 110, isNum: true),
                            _excelHeader('STATUS', 90, isCenter: true),
                          ],
                        ),
                      ),
                      Expanded(
                        child: rows.isEmpty
                            ? _buildEmptyState('No sales found for the selected date range.')
                            : ListView.builder(
                                itemCount: rows.length,
                                itemBuilder: (context, index) {
                                  final row = rows[index];
                                  return Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                      border: const Border(bottom: _gridBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        _excelCell('${index + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                        _excelCell(row['date'] ?? '', 90),
                                        _excelCell(row['invoice'] ?? '', 110, isBold: true, textColor: AppColors.success),
                                        _excelCell(row['customer'] ?? '', 160, isBold: true),
                                        _excelCell(row['items'] ?? '', 220),
                                        _excelCell(row['qty'] ?? '', 70, isNum: true),
                                        _excelCell(row['total'] ?? '', 110, isNum: true, isBold: true),
                                        _excelCell(row['paid'] ?? '', 100, isNum: true, textColor: Colors.blue.shade700),
                                        _excelCellBalance(row['balance'] ?? '', 110),
                                        _excelCellStatus(row['status'] ?? '', 90),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (rows.isNotEmpty)
                        _buildFooterRow(
                          'TOTALS (${rows.length} Invoices)',
                          [120, 220, 70, 110, 100, 110, 90],
                          [
                            summary['Total Quantity'] ?? '0',
                            summary['Total Sales'] ?? 'Rs. 0',
                            summary['Total Paid'] ?? 'Rs. 0',
                            summary['Total Outstanding'] ?? 'Rs. 0',
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // TAB 2: Supplier Statement
  // ═══════════════════════════════════════════
  Widget _buildSupplierTab() {
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_US');
    final data = StatementPdfGenerator.buildSupplierData(_appData.purchases, _fromDate, _toDate);
    final rows = (data['rows'] as List<Map<String, String>>);
    final summary = data['summary'] as Map<String, String>;

    final filtered = _appData.purchases.where((p) {
      if (_fromDate != null && p.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && p.date.isAfter(_toDate!.add(const Duration(days: 1)))) return false;
      return true;
    });

    final totalPurchases = filtered.fold(0.0, (sum, p) => sum + p.grandTotal);
    final totalPaid = filtered.fold(0.0, (sum, p) => sum + p.paidAmount);
    final totalBalance = totalPurchases - totalPaid;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppColors.surface,
          child: Row(
            children: [
              _kpiCard('TOTAL PURCHASES', 'Rs. ${currencyFmt.format(totalPurchases)}', Icons.local_mall, Colors.blue.shade700),
              const SizedBox(width: 10),
              _kpiCard('TOTAL PAID', 'Rs. ${currencyFmt.format(totalPaid)}', Icons.check_circle, Colors.green.shade700),
              const SizedBox(width: 10),
              _kpiCard('OUTSTANDING', 'Rs. ${currencyFmt.format(totalBalance)}', Icons.pending, Colors.red.shade700),
              const SizedBox(width: 10),
              _kpiCard('BILLS', '${rows.length}', Icons.receipt, AppColors.primary),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 1280.0;
              final gridWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
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
                          gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                        ),
                        child: Row(
                          children: [
                            _excelHeader('S.NO', 45),
                            _excelHeader('DATE', 90),
                            _excelHeader('BILL #', 110),
                            _excelHeader('SUPPLIER', 160),
                            _excelHeader('ITEMS', 220),
                            _excelHeader('QTY', 70, isNum: true),
                            _excelHeader('TOTAL (RS)', 110, isNum: true),
                            _excelHeader('PAID (RS)', 100, isNum: true),
                            _excelHeader('BALANCE (RS)', 110, isNum: true),
                            _excelHeader('PAYMENT', 90, isCenter: true),
                          ],
                        ),
                      ),
                      Expanded(
                        child: rows.isEmpty
                            ? _buildEmptyState('No purchases found for the selected date range.')
                            : ListView.builder(
                                itemCount: rows.length,
                                itemBuilder: (context, index) {
                                  final row = rows[index];
                                  return Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                      border: const Border(bottom: _gridBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        _excelCell('${index + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                        _excelCell(row['date'] ?? '', 90),
                                        _excelCell(row['bill'] ?? '', 110, isBold: true, textColor: AppColors.primary),
                                        _excelCell(row['supplier'] ?? '', 160, isBold: true),
                                        _excelCell(row['items'] ?? '', 220),
                                        _excelCell(row['qty'] ?? '', 70, isNum: true),
                                        _excelCell(row['total'] ?? '', 110, isNum: true, isBold: true),
                                        _excelCell(row['paid'] ?? '', 100, isNum: true, textColor: Colors.green.shade700),
                                        _excelCellBalance(row['balance'] ?? '', 110),
                                        _excelCellStatus(row['method'] ?? '', 90),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (rows.isNotEmpty)
                        _buildFooterRow(
                          'TOTALS (${rows.length} Bills)',
                          [120, 220, 70, 110, 100, 110, 90],
                          [
                            summary['Total Quantity'] ?? '0',
                            summary['Total Purchases'] ?? 'Rs. 0',
                            summary['Total Paid'] ?? 'Rs. 0',
                            summary['Total Outstanding'] ?? 'Rs. 0',
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // TAB 3: Purchase Summary (by Supplier)
  // ═══════════════════════════════════════════
  Widget _buildPurchaseTab() {
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_US');
    final data = StatementPdfGenerator.buildPurchaseSummaryData(_appData.purchases, _fromDate, _toDate);
    final rows = (data['rows'] as List<Map<String, String>>);
    final summary = data['summary'] as Map<String, String>;

    final filtered = _appData.purchases.where((p) {
      if (_fromDate != null && p.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && p.date.isAfter(_toDate!.add(const Duration(days: 1)))) return false;
      return true;
    });

    final grandTotal = filtered.fold(0.0, (sum, p) => sum + p.grandTotal);
    final grandPaid = filtered.fold(0.0, (sum, p) => sum + p.paidAmount);
    final grandBalance = grandTotal - grandPaid;
    final supplierCount = filtered.map((p) => p.supplierName).toSet().length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppColors.surface,
          child: Row(
            children: [
              _kpiCard('GRAND TOTAL PURCHASED', 'Rs. ${currencyFmt.format(grandTotal)}', Icons.shopping_cart, Colors.blue.shade700),
              const SizedBox(width: 10),
              _kpiCard('TOTAL PAID', 'Rs. ${currencyFmt.format(grandPaid)}', Icons.check_circle, Colors.green.shade700),
              const SizedBox(width: 10),
              _kpiCard('TOTAL OUTSTANDING', 'Rs. ${currencyFmt.format(grandBalance)}', Icons.pending, Colors.red.shade700),
              const SizedBox(width: 10),
              _kpiCard('SUPPLIERS', '$supplierCount', Icons.business, AppColors.primary),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 1050.0;
              final gridWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
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
                          gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                        ),
                        child: Row(
                          children: [
                            _excelHeader('S.NO', 45),
                            _excelHeader('SUPPLIER NAME', 180),
                            _excelHeader('TOTAL BILLS', 90, isNum: true),
                            _excelHeader('TOTAL QTY', 90, isNum: true),
                            _excelHeader('TOTAL PURCHASED (RS)', 140, isNum: true),
                            _excelHeader('TOTAL PAID (RS)', 120, isNum: true),
                            _excelHeader('OUTSTANDING (RS)', 130, isNum: true),
                            _excelHeader('LAST PURCHASE', 100),
                          ],
                        ),
                      ),
                      Expanded(
                        child: rows.isEmpty
                            ? _buildEmptyState('No supplier data found for the selected date range.')
                            : ListView.builder(
                                itemCount: rows.length,
                                itemBuilder: (context, index) {
                                  final row = rows[index];
                                  return Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                      border: const Border(bottom: _gridBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        _excelCell('${index + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                        _excelCell(row['supplier'] ?? '', 180, isBold: true),
                                        _excelCell(row['bills'] ?? '', 90, isNum: true),
                                        _excelCell(row['qty'] ?? '', 90, isNum: true),
                                        _excelCell(row['total'] ?? '', 140, isNum: true, isBold: true),
                                        _excelCell(row['paid'] ?? '', 120, isNum: true, textColor: Colors.green.shade700),
                                        _excelCellBalance(row['balance'] ?? '', 130),
                                        _excelCell(row['lastDate'] ?? '', 100),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (rows.isNotEmpty)
                        Container(
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            border: Border(top: BorderSide(color: Color(0xFFCBD5E1), width: 1.5), bottom: BorderSide(color: Color(0xFF94A3B8), width: 1.5)),
                          ),
                          child: Row(
                            children: [
                              _excelCell('TOTALS (${summary['Total Suppliers']} Suppliers, ${summary['Total Bills']} Bills)', 45 + 180 + 90 + 90, isBold: true),
                              _excelCell(summary['Grand Total Purchased'] ?? 'Rs. 0', 140, isNum: true, isBold: true),
                              _excelCell(summary['Grand Total Paid'] ?? 'Rs. 0', 120, isNum: true, isBold: true, textColor: Colors.green.shade800),
                              _excelCellBalance(summary['Grand Outstanding'] ?? 'Rs. 0', 130),
                              const SizedBox(width: 100),
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
    );
  }

  // ═══════════════════════════════════════════
  // TAB 4: Sold Out Statement
  // ═══════════════════════════════════════════
  Widget _buildSoldOutTab() {
    final data = StatementPdfGenerator.buildSoldOutData(_appData.sales, _fromDate, _toDate);
    final rows = (data['rows'] as List<Map<String, String>>);
    final summary = data['summary'] as Map<String, String>;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppColors.surface,
          child: Row(
            children: [
              _kpiCard('PRODUCTS SOLD', summary['Total Products Sold'] ?? '0', Icons.inventory, Colors.blue.shade700),
              const SizedBox(width: 10),
              _kpiCard('TOTAL QTY SOLD', summary['Total Quantity Sold'] ?? '0', Icons.shopping_cart, Colors.orange.shade800),
              const SizedBox(width: 10),
              _kpiCard('TOTAL REVENUE', summary['Total Revenue'] ?? 'Rs. 0', Icons.monetization_on, Colors.green.shade700),
              const SizedBox(width: 10),
              _kpiCard('INVOICES', summary['Total Invoices'] ?? '0', Icons.receipt, AppColors.primary),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 820.0;
              final gridWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;
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
                          gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                        ),
                        child: Row(
                          children: [
                            _excelHeader('S.NO', 45),
                            _excelHeader('PRODUCT NAME', 200),
                            _excelHeader('UNIT', 80),
                            _excelHeader('TOTAL SOLD QTY', 120, isNum: true),
                            _excelHeader('REVENUE (RS)', 130, isNum: true),
                            _excelHeader('INVOICES', 80, isNum: true),
                            _excelHeader('LAST SOLD', 100),
                          ],
                        ),
                      ),
                      Expanded(
                        child: rows.isEmpty
                            ? _buildEmptyState('No sold products found for the selected date range.')
                            : ListView.builder(
                                itemCount: rows.length,
                                itemBuilder: (context, index) {
                                  final row = rows[index];
                                  return Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                      border: const Border(bottom: _gridBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        _excelCell('${index + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                        _excelCell(row['product'] ?? '', 200, isBold: true),
                                        _excelCell(row['unit'] ?? '', 80),
                                        _excelCell(row['soldQty'] ?? '', 120, isNum: true),
                                        _excelCell(row['revenue'] ?? '', 130, isNum: true, isBold: true, textColor: Colors.green.shade700),
                                        _excelCell(row['invoices'] ?? '', 80, isNum: true),
                                        _excelCell(row['lastDate'] ?? '', 100),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (rows.isNotEmpty)
                        Container(
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            border: Border(top: BorderSide(color: Color(0xFFCBD5E1), width: 1.5), bottom: BorderSide(color: Color(0xFF94A3B8), width: 1.5)),
                          ),
                          child: Row(
                            children: [
                              _excelCell('TOTALS (${summary['Total Products Sold']} Products)', 45 + 200 + 80, isBold: true),
                              _excelCell(summary['Total Quantity Sold'] ?? '0', 120, isNum: true, isBold: true),
                              _excelCell(summary['Total Revenue'] ?? 'Rs. 0', 130, isNum: true, isBold: true, textColor: Colors.green.shade800),
                              _excelCell(summary['Total Invoices'] ?? '0', 80, isNum: true, isBold: true),
                              const SizedBox(width: 100),
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
    );
  }

  // ═══════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════
  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFD5D8DF)),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(3)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.3)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _excelHeader(String text, double width, {bool isNum = false, bool isCenter = false}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isCenter ? Alignment.center : (isNum ? Alignment.centerRight : Alignment.centerLeft),
      child: Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF2D3748), letterSpacing: 0.2), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _excelCell(String text, double width, {bool isNum = false, bool isBold = false, Color? textColor}) {
    return Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w400, color: textColor ?? AppColors.textPrimary)),
    );
  }

  Widget _excelCellBalance(String text, double width) {
    return Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade700), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _excelCellStatus(String text, double width) {
    final Color color;
    if (text == 'Paid') {
      color = Colors.green.shade700;
    } else if (text == 'Unpaid' || text == 'Partial') {
      color = Colors.orange.shade700;
    } else {
      color = AppColors.textPrimary;
    }
    return Container(
      width: width,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildFooterRow(String label, List<double> widths, List<String> values) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        border: Border(top: BorderSide(color: Color(0xFFCBD5E1), width: 1.5), bottom: BorderSide(color: Color(0xFF94A3B8), width: 1.5)),
      ),
      child: Row(
        children: [
          _excelCell(label, widths.fold(0.0, (sum, w) => sum + w), isBold: true),
          for (var i = 0; i < values.length; i++)
            _excelCell(values[i], widths[widths.length - values.length + i], isNum: true, isBold: true, textColor: i == values.length - 1 ? Colors.red.shade800 : AppColors.textPrimary),
          const SizedBox(width: 90),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('No Data Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
