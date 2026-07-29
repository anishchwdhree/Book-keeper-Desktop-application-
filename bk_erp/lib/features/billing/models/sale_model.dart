import '../../inventory/models/product_model.dart';

class SaleItemModel {
  final ProductModel product;
  final double quantity;
  final double unitPrice;
  final String unit; // Kg, Kuntal, Bag - what unit was sold

  SaleItemModel({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.unit = 'Kg',
  });

  double get lineTotal => quantity * unitPrice;

  // Convert quantity to Kg for stock management
  double get quantityInKg => ProductModel.convertUnit(quantity, unit, 'Kg');
}

class SaleModel {
  final int? id;
  final String invoiceNumber;
  final DateTime date;
  final String miti;
  final DateTime? dueDate;
  final int? customerId;
  final String customerName;
  final String customerVat;
  final List<SaleItemModel> items;
  final double subTotal;
  final double discountAmount;
  final double taxableAmount;
  final double vatAmount;
  final double grandTotal;
  final double paidAmount;
  
  final bool isRecurring;
  final String recurringInterval;
  final DateTime? nextDueDate;

  final String paymentMethod;
  final String paymentTerms;
  final String status;
  final String notes;
  final int? bankAccountId; // which bank account this sale goes to
  final String chequeNumber;
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;

  String get safeBankName => bankName ?? '';
  String get safeAccountHolder => accountHolder ?? '';
  String get safeAccountNumber => accountNumber ?? '';

  SaleModel({
    this.id,
    required this.invoiceNumber,
    required this.date,
    this.miti = '',
    this.dueDate,
    this.customerId,
    this.customerName = 'Walk-in Customer',
    this.customerVat = '',
    required this.items,
    required this.subTotal,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    required this.vatAmount,
    required this.grandTotal,
    this.paidAmount = 0.0,
    this.isRecurring = false,
    this.recurringInterval = 'Monthly',
    this.nextDueDate,
    this.paymentMethod = 'Cash',
    this.paymentTerms = 'Cash',
    this.status = 'Paid',
    this.notes = '',
    this.bankAccountId,
    this.chequeNumber = '',
    this.bankName = '',
    this.accountHolder = '',
    this.accountNumber = '',
  });

  bool get isOverdue {
    if (status == 'Paid') return false;
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Outstanding amount for this specific sale
  double get dueAmount {
    if (paymentMethod == 'Credit') return grandTotal;
    return (grandTotal - paidAmount).clamp(0.0, double.infinity);
  }

  // Total quantity in Kg across all items
  double get totalQuantityInKg =>
      items.fold(0.0, (sum, item) => sum + item.quantityInKg);

  SaleModel copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? date,
    String? miti,
    DateTime? dueDate,
    int? customerId,
    String? customerName,
    String? customerVat,
    List<SaleItemModel>? items,
    double? subTotal,
    double? discountAmount,
    double? taxableAmount,
    double? vatAmount,
    double? grandTotal,
    double? paidAmount,
    bool? isRecurring,
    String? recurringInterval,
    DateTime? nextDueDate,
    String? paymentMethod,
    String? paymentTerms,
    String? status,
    String? notes,
    int? bankAccountId,
    String? chequeNumber,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
  }) {
    return SaleModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      miti: miti ?? this.miti,
      dueDate: dueDate ?? this.dueDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerVat: customerVat ?? this.customerVat,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      chequeNumber: chequeNumber ?? this.chequeNumber,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}
