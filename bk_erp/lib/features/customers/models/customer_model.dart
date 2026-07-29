class CustomerModel {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String vatNumber;
  final String email;
  final double outstandingBalance;
  final double openingBalance;
  final int creditDays;
  final String purchasedItems;
  final String rateType;

  // Nepal-specific: what unit this customer buys in
  final String preferredUnit; // Kg, Kuntal, Bag, Quintal
  final double sellingRate; // Rate per unit we sell to this customer
  final double typicalQuantity; // How much they typically buy

  // Payment preference & Bank details (matching Supplier)
  final String paymentMethod;
  final double paidAmount;
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;

  String get safeBankName => bankName ?? '';
  String get safeAccountHolder => accountHolder ?? '';
  String get safeAccountNumber => accountNumber ?? '';

  CustomerModel({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.vatNumber = '',
    this.email = '',
    this.outstandingBalance = 0.0,
    this.openingBalance = 0.0,
    this.creditDays = 0,
    this.purchasedItems = '',
    this.rateType = 'Standard',
    this.preferredUnit = 'Kg',
    this.sellingRate = 0.0,
    this.typicalQuantity = 0.0,
    this.paymentMethod = 'Cash',
    this.paidAmount = 0.0,
    this.bankName = '',
    this.accountHolder = '',
    this.accountNumber = '',
  });

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? vatNumber,
    String? email,
    double? outstandingBalance,
    double? openingBalance,
    int? creditDays,
    String? purchasedItems,
    String? rateType,
    String? preferredUnit,
    double? sellingRate,
    double? typicalQuantity,
    String? paymentMethod,
    double? paidAmount,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      vatNumber: vatNumber ?? this.vatNumber,
      email: email ?? this.email,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      openingBalance: openingBalance ?? this.openingBalance,
      creditDays: creditDays ?? this.creditDays,
      purchasedItems: purchasedItems ?? this.purchasedItems,
      rateType: rateType ?? this.rateType,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      sellingRate: sellingRate ?? this.sellingRate,
      typicalQuantity: typicalQuantity ?? this.typicalQuantity,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      bankName: bankName ?? this.bankName,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}
