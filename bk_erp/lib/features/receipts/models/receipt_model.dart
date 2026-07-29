class ReceiptModel {
  final int? id;
  final DateTime date;
  final String receiptNumber;
  final int? customerId;
  final String customerName;
  final double amount;
  final String paymentMethod; // Cash, Bank Transfer, Cheque
  final String description;
  final int? saleId; // linked invoice if applicable
  final int? bankAccountId; // which bank account this receipt goes to

  ReceiptModel({
    this.id,
    DateTime? date,
    required this.receiptNumber,
    this.customerId,
    required this.customerName,
    required this.amount,
    this.paymentMethod = 'Cash',
    this.description = '',
    this.saleId,
    this.bankAccountId,
  }) : date = date ?? DateTime.now();

  ReceiptModel copyWith({
    int? id,
    DateTime? date,
    String? receiptNumber,
    int? customerId,
    String? customerName,
    double? amount,
    String? paymentMethod,
    String? description,
    int? saleId,
    int? bankAccountId,
  }) {
    return ReceiptModel(
      id: id ?? this.id,
      date: date ?? this.date,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      saleId: saleId ?? this.saleId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
    );
  }
}
