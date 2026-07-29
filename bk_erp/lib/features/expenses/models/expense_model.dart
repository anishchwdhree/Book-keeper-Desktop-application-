class ExpenseModel {
  final int? id;
  final DateTime date;
  final String expenseNumber;
  final String category;
  final String description;
  final double amount;
  final String paymentMethod;
  final int? bankAccountId;
  final String paidTo;
  final String chequeNumber;

  ExpenseModel({
    this.id,
    DateTime? date,
    required this.expenseNumber,
    this.category = 'General',
    this.description = '',
    required this.amount,
    this.paymentMethod = 'Cash',
    this.bankAccountId,
    this.paidTo = '',
    this.chequeNumber = '',
  }) : date = date ?? DateTime.now();

  ExpenseModel copyWith({
    int? id,
    DateTime? date,
    String? expenseNumber,
    String? category,
    String? description,
    double? amount,
    String? paymentMethod,
    int? bankAccountId,
    String? paidTo,
    String? chequeNumber,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      date: date ?? this.date,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      paidTo: paidTo ?? this.paidTo,
      chequeNumber: chequeNumber ?? this.chequeNumber,
    );
  }
}
