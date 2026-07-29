import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../../../core/utils/nepali_date.dart';
import '../../billing/models/sale_model.dart';
import '../../purchases/models/purchase_model.dart';

enum StatementType { sales, supplier, purchase, soldOut }

class StatementPdfGenerator {
  static final _currencyFmt = NumberFormat('#,##,##0.00', 'en_US');
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static Future<void> printStatement(
    StatementType type,
    String title,
    List<Map<String, String>> rows,
    List<Map<String, String>> headers,
    Map<String, String> summary,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    final pdfBytes = await generatePdf(type, title, rows, headers, summary, fromDate, toDate);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${title.replaceAll(' ', '_')}_Statement',
    );
  }

  static Future<Uint8List> generatePdf(
    StatementType type,
    String title,
    List<Map<String, String>> rows,
    List<Map<String, String>> headers,
    Map<String, String> summary,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final devanagariRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
    final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

    final pdfTheme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      fontFallback: [devanagariRegular, devanagariBold],
    );

    final pdf = pw.Document(theme: pdfTheme);
    final brandGreen = PdfColor.fromHex('#155d27');
    final lightGreenHeader = PdfColor.fromHex('#e8f5e9');
    final darkBorder = PdfColor.fromHex('#333333');

    final appData = AppData();
    final settings = appData.settings;
    final String companyTitle = settings.companyName.isNotEmpty
        ? settings.companyName
        : 'Ramgarm Seed Company (PVT) Ltd';

    final String dateRange;
    if (fromDate != null && toDate != null) {
      final fromBs = NepaliDate.fromDateTime(fromDate);
      final toBs = NepaliDate.fromDateTime(toDate);
      dateRange = '${fromBs.format()} to ${toBs.format()} BS (${_dateFmt.format(fromDate)} to ${_dateFmt.format(toDate)} AD)';
    } else {
      dateRange = 'All Dates';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: brandGreen,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  companyTitle,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Date Range: $dateRange',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                height: 1.5,
                color: brandGreen,
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Container(
                height: 0.8,
                color: brandGreen,
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Printed: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> children = [];

          if (headers.isNotEmpty && rows.isNotEmpty) {
            final colWidths = _calculateColumnWidths(headers.length);
            children.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerDecoration: pw.BoxDecoration(color: lightGreenHeader),
                headerAlignment: pw.Alignment.centerLeft,
                cellAlignment: pw.Alignment.centerLeft,
                headerPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                border: pw.TableBorder.all(color: darkBorder, width: 0.5),
                columnWidths: colWidths,
                headers: headers.map((h) => h['label'] ?? '').toList(),
                data: rows.map((row) => headers.map((h) => row[h['key']] ?? '').toList()).toList(),
              ),
            );
          }

          if (summary.isNotEmpty) {
            children.add(pw.SizedBox(height: 10));
            children.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: lightGreenHeader,
                  border: pw.Border.all(color: darkBorder, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: summary.entries.map((entry) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(entry.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                          pw.Text(entry.value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: brandGreen)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }

          return children;
        },
      ),
    );

    return pdf.save();
  }

  static Map<int, pw.FixedColumnWidth> _calculateColumnWidths(int count) {
    final totalWidth = 520.0;
    final perCol = totalWidth / count;
    final widths = <int, pw.FixedColumnWidth>{};
    for (var i = 0; i < count; i++) {
      widths[i] = pw.FixedColumnWidth(perCol);
    }
    return widths;
  }

  // ─── Data builders for each statement type ───

  static Map<String, dynamic> buildSalesData(
    List<SaleModel> sales,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    final filtered = sales.where((s) {
      if (fromDate != null && s.date.isBefore(fromDate)) return false;
      if (toDate != null && s.date.isAfter(toDate.add(const Duration(days: 1)))) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final headers = [
      {'key': 'date', 'label': 'Date'},
      {'key': 'invoice', 'label': 'Invoice #'},
      {'key': 'customer', 'label': 'Customer'},
      {'key': 'items', 'label': 'Items'},
      {'key': 'qty', 'label': 'Total Qty'},
      {'key': 'total', 'label': 'Total (Rs)'},
      {'key': 'paid', 'label': 'Paid (Rs)'},
      {'key': 'balance', 'label': 'Balance (Rs)'},
      {'key': 'status', 'label': 'Status'},
    ];

    final rows = filtered.map((s) {
      final itemsList = s.items.map((i) => i.product.name).join(', ');
      final totalQty = s.items.fold(0.0, (sum, i) => sum + i.quantity);
      return {
        'date': _dateFmt.format(s.date),
        'invoice': s.invoiceNumber,
        'customer': s.customerName,
        'items': itemsList.length > 40 ? '${itemsList.substring(0, 40)}...' : itemsList,
        'qty': totalQty.toStringAsFixed(2),
        'total': _currencyFmt.format(s.grandTotal),
        'paid': _currencyFmt.format(s.paidAmount),
        'balance': _currencyFmt.format(s.dueAmount),
        'status': s.status,
      };
    }).toList();

    final totalSales = filtered.fold(0.0, (sum, s) => sum + s.grandTotal);
    final totalPaid = filtered.fold(0.0, (sum, s) => sum + s.paidAmount);
    final totalBalance = filtered.fold(0.0, (sum, s) => sum + s.dueAmount);
    final totalQty = filtered.fold(0.0, (sum, s) => sum + s.items.fold(0.0, (qs, i) => qs + i.quantity));

    final summary = {
      'Total Invoices': '${filtered.length}',
      'Total Quantity': totalQty.toStringAsFixed(2),
      'Total Sales': 'Rs. ${_currencyFmt.format(totalSales)}',
      'Total Paid': 'Rs. ${_currencyFmt.format(totalPaid)}',
      'Total Outstanding': 'Rs. ${_currencyFmt.format(totalBalance)}',
    };

    return {'headers': headers, 'rows': rows, 'summary': summary};
  }

  static Map<String, dynamic> buildSupplierData(
    List<PurchaseModel> purchases,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    final filtered = purchases.where((p) {
      if (fromDate != null && p.date.isBefore(fromDate)) return false;
      if (toDate != null && p.date.isAfter(toDate.add(const Duration(days: 1)))) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final headers = [
      {'key': 'date', 'label': 'Date'},
      {'key': 'bill', 'label': 'Bill #'},
      {'key': 'supplier', 'label': 'Supplier'},
      {'key': 'items', 'label': 'Items'},
      {'key': 'qty', 'label': 'Total Qty'},
      {'key': 'total', 'label': 'Total (Rs)'},
      {'key': 'paid', 'label': 'Paid (Rs)'},
      {'key': 'balance', 'label': 'Balance (Rs)'},
      {'key': 'method', 'label': 'Payment'},
    ];

    final rows = filtered.map((p) {
      final itemsList = p.items.map((i) => i.product.name).join(', ');
      final totalQty = p.items.fold(0.0, (sum, i) => sum + i.quantity);
      return {
        'date': _dateFmt.format(p.date),
        'bill': p.invoiceNumber,
        'supplier': p.supplierName,
        'items': itemsList.length > 40 ? '${itemsList.substring(0, 40)}...' : itemsList,
        'qty': totalQty.toStringAsFixed(2),
        'total': _currencyFmt.format(p.grandTotal),
        'paid': _currencyFmt.format(p.paidAmount),
        'balance': _currencyFmt.format(p.dueAmount),
        'method': p.paymentMethod,
      };
    }).toList();

    final totalPurchases = filtered.fold(0.0, (sum, p) => sum + p.grandTotal);
    final totalPaid = filtered.fold(0.0, (sum, p) => sum + p.paidAmount);
    final totalBalance = filtered.fold(0.0, (sum, p) => sum + p.dueAmount);
    final totalQty = filtered.fold(0.0, (sum, p) => sum + p.items.fold(0.0, (qs, i) => qs + i.quantity));

    final summary = {
      'Total Bills': '${filtered.length}',
      'Total Quantity': totalQty.toStringAsFixed(2),
      'Total Purchases': 'Rs. ${_currencyFmt.format(totalPurchases)}',
      'Total Paid': 'Rs. ${_currencyFmt.format(totalPaid)}',
      'Total Outstanding': 'Rs. ${_currencyFmt.format(totalBalance)}',
    };

    return {'headers': headers, 'rows': rows, 'summary': summary};
  }

  static Map<String, dynamic> buildPurchaseSummaryData(
    List<PurchaseModel> purchases,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    final filtered = purchases.where((p) {
      if (fromDate != null && p.date.isBefore(fromDate)) return false;
      if (toDate != null && p.date.isAfter(toDate.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();

    final grouped = <String, List<PurchaseModel>>{};
    for (final p in filtered) {
      grouped.putIfAbsent(p.supplierName, () => []).add(p);
    }

    final headers = [
      {'key': 'supplier', 'label': 'Supplier Name'},
      {'key': 'bills', 'label': 'Total Bills'},
      {'key': 'qty', 'label': 'Total Qty'},
      {'key': 'total', 'label': 'Total Purchased (Rs)'},
      {'key': 'paid', 'label': 'Total Paid (Rs)'},
      {'key': 'balance', 'label': 'Outstanding (Rs)'},
      {'key': 'lastDate', 'label': 'Last Purchase'},
    ];

    final entries = grouped.entries.toList()..sort((a, b) => b.value.fold(0.0, (s, p) => s + p.dueAmount).compareTo(a.value.fold(0.0, (s, p) => s + p.dueAmount)));

    final rows = entries.map((entry) {
      final supplierPurchases = entry.value;
      final totalP = supplierPurchases.fold(0.0, (sum, p) => sum + p.grandTotal);
      final totalPd = supplierPurchases.fold(0.0, (sum, p) => sum + p.paidAmount);
      final totalBl = supplierPurchases.fold(0.0, (sum, p) => sum + p.dueAmount);
      final totalQ = supplierPurchases.fold(0.0, (sum, p) => sum + p.items.fold(0.0, (qs, i) => qs + i.quantity));
      final lastDate = supplierPurchases.map((p) => p.date).reduce((a, b) => a.isAfter(b) ? a : b);
      return {
        'supplier': entry.key,
        'bills': '${supplierPurchases.length}',
        'qty': totalQ.toStringAsFixed(2),
        'total': _currencyFmt.format(totalP),
        'paid': _currencyFmt.format(totalPd),
        'balance': _currencyFmt.format(totalBl),
        'lastDate': _dateFmt.format(lastDate),
      };
    }).toList();

    final grandTotal = filtered.fold(0.0, (sum, p) => sum + p.grandTotal);
    final grandPaid = filtered.fold(0.0, (sum, p) => sum + p.paidAmount);
    final grandBalance = filtered.fold(0.0, (sum, p) => sum + p.dueAmount);

    final summary = {
      'Total Suppliers': '${grouped.length}',
      'Total Bills': '${filtered.length}',
      'Grand Total Purchased': 'Rs. ${_currencyFmt.format(grandTotal)}',
      'Grand Total Paid': 'Rs. ${_currencyFmt.format(grandPaid)}',
      'Grand Outstanding': 'Rs. ${_currencyFmt.format(grandBalance)}',
    };

    return {'headers': headers, 'rows': rows, 'summary': summary};
  }

  static Map<String, dynamic> buildSoldOutData(
    List<SaleModel> sales,
    DateTime? fromDate,
    DateTime? toDate,
  ) {
    final filtered = sales.where((s) {
      if (fromDate != null && s.date.isBefore(fromDate)) return false;
      if (toDate != null && s.date.isAfter(toDate.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();

    final productMap = <String, Map<String, dynamic>>{};
    for (final sale in filtered) {
      for (final item in sale.items) {
        final key = item.product.name;
        if (!productMap.containsKey(key)) {
          productMap[key] = {
            'name': item.product.name,
            'unit': item.unit,
            'totalQty': 0.0,
            'totalRevenue': 0.0,
            'lastDate': sale.date,
            'saleCount': 0,
          };
        }
        final entry = productMap[key]!;
        entry['totalQty'] = (entry['totalQty'] as double) + item.quantity;
        entry['totalRevenue'] = (entry['totalRevenue'] as double) + item.lineTotal;
        entry['saleCount'] = (entry['saleCount'] as int) + 1;
        if (sale.date.isAfter(entry['lastDate'] as DateTime)) {
          entry['lastDate'] = sale.date;
        }
      }
    }

    final entries = productMap.entries.toList()
      ..sort((a, b) => (b.value['totalRevenue'] as double).compareTo(a.value['totalRevenue'] as double));

    final headers = [
      {'key': 'product', 'label': 'Product Name'},
      {'key': 'unit', 'label': 'Unit'},
      {'key': 'soldQty', 'label': 'Total Sold Qty'},
      {'key': 'revenue', 'label': 'Revenue (Rs)'},
      {'key': 'invoices', 'label': 'Invoices'},
      {'key': 'lastDate', 'label': 'Last Sold'},
    ];

    final rows = entries.map((entry) {
      final data = entry.value;
      return {
        'product': data['name'] as String,
        'unit': data['unit'] as String,
        'soldQty': (data['totalQty'] as double).toStringAsFixed(2),
        'revenue': _currencyFmt.format(data['totalRevenue'] as double),
        'invoices': '${data['saleCount']}',
        'lastDate': _dateFmt.format(data['lastDate'] as DateTime),
      };
    }).toList();

    final totalProducts = productMap.length;
    final totalQty = entries.fold(0.0, (sum, e) => sum + (e.value['totalQty'] as double));
    final totalRevenue = entries.fold(0.0, (sum, e) => sum + (e.value['totalRevenue'] as double));
    final totalInvoices = entries.fold(0, (sum, e) => sum + (e.value['saleCount'] as int));

    final summary = {
      'Total Products Sold': '$totalProducts',
      'Total Quantity Sold': totalQty.toStringAsFixed(2),
      'Total Invoices': '$totalInvoices',
      'Total Revenue': 'Rs. ${_currencyFmt.format(totalRevenue)}',
    };

    return {'headers': headers, 'rows': rows, 'summary': summary};
  }
}
