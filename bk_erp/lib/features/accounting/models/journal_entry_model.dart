class JournalEntryModel {
  final int? id;
  final String journalNumber;
  final DateTime date;
  final String debitAccount;
  final String creditAccount;
  final double amount;
  final String narration;

  JournalEntryModel({
    this.id,
    required this.journalNumber,
    required this.date,
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    this.narration = '',
  });

  JournalEntryModel copyWith({
    int? id,
    String? journalNumber,
    DateTime? date,
    String? debitAccount,
    String? creditAccount,
    double? amount,
    String? narration,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      journalNumber: journalNumber ?? this.journalNumber,
      date: date ?? this.date,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      amount: amount ?? this.amount,
      narration: narration ?? this.narration,
    );
  }
}
