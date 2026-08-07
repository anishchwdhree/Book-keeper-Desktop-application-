import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';

class ItemsSoldScreen extends StatefulWidget {
  const ItemsSoldScreen({super.key});

  @override
  State<ItemsSoldScreen> createState() => _ItemsSoldScreenState();
}

class _ItemsSoldScreenState extends State<ItemsSoldScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final nf = NumberFormat.currency(locale: 'en_NP', symbol: 'Rs. ');

  static const _gridBorder = BorderSide(color: Color(0xFFD0D5DD), width: 0.75);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SoldItem> get _aggregated {
    final list = <_SoldItem>[];

    for (final sale in _appData.sales) {
      final custName = sale.customerName;
      for (final item in sale.items) {
        list.add(_SoldItem(
          productName: item.product.name,
          category: item.product.inventoryGroup,
          unit: item.unit,
          unitPrice: item.unitPrice,
          totalQty: item.quantity,
          totalRevenue: item.lineTotal,
          invoiceCount: 1,
          customers: {custName},
        ));
      }
    }

    list.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list.retainWhere(
        (i) =>
            i.productName.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final items = _aggregated;
        final totalRevenue = items.fold(0.0, (s, i) => s + i.totalRevenue);
        final totalQty = items.fold(0.0, (s, i) => s + i.totalQty);
        final totalInvoices = _appData.sales.length;

        return Container(
          color: const Color(0xFFEBEBE4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Banner ──
              Container(
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.amberAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'ITEMS SOLD & SALES PERFORMANCE SUMMARY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Total Sales Revenue: ${nf.format(totalRevenue)}',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ── KPI Summary Banner ──
              Container(
                color: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _kpiCard(
                      'TOTAL ITEMS SOLD',
                      '${items.length} Products',
                      Icons.category_outlined,
                      const Color(0xFF003399),
                    ),
                    const SizedBox(width: 8),
                    _kpiCard(
                      'TOTAL QUANTITY SOLD',
                      '${totalQty.toStringAsFixed(0)} Units',
                      Icons.scale_outlined,
                      AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _kpiCard(
                      'TOTAL SALES REVENUE',
                      nf.format(totalRevenue),
                      Icons.payments_outlined,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _kpiCard(
                      'TOTAL SALES INVOICES',
                      '$totalInvoices Invoices',
                      Icons.receipt_long_outlined,
                      Colors.purple,
                    ),
                  ],
                ),
              ),

              // ── Toolbar Bar ──
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F0),
                  border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 28,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search sold items or category...',
                          hintStyle: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: const BorderSide(
                              color: Color(0xFFB0B4BE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: const BorderSide(
                              color: Color(0xFFB0B4BE),
                            ),
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Showing ${items.length} unique items sold',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Excel Data Grid ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridWidth = constraints.maxWidth > 1095 ? constraints.maxWidth : 1095.0;
                    final extra = gridWidth - 1095.0;
                    final nameWidth = 200.0 + (extra * 0.30);
                    final custWidth = 180.0 + (extra * 0.30);
                    final revWidth = 160.0 + (extra * 0.25);
                    final invWidth = 130.0 + (extra * 0.15);

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: gridWidth,
                        height: constraints.maxHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Excel Header Row
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
                                  _excelHeader('ITEM NAME', nameWidth),
                                  _excelHeader('CUSTOMERS', custWidth),
                                  _excelHeader('UNIT', 90),
                                  _excelHeader(
                                    'TOTAL QTY SOLD',
                                    140,
                                    isNum: true,
                                  ),
                                  _excelHeader(
                                    'AVERAGE RATE',
                                    130,
                                    isNum: true,
                                  ),
                                  _excelHeader(
                                    'TOTAL REVENUE (RS)',
                                    revWidth,
                                    isNum: true,
                                  ),
                                  _excelHeader(
                                    'TOTAL INVOICES',
                                    invWidth,
                                    isNum: true,
                                  ),
                                ],
                              ),
                            ),

                            // Excel Rows
                            Expanded(
                              child:
                                  _appData.sales.isEmpty && _searchQuery.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No sales records yet',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : items.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No matching items sold',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (ctx, i) {
                                        final item = items[i];
                                        final avgRate = item.totalQty > 0
                                            ? (item.totalRevenue /
                                                  item.totalQty)
                                            : item.unitPrice;

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
                                                  item.productName,
                                                  nameWidth,
                                                  isBold: true,
                                                ),
                                                Tooltip(
                                                  message: item.customers.join(', '),
                                                  child: Container(
                                                    width: custWidth,
                                                    height: 32,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: const BoxDecoration(border: Border(right: _gridBorder)),
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      item.customers.join(', '),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                _excelCell(item.unit, 90),
                                                _excelCell(
                                                  '${item.totalQty % 1 == 0 ? item.totalQty.toInt() : item.totalQty.toStringAsFixed(1)} ${item.unit}',
                                                  140,
                                                  isNum: true,
                                                  isBold: true,
                                                ),
                                                _excelCell(
                                                  'Rs. ${avgRate.toStringAsFixed(0)}',
                                                  130,
                                                  isNum: true,
                                                ),
                                                _excelCell(
                                                  'Rs. ${item.totalRevenue.toStringAsFixed(0)}',
                                                  revWidth,
                                                  isNum: true,
                                                  isBold: true,
                                                  textColor: AppColors.primary,
                                                ),
                                                _excelCell(
                                                  '${item.invoiceCount} Invoices',
                                                  invWidth,
                                                  isNum: true,
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

              // ── Excel Status Footer Bar ──
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFD5D8DF),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'UNIQUE SOLD ITEMS: ${items.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'TOTAL QUANTITY SOLD: ${totalQty.toStringAsFixed(0)} Units',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        'GROSS SALES REVENUE: ${nf.format(totalRevenue)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
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
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _excelHeader(String label, double width, {bool isNum = false}) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475467),
        ),
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: textColor ?? AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SoldItem {
  final String productName;
  final String category;
  final String unit;
  final double unitPrice;
  double totalQty;
  double totalRevenue;
  int invoiceCount;
  final Set<String> customers;

  _SoldItem({
    required this.productName,
    required this.category,
    required this.unit,
    required this.unitPrice,
    required this.totalQty,
    required this.totalRevenue,
    required this.invoiceCount,
    required this.customers,
  });
}
