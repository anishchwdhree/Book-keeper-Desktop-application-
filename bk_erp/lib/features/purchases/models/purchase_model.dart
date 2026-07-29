import '../../inventory/models/product_model.dart';

class PurchaseItemModel {
  final ProductModel product;
  final double quantity;
  final double unitCost;
  final String unit; // Quintal, Kuntal, Bag, Kg - what unit was purchased
  final double discountPercent;
  final double discountAmount;
  final double vatPercent;
  final double vatAmount;

  PurchaseItemModel({
    required this.product,
    required this.quantity,
    required this.unitCost,
    this.unit = 'Quintal',
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.vatPercent = 0.0,
    this.vatAmount = 0.0,
  });

  double get grossTotal => quantity * unitCost;
  double get taxableAmount => grossTotal - discountAmount;
  double get lineTotal => taxableAmount + vatAmount;

  // Convert quantity to Kg for stock management
  double get quantityInKg => ProductModel.convertUnit(quantity, unit, 'Kg');
}

class PurchaseModel {
  final int? id;
  final String invoiceNumber;
  final DateTime date;
  final String miti;
  final String supplierName;
  final int? supplierId;
  final List<PurchaseItemModel> items;
  final double subTotal;
  final double discountAmount;
  final double taxableAmount;
  final double vatAmount;
  final double grandTotal;
  final String notes;
  final String paymentMethod; // Cash, Bank Transfer, Cheque, Credit
  final int? bankAccountId;
  final double paidAmount; // Amount paid at time of purchase

  PurchaseModel({
    this.id,
    required this.invoiceNumber,
    required this.date,
    this.miti = '',
    required this.supplierName,
    this.supplierId,
    required this.items,
    required this.subTotal,
    this.discountAmount = 0.0,
    this.taxableAmount = 0.0,
    required this.vatAmount,
    required this.grandTotal,
    this.notes = '',
    this.paymentMethod = 'Cash',
    this.bankAccountId,
    this.paidAmount = 0.0,
  });

  double get dueAmount => (grandTotal - paidAmount).clamp(0, double.infinity);

  // Total quantity in Kg across all items
  double get totalQuantityInKg =>
      items.fold(0.0, (sum, item) => sum + item.quantityInKg);

  PurchaseModel copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? date,
    String? miti,
    String? supplierName,
    int? supplierId,
    List<PurchaseItemModel>? items,
    double? subTotal,
    double? discountAmount,
    double? taxableAmount,
    double? vatAmount,
    double? grandTotal,
    String? notes,
    String? paymentMethod,
    int? bankAccountId,
    double? paidAmount,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      miti: miti ?? this.miti,
      supplierName: supplierName ?? this.supplierName,
      supplierId: supplierId ?? this.supplierId,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
