import '../../purchases/models/purchase_model.dart';

class PurchaseOrderModel {
  final int? id;
  final String poNumber;
  final DateTime date;
  final DateTime? expectedDate;
  final int? supplierId;
  final String supplierName;
  final List<PurchaseItemModel> items;
  final double subTotal;
  final double vatAmount;
  final double grandTotal;
  final String status; // Draft, Sent, Received, Cancelled
  final String notes;

  PurchaseOrderModel({
    this.id,
    required this.poNumber,
    required this.date,
    this.expectedDate,
    this.supplierId,
    required this.supplierName,
    required this.items,
    required this.subTotal,
    required this.vatAmount,
    required this.grandTotal,
    this.status = 'Draft',
    this.notes = '',
  });

  PurchaseOrderModel copyWith({
    int? id,
    String? poNumber,
    DateTime? date,
    DateTime? expectedDate,
    int? supplierId,
    String? supplierName,
    List<PurchaseItemModel>? items,
    double? subTotal,
    double? vatAmount,
    double? grandTotal,
    String? status,
    String? notes,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      date: date ?? this.date,
      expectedDate: expectedDate ?? this.expectedDate,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
