import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/estimate_model.dart';
import 'create_estimate_dialog.dart';
import '../utils/estimate_pdf_generator.dart';

class EstimatesScreen extends StatefulWidget {
  const EstimatesScreen({super.key});

  @override
  State<EstimatesScreen> createState() => _EstimatesScreenState();
}

class _EstimatesScreenState extends State<EstimatesScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<EstimateModel> get _filtered {
    var list = _appData.estimates;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) => e.estimateNumber.toLowerCase().contains(q) || e.customerName.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != 'All') {
      list = list.where((e) => e.status == _statusFilter).toList();
    }
    return list;
  }

  void _createNewEstimate() async {
    final result = await showDialog<EstimateModel>(context: context, builder: (_) => const CreateEstimateDialog());
    if (result != null) {
      if (!mounted) return;
      setState(() => _appData.addEstimate(result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estimate saved successfully!')));
    }
  }

  void _viewEstimate(EstimateModel e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Estimate ${e.estimateNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${e.customerName}', style: const TextStyle(fontSize: 12)),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(e.date)}', style: const TextStyle(fontSize: 12)),
            if (e.validUntil != null) Text('Valid Until: ${DateFormat('yyyy-MM-dd').format(e.validUntil!)}', style: const TextStyle(fontSize: 12)),
            const Divider(),
            ...e.items.map((i) => Text('${i.product.name} x${i.quantity} = Rs.${(i.quantity * i.unitPrice).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12))),
            const Divider(),
            Text('Sub Total: Rs.${e.subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            Text('VAT: Rs.${e.vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            Text('Grand Total: Rs.${e.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        actions: [
          if (e.status != 'Converted')
            TextButton(
              onPressed: () {
                setState(() => _appData.updateEstimate(e.copyWith(status: 'Converted')));
                Navigator.pop(context);
              },
              child: const Text('Convert to Invoice'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
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
                    Icon(Icons.description, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Estimates & Quotes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
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
                            hintText: 'Search estimates...',
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
                      width: 120,
                      height: 30,
                      child: DropdownButtonFormField<String>(
                        initialValue: _statusFilter,
                        isDense: true,
                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                        style: const TextStyle(fontSize: 12),
                        items: ['All', 'Draft', 'Sent', 'Converted'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _statusFilter = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _createNewEstimate,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Estimate', style: TextStyle(fontSize: 12)),
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
                            _hdr('Est #', flex: 2),
                            _hdr('Date', flex: 2),
                            _hdr('Customer', flex: 3),
                            _hdr('Grand Total', flex: 2, numeric: true),
                            _hdr('Valid Until', flex: 2),
                            _hdr('Status', flex: 1),
                            _hdr('Actions', flex: 1, numeric: true),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      Expanded(
                        child: displayed.isEmpty
                            ? const Center(child: Text('No estimates generated yet.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                            : ListView.separated(
                                itemCount: displayed.length,
                                separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.surfaceBorder),
                                itemBuilder: (context, index) {
                                  final e = displayed[index];
                                  return InkWell(
                                    onDoubleTap: () => _viewEstimate(e),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          _cell(e.estimateNumber, flex: 2, bold: true),
                                          _cell(DateFormat('MMM dd, yyyy').format(e.date), flex: 2),
                                          _cell(e.customerName, flex: 3),
                                          _cell('Rs.${e.grandTotal.toStringAsFixed(2)}', flex: 2, numeric: true, color: AppColors.primary, bold: true),
                                          _cell(e.validUntil != null ? DateFormat('MMM dd, yyyy').format(e.validUntil!) : '-', flex: 2),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: e.status == 'Converted' ? AppColors.success.withValues(alpha: 0.15) : e.status == 'Sent' ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.info.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                                child: Text(e.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: e.status == 'Converted' ? AppColors.success : e.status == 'Sent' ? AppColors.secondary : AppColors.info)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(onTap: () => _viewEstimate(e), child: const Icon(Icons.visibility, size: 15, color: AppColors.primary)),
                                                  const SizedBox(width: 10),
                                                  InkWell(onTap: () => EstimatePdfGenerator.printEstimate(context, e, _appData.settings), child: const Icon(Icons.print, size: 15, color: AppColors.secondary)),
                                                ],
                                              ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
                child: Text(
                  'Total Estimates: ${_appData.estimates.length}  |  Filtered: ${displayed.length}',
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
