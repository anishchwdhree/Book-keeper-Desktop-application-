import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';
import '../models/audit_log_model.dart';

class AuditTrailScreen extends StatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  State<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends State<AuditTrailScreen> {
  final _appData = AppData();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<AuditLogModel> get _filtered {
    var list = _appData.auditLog.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) =>
        e.documentRef.toLowerCase().contains(q) ||
        e.description.toLowerCase().contains(q) ||
        e.documentType.toLowerCase().contains(q) ||
        e.action.toLowerCase().contains(q)
      ).toList();
    }
    return list;
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
                    Icon(Icons.history, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Audit Trail', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(color: AppColors.statusBarBg, border: Border(bottom: BorderSide(color: AppColors.surfaceBorder))),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search audit logs...',
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
                            _hdr('Timestamp', flex: 2),
                            _hdr('Action', flex: 1),
                            _hdr('Doc Type', flex: 2),
                            _hdr('Reference', flex: 2),
                            _hdr('Description', flex: 4),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      Expanded(
                        child: displayed.isEmpty
                            ? const Center(child: Text('No audit logs recorded yet.', style: TextStyle(color: AppColors.textHint, fontSize: 12)))
                            : ListView.separated(
                                itemCount: displayed.length,
                                separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.surfaceBorder),
                                itemBuilder: (context, index) {
                                  final e = displayed[index];
                                  Color actionColor = AppColors.textSecondary;
                                  if (e.action == 'Created') actionColor = AppColors.success;
                                  if (e.action == 'Updated') actionColor = AppColors.secondary;
                                  if (e.action == 'Deleted') actionColor = AppColors.error;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        _cell(DateFormat('MMM dd, yyyy HH:mm').format(e.timestamp), flex: 2),
                                        Expanded(
                                          flex: 1,
                                          child: Text(e.action, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: actionColor)),
                                        ),
                                        _cell(e.documentType, flex: 2, bold: true),
                                        _cell(e.documentRef, flex: 2, color: AppColors.primary),
                                        _cell(e.description, flex: 4),
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
                child: Text(
                  'Total Log Entries: ${_appData.auditLog.length}  |  Filtered: ${displayed.length}',
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
