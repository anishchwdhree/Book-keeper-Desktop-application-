class PaymentModel {
  final int? id;
  final DateTime date;
  final String paymentNumber;
  final int? supplierId;
  final String supplierName;
  final double amount;
  final String paymentMethod; // Cash, Bank Transfer, Cheque
  final String description;
  final int? bankAccountId; // which bank account this payment comes from

  PaymentModel({
    this.id,
    DateTime? date,
    required this.paymentNumber,
    this.supplierId,
    required this.supplierName,
    required this.amount,
    this.paymentMethod = 'Cash',
    this.description = '',
    this.bankAccountId,
  }) : date = date ?? DateTime.now();

  PaymentModel copyWith({
    int? id,
    DateTime? date,
    String? paymentNumber,
    int? supplierId,
    String? supplierName,
    double? amount,
    String? paymentMethod,
    String? description,
    int? bankAccountId,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      date: date ?? this.date,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      bankAccountId: bankAccountId ?? this.bankAccountId,
    );
  }
}
