import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/product_model.dart';
import 'add_product_dialog.dart';

enum InventorySortColumn { name, stock, purchaseRate, sellingRate, valuation, margin }

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _appData = AppData();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'In Stock', 'Low Stock', 'Out of Stock'
  InventorySortColumn _sortColumn = InventorySortColumn.name;
  bool _sortAscending = true;
  final _searchController = TextEditingController();

  List<ProductModel> get _filteredProducts {
    var filtered = List<ProductModel>.from(_appData.products);

    // 1. Text Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.purchaseUnit.toLowerCase().contains(q) ||
        p.sellingUnit.toLowerCase().contains(q) ||
        p.variety.toLowerCase().contains(q) ||
        p.brand.toLowerCase().contains(q)
      ).toList();
    }

    // 2. Category / Stock Filter
    if (_selectedFilter == 'In Stock') {
      filtered = filtered.where((p) => !p.isLowStock && p.currentStock > 0).toList();
    } else if (_selectedFilter == 'Low Stock') {
      filtered = filtered.where((p) => p.isLowStock && p.currentStock > 0).toList();
    } else if (_selectedFilter == 'Out of Stock') {
      filtered = filtered.where((p) => p.currentStock <= 0).toList();
    }

    // 3. Sorting
    filtered.sort((a, b) {
      int comp = 0;
      switch (_sortColumn) {
        case InventorySortColumn.name:
          comp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case InventorySortColumn.stock:
          comp = a.currentStock.compareTo(b.currentStock);
          break;
        case InventorySortColumn.purchaseRate:
          comp = a.purchasePrice.compareTo(b.purchasePrice);
          break;
        case InventorySortColumn.sellingRate:
          comp = a.sellingPrice.compareTo(b.sellingPrice);
          break;
        case InventorySortColumn.valuation:
          comp = (a.currentStock * a.purchasePrice).compareTo(b.currentStock * b.purchasePrice);
          break;
        case InventorySortColumn.margin:
          comp = a.profitMargin.compareTo(b.profitMargin);
          break;
      }
      return _sortAscending ? comp : -comp;
    });

    return filtered;
  }

  int get _totalItems => _appData.products.length;
  int get _inStockItems => _appData.products.where((p) => !p.isLowStock && p.currentStock > 0).length;
  int get _lowStockItems => _appData.products.where((p) => p.isLowStock && p.currentStock > 0).length;
  int get _outOfStockItems => _appData.products.where((p) => p.currentStock <= 0).length;
  double get _totalInventoryValuation => _appData.products.fold(0.0, (s, p) => s + (p.currentStock * p.purchasePrice));

  void _onSort(InventorySortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  void _openAddProductDialog([ProductModel? product]) async {
    final result = await showDialog<ProductModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddProductDialog(product: product),
    );
    if (result != null) {
      setState(() {
        if (product != null) {
          _appData.updateProduct(result);
        } else {
          _appData.addProduct(result);
        }
      });
    }
  }

  void _openStockAdjustDialog(ProductModel product) {
    final adjustController = TextEditingController();
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              title: Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Adjust Stock: ${product.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Stock: ${product.currentStock.toStringAsFixed(0)} ${product.sellingUnit}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('+ Add Stock'),
                        selected: isAddition,
                        selectedColor: AppColors.success.withAlpha(40),
                        onSelected: (val) => setDialogState(() => isAddition = true),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('- Deduct Stock'),
                        selected: !isAddition,
                        selectedColor: AppColors.error.withAlpha(40),
                        onSelected: (val) => setDialogState(() => isAddition = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Adjustment Quantity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 36,
                    child: TextField(
                      controller: adjustController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter quantity (e.g. 50)',
                        suffixText: product.sellingUnit,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isAddition ? AppColors.success : AppColors.error),
                  onPressed: () {
                    final qty = double.tryParse(adjustController.text) ?? 0.0;
                    if (qty > 0) {
                      final delta = isAddition ? qty : -qty;
                      setState(() {
                        _appData.updateStock(product.id!, delta);
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Stock updated for ${product.name}')),
                      );
                    }
                  },
                  child: const Text('Confirm Adjustment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Delete Item', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Delete "${product.name}" from inventory? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _appData.deleteProduct(product.id!));
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

  static const _gridBorder = BorderSide(color: Color(0xFFD5D8DF), width: 0.6);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appData,
      builder: (context, _) {
        final filteredList = _filteredProducts;

        return Container(
          color: const Color(0xFFEBEBE4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Header Banner ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                  boxShadow: [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory Master Catalog',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Manage seed items, buying/selling units, rates, stock adjustments & profit margins',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () => _openAddProductDialog(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── KPI Summary Band (Clickable Filters) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFFF2F2EC),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = 'All'),
                        child: _kpiCard(
                          'TOTAL CATALOG ITEMS',
                          '$_totalItems Items',
                          Icons.inventory_2_outlined,
                          const Color(0xFF003399),
                          isSelected: _selectedFilter == 'All',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = 'In Stock'),
                        child: _kpiCard(
                          'IN STOCK',
                          '$_inStockItems Items',
                          Icons.check_circle_outline,
                          AppColors.success,
                          isSelected: _selectedFilter == 'In Stock',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = 'Low Stock'),
                        child: _kpiCard(
                          'LOW STOCK ALERTS',
                          '$_lowStockItems Items',
                          Icons.warning_amber_rounded,
                          const Color(0xFFD97706),
                          isSelected: _selectedFilter == 'Low Stock',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = 'Out of Stock'),
                        child: _kpiCard(
                          'OUT OF STOCK',
                          '$_outOfStockItems Items',
                          Icons.error_outline_rounded,
                          AppColors.error,
                          isSelected: _selectedFilter == 'Out of Stock',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Excel Spreadsheet Container ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFB0B4BE)),
                    ),
                    child: Column(
                      children: [
                        // ── Search & Filter Ribbon ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: const Color(0xFFF4F4EE),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 300,
                                height: 30,
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Search item name, brand or unit...',
                                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                                    prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                                    prefixIconConstraints: const BoxConstraints(minWidth: 30),
                                    filled: true,
                                    fillColor: AppColors.searchBg,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _gridBorder),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: _gridBorder),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    isDense: true,
                                  ),
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                              ],
                              const SizedBox(width: 12),
                              // Filter Chips
                              _filterChip('All', 'All'),
                              const SizedBox(width: 6),
                              _filterChip('In Stock', 'In Stock'),
                              const SizedBox(width: 6),
                              _filterChip('Low Stock', 'Low Stock'),
                              const SizedBox(width: 6),
                              _filterChip('Out of Stock', 'Out of Stock'),
                              const Spacer(),
                              Text(
                                'Showing ${filteredList.length} of $_totalItems items',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        // ── Excel Column Header Row (Click to Sort) ──
                        Container(
                          height: 32,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFFE4E6EA), Color(0xFFD5D8DF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            border: Border(bottom: BorderSide(color: Color(0xFFB0B4BE), width: 1)),
                          ),
                          child: Row(
                            children: [
                              _sortableHeader('S.NO', 45, null),
                              _sortableHeader('ITEM NAME', 180, InventorySortColumn.name),
                              _sortableHeader('BUY UNIT', 85, null),
                              _sortableHeader('SELL UNIT', 85, null),
                              _sortableHeader('STOCK', 105, InventorySortColumn.stock, isNum: true),
                              _sortableHeader('PURCHASE RATE', 110, InventorySortColumn.purchaseRate, isNum: true),
                              _sortableHeader('SELLING RATE', 110, InventorySortColumn.sellingRate, isNum: true),
                              _sortableHeader('TOTAL VALUATION', 125, InventorySortColumn.valuation, isNum: true),
                              _sortableHeader('MARGIN %', 95, InventorySortColumn.margin, isNum: true),
                              _sortableHeader('STATUS', 100, null),
                              const SizedBox(width: 100),
                            ],
                          ),
                        ),

                        // ── Excel Data Rows ──
                        Expanded(
                          child: filteredList.isEmpty
                              ? _buildEmpty()
                              : ListView.builder(
                                  itemCount: filteredList.length,
                                  itemBuilder: (ctx, i) {
                                    final p = filteredList[i];
                                    final isLow = p.isLowStock && p.currentStock > 0;
                                    final isOut = p.currentStock <= 0;
                                    final double valuation = p.currentStock * p.purchasePrice;
                                    final double margin = p.profitMargin;

                                    return InkWell(
                                      hoverColor: const Color(0xFFEBF3FA),
                                      onTap: () => _openAddProductDialog(p),
                                      child: Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
                                          border: const Border(bottom: _gridBorder),
                                        ),
                                        child: Row(
                                          children: [
                                            _excelCell('${i + 1}', 45, isNum: true, textColor: AppColors.textHint),
                                            _excelCell(
                                              p.name,
                                              180,
                                              isBold: true,
                                              textColor: isOut ? AppColors.error : AppColors.textPrimary,
                                            ),
                                            _excelCell(p.purchaseUnit, 85),
                                            _excelCell(p.sellingUnit, 85),
                                            _excelCell(
                                              '${p.currentStock.toStringAsFixed(0)} ${p.sellingUnit}',
                                              105,
                                              isNum: true,
                                              isBold: isLow || isOut,
                                              textColor: isOut ? AppColors.error : (isLow ? const Color(0xFFD97706) : AppColors.textPrimary),
                                            ),
                                            _excelCell('Rs. ${p.purchasePrice.toStringAsFixed(0)}', 110, isNum: true),
                                            _excelCell('Rs. ${p.sellingPrice.toStringAsFixed(0)}', 110, isNum: true, isBold: true),
                                            _excelCell('Rs. ${valuation.toStringAsFixed(0)}', 125, isNum: true, isBold: true, textColor: const Color(0xFF003399)),
                                            _excelMarginCell(margin, 95),
                                            Expanded(
                                              flex: 100,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                decoration: const BoxDecoration(border: Border(right: _gridBorder)),
                                                alignment: Alignment.centerLeft,
                                                child: _excelStatusBadge(
                                                  isOut ? 'OUT OF STOCK' : (isLow ? 'LOW STOCK' : 'IN STOCK'),
                                                  isOut ? AppColors.error : (isLow ? const Color(0xFFD97706) : AppColors.success),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Tooltip(
                                                    message: 'Quick Stock Adjustment',
                                                    child: InkWell(
                                                      onTap: () => _openStockAdjustDialog(p),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(color: const Color(0xFF2E7D32).withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                        child: const Icon(Icons.tune, size: 14, color: Color(0xFF2E7D32)),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Tooltip(
                                                    message: 'Edit Item Details',
                                                    child: InkWell(
                                                      onTap: () => _openAddProductDialog(p),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                        child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Tooltip(
                                                    message: 'Delete Item',
                                                    child: InkWell(
                                                      onTap: () => _deleteProduct(p),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(2)),
                                                        child: const Icon(Icons.delete_outline, size: 14, color: AppColors.error),
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
                ),
              ),

              // ── Excel Status Strip ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.statusBarBg,
                  border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warehouse_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Catalog Total: $_totalItems items  |  In Stock: $_inStockItems  |  Low Stock: $_lowStockItems  |  Out of Stock: $_outOfStockItems  |  Total Asset Valuation: Rs. ${_totalInventoryValuation.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Text('Click column headers to sort', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFB0B4BE)),
          borderRadius: BorderRadius.circular(2),
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

  Widget _kpiCard(String label, String value, IconData icon, Color color, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withAlpha(15) : Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: isSelected ? color : const Color(0xFFD5D8DF), width: isSelected ? 1.5 : 1.0),
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
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textHint.withAlpha(80)),
          const SizedBox(height: 8),
          const Text('No inventory items match your filter', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () => _openAddProductDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Item', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortableHeader(String text, double width, InventorySortColumn? col, {bool isNum = false}) {
    final bool isCurrent = col != null && _sortColumn == col;
    return InkWell(
      onTap: col != null ? () => _onSort(col) : null,
      child: Container(
        width: width,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(border: Border(right: _gridBorder)),
        alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: isNum ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
                  color: isCurrent ? AppColors.primary : const Color(0xFF2D3748),
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (col != null) ...[
              const SizedBox(width: 2),
              Icon(
                isCurrent ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more,
                size: 11,
                color: isCurrent ? AppColors.primary : AppColors.textHint,
              ),
            ],
          ],
        ),
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

  Widget _excelMarginCell(double margin, double width) {
    final bool isPositive = margin > 0;
    final String text = '${isPositive ? "+" : ""}${margin.toStringAsFixed(1)}%';
    final Color color = isPositive ? AppColors.success : (margin < 0 ? AppColors.error : AppColors.textSecondary);

    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(border: Border(right: _gridBorder)),
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          border: Border.all(color: color.withAlpha(50)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _excelStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
