import '../../billing/models/sale_model.dart';

class ReturnModel {
  final int? id;
  final String returnNumber;
  final DateTime date;
  final int? customerId;
  final String customerName;
  final String originalInvoiceNumber;
  final List<SaleItemModel> items; // reusing SaleItemModel for simplicity
  final double subTotal;
  final double vatAmount;
  final double grandTotal;
  final String reason;

  ReturnModel({
    this.id,
    required this.returnNumber,
    required this.date,
    this.customerId,
    required this.customerName,
    required this.originalInvoiceNumber,
    required this.items,
    required this.subTotal,
    required this.vatAmount,
    required this.grandTotal,
    required this.reason,
  });

  ReturnModel copyWith({
    int? id,
    String? returnNumber,
    DateTime? date,
    int? customerId,
    String? customerName,
    String? originalInvoiceNumber,
    List<SaleItemModel>? items,
    double? subTotal,
    double? vatAmount,
    double? grandTotal,
    String? reason,
  }) {
    return ReturnModel(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      originalInvoiceNumber: originalInvoiceNumber ?? this.originalInvoiceNumber,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      reason: reason ?? this.reason,
    );
  }
}
