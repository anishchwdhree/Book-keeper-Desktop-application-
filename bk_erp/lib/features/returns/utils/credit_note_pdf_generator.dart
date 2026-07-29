import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../models/return_model.dart';
import '../../customers/models/customer_model.dart'; // Add customer model import

class CreditNotePdfGenerator {
  static Future<Uint8List> generate(ReturnModel creditNote) async {
    final pdf = pw.Document();
    final appData = AppData();
    final settings = appData.settings;
    final nf = NumberFormat.currency(locale: 'en_NP', symbol: 'Rs. ');
    final qtyFormat = NumberFormat('#,##0.##');

    // Fetch customer details
    CustomerModel? customer;
    if (creditNote.customerId != null) {
      final idx = appData.customers.indexWhere((c) => c.id == creditNote.customerId);
      if (idx != -1) customer = appData.customers[idx];
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => _buildHeader(settings, creditNote, customer),
        build: (pw.Context context) => [
          pw.SizedBox(height: 20),
          _buildItemTable(creditNote, nf, qtyFormat),
          pw.SizedBox(height: 20),
          _buildTotalsMatch(creditNote, nf),
          pw.SizedBox(height: 40),
          _buildTermsAndSignatures(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(AppSettings settings, ReturnModel creditNote, CustomerModel? customer) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(settings.companyName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 4),
                pw.Text(settings.companyAddress, style: const pw.TextStyle(fontSize: 12)),
                if (settings.companyPhone.isNotEmpty) pw.Text('Phone: ${settings.companyPhone}', style: const pw.TextStyle(fontSize: 12)),
                if (settings.companyVatPAN.isNotEmpty) pw.Text('VAT/PAN: ${settings.companyVatPAN}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('CREDIT NOTE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 8),
                pw.Text('CN Number: ${creditNote.returnNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('Date: ${DateFormat('MMM dd, yyyy').format(creditNote.date)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Original Inv: ${creditNote.originalInvoiceNumber}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('CREDIT TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(creditNote.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            if (customer != null && customer.address.isNotEmpty) pw.Text(customer.address, style: const pw.TextStyle(fontSize: 12)),
            if (customer != null && customer.phone.isNotEmpty) pw.Text('Phone: ${customer.phone}', style: const pw.TextStyle(fontSize: 12)),
            if (customer != null && customer.vatNumber.isNotEmpty) pw.Text('VAT/PAN: ${customer.vatNumber}', style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildItemTable(ReturnModel creditNote, NumberFormat nf, NumberFormat qf) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellStyle: const pw.TextStyle(fontSize: 11),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      headers: ['S.N.', 'Item / Description', 'Return Qty', 'Rate', 'Amount'],
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2.5),
      },
      data: List<List<String>>.generate(creditNote.items.length, (index) {
        final item = creditNote.items[index];
        return [
          '${index + 1}',
          item.product.name,
          '${qf.format(item.quantity)} ${item.product.unit}',
          nf.format(item.unitPrice),
          nf.format(item.lineTotal),
        ];
      }),
    );
  }

  static pw.Widget _buildTotalsMatch(ReturnModel creditNote, NumberFormat nf) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 6,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reason for Return:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 4),
              pw.Text(creditNote.reason.isNotEmpty ? creditNote.reason : 'Goods returned', style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Sub Total:', style: const pw.TextStyle(fontSize: 11)), pw.Text(nf.format(creditNote.subTotal), style: const pw.TextStyle(fontSize: 11))],
                ),
                if (creditNote.vatAmount > 0) pw.Divider(color: PdfColors.grey300),
                if (creditNote.vatAmount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [pw.Text('VAT (13%):', style: const pw.TextStyle(fontSize: 11)), pw.Text(nf.format(creditNote.vatAmount), style: const pw.TextStyle(fontSize: 11))],
                  ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Credit Value:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900)),
                      pw.Text(nf.format(creditNote.grandTotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTermsAndSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Note:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.SizedBox(height: 4),
            pw.Text('This is a system generated credit note.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            pw.Text('Authorized Signatory', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
