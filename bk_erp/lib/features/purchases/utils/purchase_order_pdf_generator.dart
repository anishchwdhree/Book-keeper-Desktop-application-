import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../models/purchase_order_model.dart';
import 'package:flutter/material.dart' show BuildContext;

class PurchaseOrderPdfGenerator {
  static Future<void> printPO(BuildContext context, PurchaseOrderModel po, AppSettings settings) async {
    final pdfBytes = await generatePdf(po, settings);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'PO_${po.poNumber}',
    );
  }

  static Future<Uint8List> generatePdf(PurchaseOrderModel po, AppSettings settings) async {
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
                      pw.Text('PURCHASE ORDER', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.SizedBox(height: 8),
                      pw.Text('PO #: ${po.poNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(po.date)}'),
                      if (po.expectedDate != null)
                        pw.Text('Expected Delivery: ${DateFormat('yyyy-MM-dd').format(po.expectedDate!)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Supplier Info
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
                          pw.Text('Order From (Supplier):', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                          pw.SizedBox(height: 2),
                          pw.Text(po.supplierName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          if (po.supplierId != null)
                            pw.Text('Supplier ID: ${po.supplierId}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Items Table
              pw.TableHelper.fromTextArray(
                headers: ['S.N.', 'Item Description', 'Qty', 'Est. Unit Cost (Rs)', 'Est. Total (Rs)'],
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                },
                data: List<List<String>>.generate(
                  po.items.length,
                  (index) {
                    final item = po.items[index];
                    return [
                      '${index + 1}',
                      item.product.name,
                      item.quantity.toString(),
                      item.unitCost.toStringAsFixed(2),
                      (item.quantity * item.unitCost).toStringAsFixed(2),
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
                            pw.Text('Est. Sub Total:'),
                            pw.Text('Rs ${po.subTotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Est. Tax (13% VAT):'),
                            pw.Text('Rs ${po.vatAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Est. Grand Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            pw.Text('Rs ${po.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (po.notes.isNotEmpty) ...[
                pw.SizedBox(height: 24),
                pw.Text('Notes & Instructions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(po.notes, style: const pw.TextStyle(fontSize: 10)),
              ],
              
              pw.Spacer(),
              
              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                    ]
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
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
