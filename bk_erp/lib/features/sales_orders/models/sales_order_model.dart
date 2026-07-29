import '../../billing/models/sale_model.dart';

class SalesOrderModel {
  final int? id;
  final String soNumber;
  final DateTime date;
  final int? customerId;
  final String customerName;
  final List<SaleItemModel> items;
  final double subTotal;
  final double discountAmount;
  final double vatAmount;
  final double grandTotal;
  final String status; // Draft, Confirmed, Fulfilled
  final String notes;

  SalesOrderModel({
    this.id,
    required this.soNumber,
    required this.date,
    this.customerId,
    required this.customerName,
    required this.items,
    required this.subTotal,
    this.discountAmount = 0,
    required this.vatAmount,
    required this.grandTotal,
    this.status = 'Draft',
    this.notes = '',
  });

  SalesOrderModel copyWith({
    int? id,
    String? soNumber,
    DateTime? date,
    int? customerId,
    String? customerName,
    List<SaleItemModel>? items,
    double? subTotal,
    double? discountAmount,
    double? vatAmount,
    double? grandTotal,
    String? status,
    String? notes,
  }) {
    return SalesOrderModel(
      id: id ?? this.id,
      soNumber: soNumber ?? this.soNumber,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
