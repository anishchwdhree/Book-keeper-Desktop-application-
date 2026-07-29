class ContraEntryModel {
  final int? id;
  final String contraNumber;
  final DateTime date;
  final String fromAccount; // 'Cash' or 'Bank'
  final String toAccount;   // 'Cash' or 'Bank'
  final double amount;
  final String narration;

  ContraEntryModel({
    this.id,
    required this.contraNumber,
    required this.date,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    this.narration = '',
  });

  ContraEntryModel copyWith({
    int? id,
    String? contraNumber,
    DateTime? date,
    String? fromAccount,
    String? toAccount,
    double? amount,
    String? narration,
  }) {
    return ContraEntryModel(
      id: id ?? this.id,
      contraNumber: contraNumber ?? this.contraNumber,
      date: date ?? this.date,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      amount: amount ?? this.amount,
      narration: narration ?? this.narration,
    );
  }
}
