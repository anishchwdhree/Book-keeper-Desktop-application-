class ProductModel {
  final int? id;

  // Basic Details
  final String name;
  final String inventoryGroup;
  final double defaultTaxRate;
  
  // Unit Settings
  final String unit; // Primary selling unit (Kg, Kuntal, Bag, Pcs)
  final String alternateUnit; // Alternate unit (Quintal, Kg, etc.)
  final double conversionRate; // E.g., 1 Quintal = 100 Kg

  // Nepal-specific unit system
  final String purchaseUnit; // Unit used when buying (Quintal, Kuntal, Bag)
  final String sellingUnit;  // Unit used when selling (Kg, Kuntal, Bag)

  // Pricing & Stock
  final double purchasePrice; // Rate per purchase unit
  final double sellingPrice;  // Rate per selling unit
  final double initialQuantity;
  final double currentStock;
  final double reorderLevel;

  // Additional
  final String batchNumber;
  final String barcode;
  final DateTime? expiryDate;
  final DateTime? manufacturingDate;
  final String brand;
  final String packSize;
  final String variety;

  // Nepal-specific units list
  static const List<String> nepalUnits = [
    'Kg',
    'Quintal',
    'Kuntal',
    'Bag',
    'Pcs',
    'Box',
    'Dharni',
    'Pauwa',
    'Litre',
    'Meter',
  ];

  // Conversion rates (base = Kg)
  static const Map<String, double> unitConversions = {
    'Kg': 1.0,
    'Quintal': 100.0,      // 1 Quintal = 100 Kg
    'Kuntal': 50.0,         // 1 Kuntal = 50 Kg (approx)
    'Bag': 25.0,            // 1 Bag = 25 Kg
    'Pcs': 1.0,
    'Box': 1.0,
    'Dharni': 10.0,         // 1 Dharni = 10 Kg
    'Pauwa': 5.0,           // 1 Pauwa = 5 Kg
    'Litre': 1.0,
    'Meter': 1.0,
  };

  ProductModel({
    this.id,
    required this.name,
    this.inventoryGroup = 'All Items',
    this.defaultTaxRate = 0.0,
    
    this.unit = 'Kg',
    this.alternateUnit = '',
    this.conversionRate = 1.0,

    this.purchaseUnit = 'Quintal',
    this.sellingUnit = 'Kg',

    this.purchasePrice = 0.0,
    this.sellingPrice = 0.0,
    this.initialQuantity = 0.0,
    this.currentStock = 0.0,
    this.reorderLevel = 0.0,

    this.batchNumber = '',
    this.barcode = '',
    this.expiryDate,
    this.manufacturingDate,
    this.brand = '',
    this.packSize = '',
    this.variety = '',
  });

  ProductModel copyWith({
    int? id,
    String? name,
    String? inventoryGroup,
    double? defaultTaxRate,
    String? unit,
    String? alternateUnit,
    double? conversionRate,
    String? purchaseUnit,
    String? sellingUnit,
    double? purchasePrice,
    double? sellingPrice,
    double? initialQuantity,
    double? currentStock,
    double? reorderLevel,
    String? batchNumber,
    String? barcode,
    DateTime? expiryDate,
    DateTime? manufacturingDate,
    String? brand,
    String? packSize,
    String? variety,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      inventoryGroup: inventoryGroup ?? this.inventoryGroup,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      unit: unit ?? this.unit,
      alternateUnit: alternateUnit ?? this.alternateUnit,
      conversionRate: conversionRate ?? this.conversionRate,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      sellingUnit: sellingUnit ?? this.sellingUnit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      currentStock: currentStock ?? this.currentStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      batchNumber: batchNumber ?? this.batchNumber,
      barcode: barcode ?? this.barcode,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      brand: brand ?? this.brand,
      packSize: packSize ?? this.packSize,
      variety: variety ?? this.variety,
    );
  }

  // Convert quantity from one unit to another
  static double convertUnit(double qty, String fromUnit, String toUnit) {
    final fromFactor = unitConversions[fromUnit] ?? 1.0;
    final toFactor = unitConversions[toUnit] ?? 1.0;
    return (qty * fromFactor) / toFactor;
  }

  // Get rate per Kg from rate per purchase unit
  double get ratePerKg {
    final factor = unitConversions[purchaseUnit] ?? 1.0;
    return purchasePrice / factor;
  }

  // Get rate per selling unit
  double get ratePerSellingUnit => sellingPrice;

  // Deprecated fields compatibility
  String get category => inventoryGroup;
  bool get isVatable => defaultTaxRate > 0;

  double get profit => sellingPrice - purchasePrice;
  double get profitMargin => purchasePrice > 0 ? (profit / purchasePrice) * 100 : 0;
  bool get isLowStock => currentStock <= reorderLevel;
}
