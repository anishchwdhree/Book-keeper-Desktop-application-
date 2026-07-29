import '../../billing/models/sale_model.dart';

class DeliveryNoteModel {
  final int? id;
  final String deliveryNumber;
  final DateTime date;
  final int? customerId;
  final String customerName;
  final List<SaleItemModel> items;
  final String vehicleNumber;
  final String driverName;
  final String status; // Dispatched, Delivered, Invoiced
  final String notes;

  DeliveryNoteModel({
    this.id,
    required this.deliveryNumber,
    required this.date,
    this.customerId,
    required this.customerName,
    required this.items,
    this.vehicleNumber = '',
    this.driverName = '',
    this.status = 'Dispatched',
    this.notes = '',
  });

  DeliveryNoteModel copyWith({
    int? id,
    String? deliveryNumber,
    DateTime? date,
    int? customerId,
    String? customerName,
    List<SaleItemModel>? items,
    String? vehicleNumber,
    String? driverName,
    String? status,
    String? notes,
  }) {
    return DeliveryNoteModel(
      id: id ?? this.id,
      deliveryNumber: deliveryNumber ?? this.deliveryNumber,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
