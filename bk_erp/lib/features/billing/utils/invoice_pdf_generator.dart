import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_data.dart';
import '../models/sale_model.dart';
import '../../customers/models/customer_model.dart';
import 'package:flutter/material.dart' show BuildContext;

class InvoicePdfGenerator {
  static String _convertIntegerToWords(int n) {
    final List<String> units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    if (n < 20) return units[n];
    if (n < 100) {
      return '${tens[n ~/ 10]}${n % 10 > 0 ? " ${units[n % 10]}" : ""}';
    }
    if (n < 1000) {
      return '${units[n ~/ 100]} Hundred${n % 100 > 0 ? " ${_convertIntegerToWords(n % 100)}" : ""}';
    }
    if (n < 100000) {
      return '${_convertIntegerToWords(n ~/ 1000)} Thousand${n % 1000 > 0 ? " ${_convertIntegerToWords(n % 1000)}" : ""}';
    }
    if (n < 10000000) {
      return '${_convertIntegerToWords(n ~/ 100000)} Lakh${n % 100000 > 0 ? " ${_convertIntegerToWords(n % 100000)}" : ""}';
    }
    return '${_convertIntegerToWords(n ~/ 10000000)} Crore${n % 10000000 > 0 ? " ${_convertIntegerToWords(n % 10000000)}" : ""}';
  }

  static String _amountToWords(double amount) {
    final int wholePart = amount.floor();
    final int paisa = ((amount - wholePart) * 100).round();

    if (wholePart == 0 && paisa == 0) return 'Zero Only';

    String words = _convertIntegerToWords(wholePart);
    if (words.isEmpty) words = 'Zero';

    if (paisa > 0) {
      words += ' and ${_convertIntegerToWords(paisa)} Paisa';
    }
    return '$words Only';
  }

  static Future<void> printInvoice(
    BuildContext context,
    SaleModel sale,
    AppSettings settings,
  ) async {
    final pdfBytes = await generatePdf(sale, settings);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'TaxInvoice_${sale.invoiceNumber}',
    );
  }

  static Future<Uint8List> generatePdf(
    SaleModel sale,
    AppSettings settings,
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

    // Get full customer info if available
    final appData = AppData();
    CustomerModel? customer;
    if (sale.customerId != null) {
      try {
        customer = appData.customers.firstWhere((c) => c.id == sale.customerId);
      } catch (_) {}
    }
    if (customer == null &&
        sale.customerName.isNotEmpty &&
        sale.customerName != 'Walk-in Customer') {
      try {
        customer = appData.customers.firstWhere(
          (c) => c.name == sale.customerName,
        );
      } catch (_) {}
    }

    String title = (settings.companyName.isNotEmpty)
        ? settings.companyName
        : 'Ramgarm Seed Company (PVT) Ltd';
    if (!title.toUpperCase().contains('PVT')) {
      title = '$title (PVT) Ltd';
    }
    final String companyTitle = title;
    final String companyAddr = (settings.companyAddress.isNotEmpty)
        ? settings.companyAddress
        : 'Ramgram-10-Laxmipur,Nawalparasi';
    final String companyPh = (settings.companyPhone.isNotEmpty)
        ? settings.companyPhone
        : '9804728321';
    // companyEmail may be null for settings created before this field was added
    final String rawEmail = (() {
      try {
        return settings.companyEmail;
      } catch (_) {
        return '';
      }
    })();
    final String companyEmail = rawEmail.isNotEmpty
        ? rawEmail
        : 'ramgramseedcompany@gmail.com';
    final String companyPan = (settings.companyVatPAN.isNotEmpty)
        ? settings.companyVatPAN
        : '302013496';

    final String inWordsText = _amountToWords(sale.grandTotal);
    final String printDateTimeStr = DateFormat(
      'MM/dd/yyyy h:mm:ss a',
    ).format(DateTime.now());
    final NumberFormat currencyFmt = NumberFormat('#,##,##0.00', 'en_US');

    // Theme Colors matching Universal / Ramgram seed tax invoice layout
    final brandGreen = PdfColor.fromHex('#155d27');
    final lightGreenHeader = PdfColor.fromHex('#e8f5e9');
    final darkBorder = PdfColor.fromHex('#333333');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER & BRANDING
              pw.Center(
                child: pw.Text(
                  'Tax Invoice',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo Container / Icon
                  pw.Container(
                    width: 48,
                    height: 48,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: brandGreen, width: 1.5),
                      color: lightGreenHeader,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'RSC',
                        style: pw.TextStyle(
                          color: brandGreen,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Company Main Title & Details
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          companyTitle.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: brandGreen,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          companyAddr,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.black,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        if (companyPh.isNotEmpty)
                          pw.Text(
                            'Phone No. $companyPh',
                            style: const pw.TextStyle(
                              fontSize: 9.5,
                              color: PdfColors.grey800,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Print Date (Right Aligned)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Print Date : $printDateTimeStr',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),

              // 2. TWO-COLUMN METADATA GRID BOX
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: darkBorder, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildGridRow('PAN No.', companyPan),
                          _buildGridRow('Invoice No.', sale.invoiceNumber),
                          _buildGridRow('Customer Name', sale.customerName),
                          _buildGridRow(
                            'Address',
                            customer?.address.isNotEmpty == true
                                ? customer!.address
                                : companyAddr,
                          ),
                          _buildGridRow(
                            'Phone No.',
                            customer?.phone.isNotEmpty == true
                                ? customer!.phone
                                : '-',
                          ),
                          _buildGridRow('Site', '-'),
                          _buildGridRow(
                            'Customer PAN No.',
                            customer?.vatNumber.isNotEmpty == true
                                ? customer!.vatNumber
                                : (sale.customerVat.isNotEmpty
                                      ? sale.customerVat
                                      : '-'),
                          ),
                          _buildGridRow(
                            'Payment Mode',
                            sale.status == 'Partial'
                                ? 'Partial (${sale.paymentMethod})'
                                : (sale.paymentMethod == 'Credit'
                                    ? 'Credit (Unpaid)'
                                    : sale.paymentMethod),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    // Vertical Divider
                    pw.Container(
                      width: 0.5,
                      height: 110,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(width: 12),
                    // Right Column
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildGridRow(
                            'Invoice Miti',
                            sale.miti.isNotEmpty ? sale.miti : '-',
                          ),
                          _buildGridRow(
                            'Invoice Date',
                            DateFormat('yyyy/MM/dd').format(sale.date),
                          ),
                          _buildGridRow('Truck No.', '-'),
                          _buildGridRow('Transporter', '-'),
                          _buildGridRow('Address', '-'),
                          _buildGridRow('Driver Name', '-'),
                          _buildGridRow('Phone No.', '-'),
                          _buildGridRow('Delivery Through', '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // 3. PARTICULARS TABLE
              // Item Header & Data Rows Table
              pw.Table(
                border: pw.TableBorder.all(color: darkBorder, width: 0.8),
                columnWidths: const {
                  0: pw.FixedColumnWidth(38),
                  1: pw.FlexColumnWidth(4),
                  2: pw.FixedColumnWidth(65),
                  3: pw.FixedColumnWidth(45),
                  4: pw.FixedColumnWidth(80),
                  5: pw.FixedColumnWidth(90),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightGreenHeader),
                    children: [
                      _tableHeaderCell('S.No.'),
                      _tableHeaderCell('Particulars', alignLeft: true),
                      _tableHeaderCell('QTY'),
                      _tableHeaderCell('Unit'),
                      _tableHeaderCell('Rate'),
                      _tableHeaderCell('Amount'),
                    ],
                  ),
                  ...sale.items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        _tableDataCell('$idx', center: true),
                        _tableDataCell(item.product.name, alignLeft: true),
                        _tableDataCell(
                          item.quantity.toStringAsFixed(
                            item.quantity % 1 == 0 ? 0 : 3,
                          ),
                        ),
                        _tableDataCell(item.unit, center: true),
                        _tableDataCell(currencyFmt.format(item.unitPrice)),
                        _tableDataCell(
                          currencyFmt.format(item.lineTotal),
                          bold: true,
                        ),
                      ],
                    );
                  }),
                ],
              ),
              // Empty rows area — vertical column dividers only
              pw.Container(
                height: 140,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColors.black, width: 0.8),
                    right: pw.BorderSide(color: PdfColors.black, width: 0.8),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 38,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(
                            color: PdfColors.black,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(
                              color: PdfColors.black,
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 65,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(
                            color: PdfColors.black,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 45,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(
                            color: PdfColors.black,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 80,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(
                            color: PdfColors.black,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    pw.Container(width: 90),
                  ],
                ),
              ),
              // Total Summary Row — placed at the bottom of the table grid
              pw.Table(
                border: pw.TableBorder.all(color: darkBorder, width: 0.8),
                columnWidths: const {
                  0: pw.FixedColumnWidth(38),
                  1: pw.FlexColumnWidth(4),
                  2: pw.FixedColumnWidth(65),
                  3: pw.FixedColumnWidth(45),
                  4: pw.FixedColumnWidth(80),
                  5: pw.FixedColumnWidth(90),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightGreenHeader),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(
                          child: pw.Text(
                            sale.items
                                .fold(0.0, (s, i) => s + i.quantity)
                                .toStringAsFixed(3),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ),
                      _tableDataCell('', center: true),
                      _tableDataCell('', center: true),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            currencyFmt.format(sale.grandTotal),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(
                          child: pw.Text(
                            'Amount Paid',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      _tableDataCell('', center: true),
                      _tableDataCell('', center: true),
                      _tableDataCell('', center: true),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            currencyFmt.format(sale.paidAmount),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // 4. NARRATION VALUE & IN WORDS (With requested "RS" prefix!)
              if (sale.notes.isNotEmpty) ...[
                pw.Text(
                  'Narration Value: ${sale.notes}',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 4),
              ],

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: const PdfColor(0.96, 0.96, 0.96),
                  border: pw.Border.all(color: darkBorder, width: 0.6),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(2),
                  ),
                ),
                child: pw.Text(
                  'In Words:$inWordsText',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: brandGreen,
                  ),
                ),
              ),
              pw.Spacer(),

              // 5. SIGNATURE / AUTHORIZATION SECTION (ANCHORED AT BOTTOM)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // Prepared By Column (No line)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Admin',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Prepared By',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Checked By Column (No line)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.SizedBox(height: 34),
                          pw.Text(
                            'Checked By',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Authorized Signatory Column (With line)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'For: ${companyTitle.toUpperCase()}',
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Container(
                            width: 140,
                            height: 0.8,
                            color: darkBorder,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Authorized Signatory',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              // 6. BOTTOM FOOTER BAR WITH ICONS / CONTACT DETAILS
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: brandGreen, width: 1.2),
                  ),
                ),
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'Addr: $companyAddr',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Ph: $companyPh',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Email: $companyEmail',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildGridRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 95,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
              maxLines: 2,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableHeaderCell(String text, {bool alignLeft = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Align(
        alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ),
    );
  }

  static pw.Widget _tableDataCell(
    String text, {
    bool center = false,
    bool alignLeft = false,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Align(
        alignment: alignLeft
            ? pw.Alignment.centerLeft
            : (center ? pw.Alignment.center : pw.Alignment.centerRight),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.black,
          ),
        ),
      ),
    );
  }
}
