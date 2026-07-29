class BankAccountModel {
  final int? id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String branch;
  final String accountType; // Current, Savings
  final double openingBalance;
  final bool isDefault;

  BankAccountModel({
    this.id,
    required this.bankName,
    required this.accountNumber,
    this.accountHolderName = '',
    this.branch = '',
    this.accountType = 'Current',
    this.openingBalance = 0.0,
    this.isDefault = false,
  });

  BankAccountModel copyWith({
    int? id,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? branch,
    String? accountType,
    double? openingBalance,
    bool? isDefault,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      branch: branch ?? this.branch,
      accountType: accountType ?? this.accountType,
      openingBalance: openingBalance ?? this.openingBalance,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
