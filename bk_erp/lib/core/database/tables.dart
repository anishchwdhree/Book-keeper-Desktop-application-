import 'package:drift/drift.dart';

// -------------------------------------------------------------
// 1. PRODUCTS TABLE
// -------------------------------------------------------------
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get category => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get variety => text().nullable()();
  TextColumn get packSize => text().nullable()();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellingPrice => real().withDefault(const Constant(0.0))();
  RealColumn get currentStock => real().withDefault(const Constant(0.0))();
  
  // Barcode / SKU for fast scanning
  TextColumn get barcode => text().nullable()();
  
  // To determine if VAT is applicable to this product
  BoolColumn get isVatable => boolean().withDefault(const Constant(true))();
}

// -------------------------------------------------------------
// 2. CUSTOMERS TABLE
// -------------------------------------------------------------
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get vatNumber => text().nullable()();
  TextColumn get email => text().nullable()();
  RealColumn get outstandingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  TextColumn get purchasedItems => text().nullable()();
  TextColumn get rateType => text().nullable()();
}

// -------------------------------------------------------------
// 3. SUPPLIERS TABLE
// -------------------------------------------------------------
class Suppliers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get vatNumber => text().nullable()();
  TextColumn get email => text().nullable()();
  RealColumn get outstandingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  TextColumn get suppliedItems => text().nullable()();
  TextColumn get rateType => text().nullable()();
}

// -------------------------------------------------------------
// 4. SALES (INVOICES) TABLE
// -------------------------------------------------------------
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  
  // Nullable because you might have a walk-in customer
  IntColumn get customerId => integer().nullable().references(Customers, #id)();

  RealColumn get subTotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxableAmount => real().withDefault(const Constant(0.0))();
  RealColumn get vatAmount => real().withDefault(const Constant(0.0))();
  RealColumn get grandTotal => real().withDefault(const Constant(0.0))();
  
  // Payment Status (e.g. "Cash", "Credit", "Card")
  TextColumn get paymentMethod => text().nullable()();
}

// -------------------------------------------------------------
// 5. SALE ITEMS TABLE (Products sold in each Invoice)
// -------------------------------------------------------------
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get lineTotal => real()();
}

// -------------------------------------------------------------
// 6. SETTINGS TABLE
// -------------------------------------------------------------
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get companyName => text().nullable()();
  TextColumn get companyAddress => text().nullable()();
  TextColumn get companyPhone => text().nullable()();
  TextColumn get companyVatPAN => text().nullable()();
  RealColumn get defaultVatRate => real().withDefault(const Constant(13.0))(); // Standard VAT rate
}

// -------------------------------------------------------------
// 7. TRANSACTIONS TABLE (Receipts, Payments, Expenses)
// -------------------------------------------------------------
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get type => text()(); // 'RECEIPT', 'PAYMENT', 'EXPENSE'
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get supplierId => integer().nullable().references(Suppliers, #id)();
  IntColumn get saleId => integer().nullable().references(Sales, #id)(); // if linked to specific invoice
}
