class SupplierModel {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String vatNumber;
  final String email;
  final double outstandingBalance;
  final double openingBalance;
  final String suppliedItems; // What seeds/items they supply
  final String rateType;
  
  // Nepal-specific: what unit this supplier sells in, rate, and typical quantity
  final String defaultUnit;  // Quintal, Kuntal, Bag, Kg
  final double defaultRate;  // Rate per default unit
  final double defaultQty;   // Typical order quantity

  // Payment preference & Bank details
  final String paymentMethod; // Cash, Online, Bank Account
  final double paidAmount;
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;

  String get safeBankName => bankName ?? '';
  String get safeAccountHolder => accountHolder ?? '';
  String get safeAccountNumber => accountNumber ?? '';

  SupplierModel({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.vatNumber = '',
    this.email = '',
    this.outstandingBalance = 0.0,
    this.openingBalance = 0.0,
    this.suppliedItems = '',
    this.rateType = '',
    this.defaultUnit = 'Quintal',
    this.defaultRate = 0.0,
    this.defaultQty = 0.0,
    this.paymentMethod = 'Cash',
    this.paidAmount = 0.0,
    this.bankName = '',
    this.accountHolder = '',
    this.accountNumber = '',
  });

  SupplierModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? vatNumber,
    String? email,
    double? outstandingBalance,
    double? openingBalance,
    String? suppliedItems,
    String? rateType,
    String? defaultUnit,
    double? defaultRate,
    double? defaultQty,
    String? paymentMethod,
    double? paidAmount,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      vatNumber: vatNumber ?? this.vatNumber,
      email: email ?? this.email,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      openingBalance: openingBalance ?? this.openingBalance,
      suppliedItems: suppliedItems ?? this.suppliedItems,
      rateType: rateType ?? this.rateType,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultRate: defaultRate ?? this.defaultRate,
      defaultQty: defaultQty ?? this.defaultQty,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}
