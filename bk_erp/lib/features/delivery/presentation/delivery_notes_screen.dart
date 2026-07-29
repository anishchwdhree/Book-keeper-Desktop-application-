import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/delivery_note_model.dart';
import 'create_delivery_note_dialog.dart';

class DeliveryNotesScreen extends StatefulWidget {
  const DeliveryNotesScreen({super.key});

  @override
  State<DeliveryNotesScreen> createState() => _DeliveryNotesScreenState();
}

class _DeliveryNotesScreenState extends State<DeliveryNotesScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<DeliveryNoteModel> get _filtered {
    var list = _appData.deliveryNotes;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((d) => d.deliveryNumber.toLowerCase().contains(q) || d.customerName.toLowerCase().contains(q) || d.vehicleNumber.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != 'All') {
      list = list.where((d) => d.status == _statusFilter).toList();
    }
    return list;
  }

  void _createNewNote() async {
    final result = await showDialog<DeliveryNoteModel>(context: context, builder: (_) => const CreateDeliveryNoteDialog());
    if (result != null) {
      if (!mounted) return;
      setState(() => _appData.addDeliveryNote(result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery Note saved successfully!')));
    }
  }

  void _viewNote(DeliveryNoteModel d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Challan ${d.deliveryNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${d.customerName}', style: const TextStyle(fontSize: 12)),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(d.date)}', style: const TextStyle(fontSize: 12)),
            if (d.vehicleNumber.isNotEmpty) Text('Vehicle: ${d.vehicleNumber}', style: const TextStyle(fontSize: 12)),
            if (d.driverName.isNotEmpty) Text('Driver: ${d.driverName}', style: const TextStyle(fontSize: 12)),
            const Divider(),
            ...d.items.map((i) => Text('${i.product.name} x${i.quantity} ${i.product.unit}', style: const TextStyle(fontSize: 12))),
            const Divider(),
            Text('Status: ${d.status}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        actions: [
          if (d.status != 'Invoiced')
            TextButton(
              onPressed: () {
                setState(() => _appData.updateDeliveryNote(d.copyWith(status: 'Invoiced')));
                Navigator.pop(context);
              },
              child: const Text('Mark as Invoiced'),
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
                    Icon(Icons.local_shipping, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Delivery Notes (Challan)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
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
                            hintText: 'Search challans...',
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
                        items: ['All', 'Dispatched', 'Delivered', 'Invoiced'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _statusFilter = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _createNewNote,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Challan', style: TextStyle(fontSize: 12)),
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
                            _hdr('DN #', flex: 2),
                            _hdr('Date', flex: 2),
                            _hdr('Customer', flex: 3),
                            _hdr('Vehicle #', flex: 2),
                            _hdr('Status', flex: 2),
                            _hdr('Actions', flex: 1, numeric: true),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      Expanded(
                        child: displayed.isEmpty
                            ? const Center(child: Text('No delivery notes yet.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                            : ListView.separated(
                                itemCount: displayed.length,
                                separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.surfaceBorder),
                                itemBuilder: (context, index) {
                                  final d = displayed[index];
                                  return InkWell(
                                    onDoubleTap: () => _viewNote(d),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          _cell(d.deliveryNumber, flex: 2, bold: true),
                                          _cell(DateFormat('MMM dd, yyyy').format(d.date), flex: 2),
                                          _cell(d.customerName, flex: 3),
                                          _cell(d.vehicleNumber.isNotEmpty ? d.vehicleNumber : '-', flex: 2),
                                          Expanded(
                                            flex: 2,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: d.status == 'Invoiced' ? AppColors.success.withValues(alpha: 0.15) : d.status == 'Delivered' ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.info.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                                child: Text(d.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: d.status == 'Invoiced' ? AppColors.success : d.status == 'Delivered' ? AppColors.secondary : AppColors.info)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () => _viewNote(d),
                                                child: const Icon(Icons.visibility, size: 15, color: AppColors.primary),
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
                  'Total Challans: ${_appData.deliveryNotes.length}  |  Filtered: ${displayed.length}',
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
