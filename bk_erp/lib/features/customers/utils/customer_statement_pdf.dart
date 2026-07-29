import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../models/customer_model.dart';
import 'package:flutter/material.dart' show BuildContext;

class CustomerStatementPdfGenerator {
  static Future<void> printStatement(BuildContext context, CustomerModel customer, AppSettings settings, List<Map<String, dynamic>> ledger) async {
    final pdfBytes = await generatePdf(customer, settings, ledger);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Statement_${customer.name.replaceAll(' ', '_')}',
    );
  }

  static Future<Uint8List> generatePdf(CustomerModel customer, AppSettings settings, List<Map<String, dynamic>> ledger) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
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
                      if (settings.companyAddress.isNotEmpty) pw.Text(settings.companyAddress),
                      if (settings.companyPhone.isNotEmpty) pw.Text('Ph: ${settings.companyPhone}'),
                      if (settings.companyVatPAN.isNotEmpty) pw.Text('VAT/PAN: ${settings.companyVatPAN}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('CUSTOMER STATEMENT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 8),
                      pw.Text('Date Generated: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('To:', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                    pw.Text(customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    if (customer.address.isNotEmpty) pw.Text(customer.address),
                    if (customer.phone.isNotEmpty) pw.Text('Phone: ${customer.phone}'),
                    if (customer.vatNumber.isNotEmpty) pw.Text('VAT/PAN: ${customer.vatNumber}'),
                  ]
                ),
              ),
              pw.SizedBox(height: 24),
            ],
          );
        },
        build: (pw.Context context) {
          double runningBalance = 0.0;
          
          return [
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Type', 'Ref #', 'Debit (Rs)', 'Credit (Rs)', 'Balance (Rs)'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
              data: ledger.map((entry) {
                final date = DateFormat('yyyy-MM-dd').format(entry['date'] as DateTime);
                final type = entry['type'] as String;
                final ref = entry['ref'] as String;
                final debit = entry['debit'] as double;
                final credit = entry['credit'] as double;
                runningBalance += debit - credit;
                
                return [
                  date,
                  type,
                  ref,
                  debit > 0 ? debit.toStringAsFixed(2) : '',
                  credit > 0 ? credit.toStringAsFixed(2) : '',
                  runningBalance.toStringAsFixed(2)
                ];
              }).toList(),
            ),
            
            pw.SizedBox(height: 24),
            
            // Closing balance summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue900, width: 2),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Closing Balance:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text(
                        'Rs. ${customer.outstandingBalance.toStringAsFixed(2)}', 
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, 
                          fontSize: 14,
                          color: customer.outstandingBalance > 0 ? PdfColors.red : PdfColors.green
                        )
                      ),
                    ]
                  )
                )
              ]
            ),
            
            pw.SizedBox(height: 48),
            
            // Auth Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
      )
    );

    return pdf.save();
  }
}
