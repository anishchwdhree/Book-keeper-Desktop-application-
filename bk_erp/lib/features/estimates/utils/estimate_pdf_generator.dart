import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../models/estimate_model.dart';
import 'package:flutter/material.dart' show BuildContext;

class EstimatePdfGenerator {
  static Future<void> printEstimate(BuildContext context, EstimateModel estimate, AppSettings settings) async {
    final pdfBytes = await generatePdf(estimate, settings);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Estimate_${estimate.estimateNumber}',
    );
  }

  static Future<Uint8List> generatePdf(EstimateModel estimate, AppSettings settings) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Series
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
                      pw.Text('ESTIMATE / QUOTATION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 8),
                      pw.Text('Estimate #: ${estimate.estimateNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(estimate.date)}'),
                      if (estimate.validUntil != null)
                        pw.Text('Valid Until: ${DateFormat('yyyy-MM-dd').format(estimate.validUntil!)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Customer Info
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Quotation To:', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                          pw.SizedBox(height: 2),
                          pw.Text(estimate.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          if (estimate.customerId != null)
                            pw.Text('Customer ID: ${estimate.customerId}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Items Table
              pw.TableHelper.fromTextArray(
                headers: ['S.N.', 'Item Description', 'Qty', 'Rate (Rs)', 'Total (Rs)'],
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                },
                data: List<List<String>>.generate(
                  estimate.items.length,
                  (index) {
                    final item = estimate.items[index];
                    return [
                      '${index + 1}',
                      item.product.name,
                      item.quantity.toString(),
                      item.unitPrice.toStringAsFixed(2),
                      item.lineTotal.toStringAsFixed(2),
                    ];
                  },
                ),
              ),
              pw.SizedBox(height: 24),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Sub Total:'),
                            pw.Text('Rs ${estimate.subTotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Discount:'),
                            pw.Text('Rs ${estimate.discountAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Tax (13% VAT):'),
                            pw.Text('Rs ${estimate.vatAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Est. Grand Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            pw.Text('Rs ${estimate.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (estimate.notes.isNotEmpty) ...[
                pw.SizedBox(height: 24),
                pw.Text('Terms & Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(estimate.notes, style: const pw.TextStyle(fontSize: 10)),
              ],
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('This is a quotation, not an invoice.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('Generated by BK ERP', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
