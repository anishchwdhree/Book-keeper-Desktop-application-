import '../../purchases/models/purchase_model.dart';

class PurchaseReturnModel {
  final int? id;
  final String returnNumber;
  final DateTime date;
  final int? supplierId;
  final String supplierName;
  final String originalInvoiceNumber;
  final List<PurchaseItemModel> items;
  final double subTotal;
  final double vatAmount;
  final double grandTotal;
  final String reason;
  final String notes;

  PurchaseReturnModel({
    this.id,
    required this.returnNumber,
    required this.date,
    this.supplierId,
    required this.supplierName,
    required this.originalInvoiceNumber,
    required this.items,
    required this.subTotal,
    required this.vatAmount,
    required this.grandTotal,
    required this.reason,
    this.notes = '',
  });

  PurchaseReturnModel copyWith({
    int? id,
    String? returnNumber,
    DateTime? date,
    int? supplierId,
    String? supplierName,
    String? originalInvoiceNumber,
    List<PurchaseItemModel>? items,
    double? subTotal,
    double? vatAmount,
    double? grandTotal,
    String? reason,
    String? notes,
  }) {
    return PurchaseReturnModel(
      id: id ?? this.id,
      returnNumber: returnNumber ?? this.returnNumber,
      date: date ?? this.date,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      originalInvoiceNumber: originalInvoiceNumber ?? this.originalInvoiceNumber,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
    );
  }
}
