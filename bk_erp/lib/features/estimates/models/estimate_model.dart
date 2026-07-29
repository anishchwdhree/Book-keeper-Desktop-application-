import '../../billing/models/sale_model.dart';

class EstimateModel {
  final int? id;
  final String estimateNumber;
  final DateTime date;
  final DateTime? validUntil;
  final int? customerId;
  final String customerName;
  final List<SaleItemModel> items;
  final double subTotal;
  final double discountAmount;
  final double taxableAmount;
  final double vatAmount;
  final double grandTotal;
  final String status; // Draft, Sent, Accepted, Rejected, Converted, Expired
  final String notes;

  EstimateModel({
    this.id,
    required this.estimateNumber,
    required this.date,
    this.validUntil,
    this.customerId,
    this.customerName = 'Walk-in Customer',
    required this.items,
    required this.subTotal,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    required this.vatAmount,
    required this.grandTotal,
    this.status = 'Draft',
    this.notes = '',
  });

  EstimateModel copyWith({
    int? id,
    String? estimateNumber,
    DateTime? date,
    DateTime? validUntil,
    int? customerId,
    String? customerName,
    List<SaleItemModel>? items,
    double? subTotal,
    double? discountAmount,
    double? taxableAmount,
    double? vatAmount,
    double? grandTotal,
    String? status,
    String? notes,
  }) {
    return EstimateModel(
      id: id ?? this.id,
      estimateNumber: estimateNumber ?? this.estimateNumber,
      date: date ?? this.date,
      validUntil: validUntil ?? this.validUntil,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
