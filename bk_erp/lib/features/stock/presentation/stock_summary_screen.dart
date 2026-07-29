import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../../inventory/models/product_model.dart';

class StockSummaryScreen extends StatefulWidget {
  const StockSummaryScreen({super.key});

  @override
  State<StockSummaryScreen> createState() => _StockSummaryScreenState();
}

class _StockSummaryScreenState extends State<StockSummaryScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  String _stockFilter = 'All'; // 'All', 'In Stock', 'Low Stock', 'Out of Stock'
  final _searchController = TextEditingController();
  final nf = NumberFormat.currency(locale: 'en_NP', symbol: 'Rs. ');

  static const _gridBorder = BorderSide(color: Color(0xFFD0D5DD), width: 0.75);

  List<ProductModel> get _filtered {
    List<ProductModel> list = _appData.products;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.inventoryGroup.toLowerCase().contains(q)
      ).toList();
    }

    if (_stockFilter == 'In Stock') {
      list = list.where((p) => !p.isLowStock && p.currentStock > 0).toList();
    } else if (_stockFilter == 'Low Stock') {
      list = list.where((p) => p.isLowStock && p.currentStock > 0).toList();
    } else if (_stockFilter == 'Out of Stock') {
      list = list.where((p) => p.currentStock <= 0).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final totalProducts = _appData.products.length;
        final totalStockUnits = _appData.products.fold(0.0, (sum, p) => sum + p.currentStock);
        final lowStockCount = _appData.products.where((p) => p.isLowStock && p.currentStock > 0).length;
        final outOfStockCount = _appData.products.where((p) => p.currentStock <= 0).length;
        final totalValuation = _appData.products.fold(0.0, (sum, p) => sum + (p.currentStock * p.purchasePrice));
        final filteredList = _filtered;

        return Container(
          color: const Color(0xFFEBEBE4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Banner ──
              Container(
                color: const Color(0xFF2C3E50),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.warehouse, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'STOCK SUMMARY & INVENTORY VALUATION',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Total Items: $totalProducts  |  Valuation: ${nf.format(totalValuation)}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // ── Quick Summary Cards Banner ──
              Container(
                color: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _kpiCard('TOTAL STOCK UNITS', '${totalStockUnits.toStringAsFixed(0)} Units', Icons.inventory_2_outlined, const Color(0xFF003399)),
                    const SizedBox(width: 8),
                    _kpiCard('TOTAL VALUATION', nf.format(totalValuation), Icons.account_balance_wallet_outlined, AppColors.primary),
                    const SizedBox(width: 8),
                    _kpiCard('LOW STOCK ALERT', '$lowStockCount Items', Icons.warning_amber_rounded, AppColors.error),
                    const SizedBox(width: 8),
                    _kpiCard('OUT OF STOCK', '$outOfStockCount Items', Icons.remove_shopping_cart_outlined, AppColors.warning),
                  ],
                ),
              ),

              // ── Toolbar & Filter Bar ──
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
                      width: 240,
                      height: 28,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search item or category...',
                          hintStyle: const TextStyle(fontSize: 11, color: AppColors.textHint),
                          prefixIcon: const Icon(Icons.search, size: 14, color: AppColors.textHint),
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Color(0xFFB0B4BE))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Color(0xFFB0B4BE))),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('All Items', _stockFilter == 'All', () => setState(() => _stockFilter = 'All')),
                            const SizedBox(width: 6),
                            _filterChip('In Stock', _stockFilter == 'In Stock', () => setState(() => _stockFilter = 'In Stock')),
                            const SizedBox(width: 6),
                            _filterChip('Low Stock ($lowStockCount)', _stockFilter == 'Low Stock', () => setState(() => _stockFilter = 'Low Stock'), color: AppColors.error),
                            const SizedBox(width: 6),
                            _filterChip('Out of Stock ($outOfStockCount)', _stockFilter == 'Out of Stock', () => setState(() => _stockFilter = 'Out of Stock'), color: AppColors.warning),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Showing ${filteredList.length} of $totalProducts items',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // ── Excel Data Grid ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridWidth = constraints.maxWidth > 1110 ? constraints.maxWidth : 1110.0;
                    final extra = gridWidth - 1110.0;
                    final nameWidth = 200.0 + (extra * 0.45);
                    final valWidth = 135.0 + (extra * 0.30);
                    final statusWidth = 110.0 + (extra * 0.25);

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
                                gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  _excelHeader('S.NO', 45),
                                  _excelHeader('ITEM NAME', nameWidth),
                                  _excelHeader('BUY UNIT', 90),
                                  _excelHeader('SELL UNIT', 90),
                                  _excelHeader('CURRENT STOCK', 130, isNum: true),
                                  _excelHeader('PURCHASE RATE', 110, isNum: true),
                                  _excelHeader('SELLING RATE', 110, isNum: true),
                                  _excelHeader('VALUATION (RS)', valWidth, isNum: true),
                                  _excelHeader('REORDER LVL', 90, isNum: true),
                                  _excelHeader('STATUS', statusWidth),
                                ],
                              ),
                            ),

                            // Excel Rows
                            Expanded(
                              child: filteredList.isEmpty
                                  ? const Center(child: Text('No stock records found matching criteria', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)))
                                  : ListView.builder(
                                      itemCount: filteredList.length,
                                      itemBuilder: (ctx, i) {
                                        final p = filteredList[i];
                                        final bool isLow = p.isLowStock && p.currentStock > 0;
                                        final bool isOut = p.currentStock <= 0;
                                        final double valuation = p.currentStock * p.purchasePrice;

                                        return InkWell(
                                          hoverColor: const Color(0xFFEBF3FA),
                                          child: Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                              border: const Border(bottom: _gridBorder),
                                            ),
                                            child: Row(
                                              children: [
                                                _excelCell('${i + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                                _excelCell(p.name, nameWidth, isBold: true),
                                                _excelCell(p.purchaseUnit, 90),
                                                _excelCell(p.sellingUnit, 90),
                                                _excelCell(
                                                  '${p.currentStock.toStringAsFixed(1)} ${p.sellingUnit}',
                                                  130,
                                                  isNum: true,
                                                  isBold: true,
                                                  textColor: isOut ? AppColors.error : (isLow ? Colors.deepOrange : AppColors.textPrimary),
                                                ),
                                                _excelCell('Rs. ${p.purchasePrice.toStringAsFixed(0)}', 110, isNum: true),
                                                _excelCell('Rs. ${p.sellingPrice.toStringAsFixed(0)}', 110, isNum: true, isBold: true),
                                                _excelCell(
                                                  'Rs. ${valuation.toStringAsFixed(0)}',
                                                  valWidth,
                                                  isNum: true,
                                                  isBold: true,
                                                  textColor: AppColors.primary,
                                                ),
                                                _excelCell(p.reorderLevel > 0 ? '${p.reorderLevel.toStringAsFixed(0)} ${p.sellingUnit}' : '-', 90, isNum: true),
                                                _excelStatusBadge(isOut ? 'OUT OF STOCK' : (isLow ? 'LOW STOCK' : 'IN STOCK'), statusWidth),
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
                      Text('TOTAL ITEMS: ${filteredList.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      const SizedBox(width: 20),
                      Text('TOTAL UNITS IN STOCK: ${filteredList.fold(0.0, (s, p) => s + p.currentStock).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      const SizedBox(width: 30),
                      Text('TOTAL STOCK VALUATION: ${nf.format(filteredList.fold(0.0, (s, p) => s + (p.currentStock * p.purchasePrice)))}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(3)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                  Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: isSelected ? activeColor : const Color(0xFFB0B4BE)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
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
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475467)),
      ),
    );
  }

  Widget _excelCell(String text, double width, {bool isNum = false, bool isBold = false, Color? textColor}) {
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

  Widget _excelStatusBadge(String status, double width) {
    Color bg = const Color(0xFFECFDF5);
    Color fg = const Color(0xFF047857);
    Color border = const Color(0xFFA7F3D0);

    if (status == 'LOW STOCK') {
      bg = const Color(0xFFFFFAEB);
      fg = const Color(0xFFB54708);
      border = const Color(0xFFFEDF89);
    } else if (status == 'OUT OF STOCK') {
      bg = const Color(0xFFFEF3F2);
      fg = const Color(0xFFB42318);
      border = const Color(0xFFFECDCA);
    }

    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(2)),
        child: Text(status, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: fg)),
      ),
    );
  }
}
