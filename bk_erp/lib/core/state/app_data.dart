import 'package:flutter/foundation.dart';
import '../../features/inventory/models/product_model.dart';
import '../../features/customers/models/customer_model.dart';
import '../../features/purchases/models/supplier_model.dart';
import '../../features/billing/models/sale_model.dart';
import '../../features/purchases/models/purchase_model.dart';
import '../../features/receipts/models/receipt_model.dart';
import '../../features/payments/models/payment_model.dart';
import '../../features/expenses/models/expense_model.dart';
import '../../features/returns/models/return_model.dart';
import '../../features/returns/models/purchase_return_model.dart';
import '../../features/estimates/models/estimate_model.dart';
import '../../features/delivery/models/delivery_note_model.dart';
import '../../features/purchases/models/purchase_order_model.dart';
import '../../features/accounting/models/contra_entry_model.dart';
import '../../features/accounting/models/journal_entry_model.dart';
import '../../features/accounting/models/audit_log_model.dart';
import '../../features/sales_orders/models/sales_order_model.dart';
import '../../features/inventory/models/inventory_group_model.dart';
import '../../features/bank_accounts/models/bank_account_model.dart';

class AppSettings {
  String companyName;
  String companyAddress;
  String companyPhone;
  String companyEmail;
  String companyVatPAN;
  double defaultVatRate;
  String financialYearStart; // e.g. "2083/04/01" (Nepali) or "2026-07-16"
  double cashOpeningBalance;

  AppSettings({
    this.companyName = 'Ramgarm Seed Company (PVT) Ltd',
    this.companyAddress = 'Ramgram-10-Laxmipur, Nawalparasi',
    this.companyPhone = '9804728321',
    this.companyEmail = 'ramgramseedcompany@gmail.com',
    this.companyVatPAN = '',
    this.defaultVatRate = 13.0,
    this.financialYearStart = '',
    this.cashOpeningBalance = 0.0,
  });
}

class AppData extends ChangeNotifier {
  // Singleton
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // Data lists
  final List<ProductModel> products = [];
  final List<CustomerModel> customers = [];
  final List<SupplierModel> suppliers = [];
  final List<SaleModel> sales = [];
  final List<PurchaseModel> purchases = [];
  final List<ReceiptModel> receipts = [];
  final List<PaymentModel> payments = [];
  final List<ExpenseModel> expenses = [];
  final List<ReturnModel> returns = [];
  final List<PurchaseReturnModel> purchaseReturns = [];
  final List<EstimateModel> estimates = [];
  final List<DeliveryNoteModel> deliveryNotes = [];
  final List<PurchaseOrderModel> purchaseOrders = [];
  final List<ContraEntryModel> contraEntries = [];
  final List<JournalEntryModel> journalEntries = [];
  final List<SalesOrderModel> salesOrders = [];
  final List<AuditLogModel> auditLog = [];
  final List<BankAccountModel> bankAccounts = [];
  
  final List<InventoryGroupModel> inventoryGroups = [
    InventoryGroupModel(id: 1, name: 'All Items', description: 'Default Group'),
    InventoryGroupModel(id: 2, name: 'Raw Materials', description: 'Unprocessed goods'),
    InventoryGroupModel(id: 3, name: 'Finished Goods', description: 'Processed items ready for sale'),
    InventoryGroupModel(id: 4, name: 'Services', description: 'Intangible items or labor'),
  ];
  
  final AppSettings settings = AppSettings();

  int _nextId = 1;
  int _invoiceCounter = 1;
  int _purchaseCounter = 1;
  int _receiptCounter = 1;
  int _paymentCounter = 1;
  int _expenseCounter = 1;
  int _returnCounter = 1;
  int _purchaseReturnCounter = 1;
  int _estimateCounter = 1;
  int _deliveryCounter = 1;
  int _poCounter = 1;
  int _contraCounter = 1;
  int _journalCounter = 1;
  int _soCounter = 1;

  int get nextId => _nextId++;

  String get nextInvoiceNumber {
    final num = _invoiceCounter++;
    return 'INV-${num.toString().padLeft(5, '0')}';
  }

  String get nextPurchaseNumber {
    final num = _purchaseCounter++;
    return 'PUR-${num.toString().padLeft(5, '0')}';
  }

  String get nextReceiptNumber {
    final num = _receiptCounter++;
    return 'RCT-${num.toString().padLeft(5, '0')}';
  }

  String get nextPaymentNumber {
    final num = _paymentCounter++;
    return 'PAY-${num.toString().padLeft(5, '0')}';
  }

  String get nextExpenseNumber {
    final num = _expenseCounter++;
    return 'EXP-${num.toString().padLeft(5, '0')}';
  }

  String get nextReturnNumber {
    final num = _returnCounter++;
    return 'RET-${num.toString().padLeft(5, '0')}';
  }

  String get nextPurchaseReturnNumber {
    final num = _purchaseReturnCounter++;
    return 'PRT-${num.toString().padLeft(5, '0')}';
  }

  String get nextEstimateNumber {
    final num = _estimateCounter++;
    return 'EST-${num.toString().padLeft(5, '0')}';
  }

  String get nextDeliveryNumber {
    final num = _deliveryCounter++;
    return 'DN-${num.toString().padLeft(5, '0')}';
  }

  String get nextPoNumber {
    final num = _poCounter++;
    return 'PO-${num.toString().padLeft(5, '0')}';
  }

  String get nextContraNumber {
    final num = _contraCounter++;
    return 'CTR-${num.toString().padLeft(5, '0')}';
  }

  String get nextJournalNumber {
    final num = _journalCounter++;
    return 'JV-${num.toString().padLeft(5, '0')}';
  }

  String get nextSalesOrderNumber {
    final num = _soCounter++;
    return 'SO-${num.toString().padLeft(5, '0')}';
  }

  // ============ PRODUCTS ============
  void addProduct(ProductModel product) {
    products.add(product.copyWith(id: nextId));
    notifyListeners();
  }

  void updateProduct(ProductModel product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(int id) {
    products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ============ INVENTORY GROUPS ============
  void addInventoryGroup(InventoryGroupModel group) {
    final highestId = inventoryGroups.fold(0, (max, g) => (g.id ?? 0) > max ? (g.id!) : max);
    inventoryGroups.add(group.copyWith(id: highestId + 1));
    notifyListeners();
  }

  void updateInventoryGroup(InventoryGroupModel group) {
    final index = inventoryGroups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      inventoryGroups[index] = group;
      notifyListeners();
    }
  }

  void deleteInventoryGroup(int id) {
    inventoryGroups.removeWhere((g) => g.id == id);
    notifyListeners();
  }



  void updateStock(int productId, double quantityChange) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = products[index];
      products[index] = p.copyWith(currentStock: p.currentStock + quantityChange);
      notifyListeners();
    }
  }

  // ============ CUSTOMERS ============
  void addCustomer(CustomerModel customer) {
    final c = customer.copyWith(
      id: nextId,
      outstandingBalance: customer.openingBalance,
    );
    customers.add(c);
    notifyListeners();
  }

  void updateCustomer(CustomerModel customer) {
    final index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      notifyListeners();
    }
  }

  void deleteCustomer(int id) {
    customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ============ SUPPLIERS ============
  void addSupplier(SupplierModel supplier) {
    final s = supplier.copyWith(
      id: nextId,
      outstandingBalance: supplier.openingBalance,
    );
    suppliers.add(s);
    notifyListeners();
  }

  void updateSupplier(SupplierModel supplier) {
    final index = suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      suppliers[index] = supplier;
      notifyListeners();
    }
  }

  void deleteSupplier(int id) {
    suppliers.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ============ SALES ============
  void addSale(SaleModel sale) {
    sales.add(sale);
    // Reduce stock for each sold item (convert to Kg)
    for (final item in sale.items) {
      updateStock(item.product.id!, -item.quantityInKg);
    }
    // Add unpaid portion to customer outstanding
    final dueAmount = sale.dueAmount;
    if (dueAmount > 0 && sale.customerId != null) {
      final ci = customers.indexWhere((c) => c.id == sale.customerId);
      if (ci != -1) {
        final c = customers[ci];
        customers[ci] = c.copyWith(outstandingBalance: c.outstandingBalance + dueAmount);
      }
    }
    notifyListeners();
  }

  void deleteSale(SaleModel sale) {
    // Restore stock for each sold item
    for (final item in sale.items) {
      updateStock(item.product.id!, item.quantityInKg);
    }
    // Reverse unpaid portion from customer outstanding
    final dueAmount = sale.dueAmount;
    if (dueAmount > 0 && sale.customerId != null) {
      final ci = customers.indexWhere((c) => c.id == sale.customerId);
      if (ci != -1) {
        final c = customers[ci];
        customers[ci] = c.copyWith(
          outstandingBalance: (c.outstandingBalance - dueAmount).clamp(0, double.infinity),
        );
      }
    }
    sales.removeWhere((s) => s.id == sale.id);
    notifyListeners();
  }

  void paySaleCredit({
    required SaleModel sale,
    required double amount,
    required String paymentMethod,
    int? bankAccountId,
    String notes = '',
  }) {
    final si = sales.indexWhere((s) => (s.id != null && s.id == sale.id) || (s.invoiceNumber.isNotEmpty && s.invoiceNumber == sale.invoiceNumber));
    if (si != -1) {
      final s = sales[si];
      final newPaid = s.paidAmount + amount;
      sales[si] = s.copyWith(paidAmount: newPaid);

      final receipt = ReceiptModel(
        receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        customerId: s.customerId,
        customerName: s.customerName,
        amount: amount,
        paymentMethod: paymentMethod,
        bankAccountId: bankAccountId,
        description: 'Credit payment for Invoice #${s.invoiceNumber}${notes.isNotEmpty ? ' ($notes)' : ''}',
      );
      addReceipt(receipt);
    }
  }

  // ============ RETURNS (Sales) ============
  void addReturn(ReturnModel r) {
    returns.add(r.copyWith(id: nextId));
    for (final item in r.items) {
      updateStock(item.product.id!, item.quantityInKg);
    }
    if (r.customerId != null) {
      final ci = customers.indexWhere((c) => c.id == r.customerId);
      if (ci != -1) {
        final c = customers[ci];
        customers[ci] = c.copyWith(
          outstandingBalance: (c.outstandingBalance - r.grandTotal).clamp(0, double.infinity),
        );
      }
    }
    notifyListeners();
  }

  // ============ PURCHASE RETURNS (Debit Notes) ============
  void addPurchaseReturn(PurchaseReturnModel r) {
    purchaseReturns.add(r.copyWith(id: nextId));
    // Decrease stock (returning goods to supplier)
    for (final item in r.items) {
      updateStock(item.product.id!, -item.quantityInKg);
    }
    // Decrease how much we owe the supplier
    if (r.supplierId != null) {
      final si = suppliers.indexWhere((s) => s.id == r.supplierId);
      if (si != -1) {
        final s = suppliers[si];
        suppliers[si] = s.copyWith(
          outstandingBalance: (s.outstandingBalance - r.grandTotal).clamp(0, double.infinity),
        );
      }
    }
    notifyListeners();
  }

  // ============ PURCHASES ============
  void addPurchase(PurchaseModel purchase) {
    purchases.add(purchase);
    for (final item in purchase.items) {
      updateStock(item.product.id!, item.quantityInKg);
    }
    // Add unpaid portion (due amount) to supplier outstanding
    final dueAmount = purchase.dueAmount;
    if (dueAmount > 0 && purchase.supplierId != null) {
      final si = suppliers.indexWhere((s) => s.id == purchase.supplierId);
      if (si != -1) {
        final s = suppliers[si];
        suppliers[si] = s.copyWith(
          outstandingBalance: s.outstandingBalance + dueAmount,
        );
      }
    }
    notifyListeners();
  }

  void deletePurchase(PurchaseModel purchase) {
    // Restore stock
    for (final item in purchase.items) {
      updateStock(item.product.id!, -item.quantityInKg);
    }
    // Reverse unpaid portion from supplier outstanding
    final dueAmount = purchase.dueAmount;
    if (dueAmount > 0 && purchase.supplierId != null) {
      final si = suppliers.indexWhere((s) => s.id == purchase.supplierId);
      if (si != -1) {
        final s = suppliers[si];
        suppliers[si] = s.copyWith(
          outstandingBalance: (s.outstandingBalance - dueAmount).clamp(0, double.infinity),
        );
      }
    }
    purchases.removeWhere((p) => p.id == purchase.id);
    notifyListeners();
  }

  void payPurchaseCredit({
    required PurchaseModel purchase,
    required double amount,
    required String paymentMethod,
    int? bankAccountId,
    String notes = '',
  }) {
    final pi = purchases.indexWhere((p) => (p.id != null && p.id == purchase.id) || (p.invoiceNumber.isNotEmpty && p.invoiceNumber == purchase.invoiceNumber));
    if (pi != -1) {
      final p = purchases[pi];
      final newPaid = p.paidAmount + amount;
      purchases[pi] = p.copyWith(paidAmount: newPaid);

      final payment = PaymentModel(
        paymentNumber: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        supplierId: p.supplierId,
        supplierName: p.supplierName,
        amount: amount,
        paymentMethod: paymentMethod,
        bankAccountId: bankAccountId,
        description: 'Credit payment for Bill #${p.invoiceNumber}${notes.isNotEmpty ? ' ($notes)' : ''}',
      );
      addPayment(payment);
    }
  }

  // ============ RECEIPTS (Money In) ============
  void addReceipt(ReceiptModel receipt) {
    receipts.add(receipt.copyWith(id: nextId));
    if (receipt.customerId != null) {
      final ci = customers.indexWhere((c) => c.id == receipt.customerId);
      if (ci != -1) {
        final c = customers[ci];
        customers[ci] = c.copyWith(
          outstandingBalance: (c.outstandingBalance - receipt.amount).clamp(0, double.infinity),
        );
      }
    }
    notifyListeners();
  }

  void deleteReceipt(ReceiptModel receipt) {
    // Reverse the outstanding balance reduction
    if (receipt.customerId != null) {
      final ci = customers.indexWhere((c) => c.id == receipt.customerId);
      if (ci != -1) {
        final c = customers[ci];
        customers[ci] = c.copyWith(
          outstandingBalance: c.outstandingBalance + receipt.amount,
        );
      }
    }
    receipts.removeWhere((r) => r.id == receipt.id);
    notifyListeners();
  }

  // ============ PAYMENTS (Money Out to Suppliers) ============
  void addPayment(PaymentModel payment) {
    payments.add(payment.copyWith(id: nextId));
    // Decrease supplier outstanding
    if (payment.supplierId != null) {
      final si = suppliers.indexWhere((s) => s.id == payment.supplierId);
      if (si != -1) {
        final s = suppliers[si];
        suppliers[si] = s.copyWith(
          outstandingBalance: (s.outstandingBalance - payment.amount).clamp(0, double.infinity),
        );
      }
    }
    notifyListeners();
  }

  void deletePayment(PaymentModel payment) {
    payments.removeWhere((p) => p.id == payment.id);
    // Reverse supplier outstanding
    if (payment.supplierId != null) {
      final si = suppliers.indexWhere((s) => s.id == payment.supplierId);
      if (si != -1) {
        final s = suppliers[si];
        suppliers[si] = s.copyWith(
          outstandingBalance: s.outstandingBalance + payment.amount,
        );
      }
    }
    notifyListeners();
  }

  // ============ EXPENSES ============
  void addExpense(ExpenseModel expense) {
    expenses.add(expense.copyWith(id: nextId));
    notifyListeners();
  }

  void updateExpense(ExpenseModel expense) {
    final idx = expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      expenses[idx] = expense;
      notifyListeners();
    }
  }

  void deleteExpense(int id) {
    expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ============ ESTIMATES ============
  void addEstimate(EstimateModel estimate) {
    estimates.add(estimate.copyWith(id: nextId));
    notifyListeners();
  }

  void updateEstimate(EstimateModel estimate) {
    final index = estimates.indexWhere((e) => e.id == estimate.id);
    if (index != -1) {
      estimates[index] = estimate;
      notifyListeners();
    }
  }

  void deleteEstimate(int id) {
    estimates.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ============ DELIVERY NOTES ============
  void addDeliveryNote(DeliveryNoteModel note) {
    deliveryNotes.add(note.copyWith(id: nextId));
    notifyListeners();
  }

  void updateDeliveryNote(DeliveryNoteModel note) {
    final index = deliveryNotes.indexWhere((d) => d.id == note.id);
    if (index != -1) {
      deliveryNotes[index] = note;
      notifyListeners();
    }
  }

  // ============ PURCHASE ORDERS ============
  void addPurchaseOrder(PurchaseOrderModel po) {
    purchaseOrders.add(po.copyWith(id: nextId));
    notifyListeners();
  }

  void updatePurchaseOrder(PurchaseOrderModel po) {
    final index = purchaseOrders.indexWhere((p) => p.id == po.id);
    if (index != -1) {
      purchaseOrders[index] = po;
      notifyListeners();
    }
  }

  // ============ SETTINGS ============
  void saveSettings(AppSettings newSettings) {
    settings.companyName = newSettings.companyName;
    settings.companyAddress = newSettings.companyAddress;
    settings.companyPhone = newSettings.companyPhone;
    settings.companyEmail = newSettings.companyEmail;
    settings.companyVatPAN = newSettings.companyVatPAN;
    settings.defaultVatRate = newSettings.defaultVatRate;
    settings.financialYearStart = newSettings.financialYearStart;
    settings.cashOpeningBalance = newSettings.cashOpeningBalance;
    notifyListeners();
  }

  // ============ CONTRA ENTRIES ============
  void addContraEntry(ContraEntryModel entry) {
    contraEntries.add(entry.copyWith(id: nextId));
    _logAudit('Created', 'Contra Entry', entry.contraNumber, '${entry.fromAccount} → ${entry.toAccount}: Rs.${entry.amount.toStringAsFixed(2)}');
    notifyListeners();
  }

  // ============ JOURNAL ENTRIES ============
  void addJournalEntry(JournalEntryModel entry) {
    journalEntries.add(entry.copyWith(id: nextId));
    _logAudit('Created', 'Journal Voucher', entry.journalNumber, 'Dr. ${entry.debitAccount} / Cr. ${entry.creditAccount}: Rs.${entry.amount.toStringAsFixed(2)}');
    notifyListeners();
  }

  // ============ SALES ORDERS ============
  void addSalesOrder(SalesOrderModel so) {
    salesOrders.add(so.copyWith(id: nextId));
    _logAudit('Created', 'Sales Order', so.soNumber, 'Customer: ${so.customerName}, Total: Rs.${so.grandTotal.toStringAsFixed(2)}');
    notifyListeners();
  }

  void updateSalesOrder(SalesOrderModel so) {
    final index = salesOrders.indexWhere((s) => s.id == so.id);
    if (index != -1) {
      salesOrders[index] = so;
      _logAudit('Updated', 'Sales Order', so.soNumber, 'Status: ${so.status}');
      notifyListeners();
    }
  }

  void deleteSalesOrder(SalesOrderModel so) {
    salesOrders.removeWhere((s) => s.id == so.id);
    _logAudit('Deleted', 'Sales Order', so.soNumber, 'Deleted');
    notifyListeners();
  }

  // ============ BANK ACCOUNTS ============
  void addBankAccount(BankAccountModel account) {
    bankAccounts.add(account.copyWith(id: nextId));
    _logAudit('Created', 'Bank Account', account.bankName, account.accountNumber);
    notifyListeners();
  }

  void updateBankAccount(BankAccountModel account) {
    final index = bankAccounts.indexWhere((b) => b.id == account.id);
    if (index != -1) {
      bankAccounts[index] = account;
      _logAudit('Updated', 'Bank Account', account.bankName, account.accountNumber);
      notifyListeners();
    }
  }

  void deleteBankAccount(int id) {
    final acc = bankAccounts.firstWhere((b) => b.id == id, orElse: () => BankAccountModel(bankName: '', accountNumber: ''));
    bankAccounts.removeWhere((b) => b.id == id);
    _logAudit('Deleted', 'Bank Account', acc.bankName, acc.accountNumber);
    notifyListeners();
  }

  double getBankAccountBalance(int accountId) {
    final account = bankAccounts.firstWhere((b) => b.id == accountId, orElse: () => BankAccountModel(bankName: '', accountNumber: ''));
    double balance = account.openingBalance;
    // Receipts deposited to this specific account
    balance += receipts.where((r) => r.bankAccountId == accountId).fold(0.0, (s, r) => s + r.amount);
    // Sales paid via this specific account
    balance += sales.where((s) => s.bankAccountId == accountId).fold(0.0, (s, sale) => s + sale.grandTotal);
    // Purchases paid from this specific account (Bank Transfer/Cheque)
    balance -= purchases.where((p) => p.bankAccountId == accountId).fold(0.0, (s, p) => s + p.grandTotal);
    // Payments made from this specific account
    balance -= payments.where((p) => p.bankAccountId == accountId).fold(0.0, (s, p) => s + p.amount);
    // Expenses paid from this specific account
    balance -= expenses.where((e) => e.bankAccountId == accountId).fold(0.0, (s, e) => s + e.amount);
    // Contra: money coming into this bank
    balance += contraEntries.where((c) => c.toAccount == account.bankName).fold(0.0, (s, c) => s + c.amount);
    // Contra: money going out of this bank
    balance -= contraEntries.where((c) => c.fromAccount == account.bankName).fold(0.0, (s, c) => s + c.amount);
    return balance;
  }

  SaleModel convertSalesOrderToInvoice(SalesOrderModel so) {
    final sale = SaleModel(
      id: nextId,
      invoiceNumber: nextInvoiceNumber,
      date: DateTime.now(),
      customerId: so.customerId,
      customerName: so.customerName,
      customerVat: '',
      items: so.items,
      subTotal: so.subTotal,
      discountAmount: so.discountAmount,
      taxableAmount: so.subTotal - so.discountAmount,
      vatAmount: so.vatAmount,
      grandTotal: so.grandTotal,
      paymentMethod: 'Credit',
      paymentTerms: '30 Days',
      status: 'Unpaid',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      notes: 'Converted from ${so.soNumber}',
    );
    addSale(sale);
    updateSalesOrder(so.copyWith(status: 'Fulfilled'));
    return sale;
  }

  // ============ AUDIT TRAIL ============
  void _logAudit(String action, String docType, String docRef, String description) {
    auditLog.add(AuditLogModel(
      timestamp: DateTime.now(),
      action: action,
      documentType: docType,
      documentRef: docRef,
      description: description,
    ));
  }

  // ============ DASHBOARD STATS ============
  double get todaySales {
    final today = DateTime.now();
    return sales
        .where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day)
        .fold(0.0, (sum, s) => sum + s.grandTotal);
  }

  int get todayInvoiceCount {
    final today = DateTime.now();
    return sales
        .where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day)
        .length;
  }

  double get monthlySales {
    final now = DateTime.now();
    return sales
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold(0.0, (sum, s) => sum + s.grandTotal);
  }

  int get lowStockCount => products.where((p) => p.isLowStock).length;

  int get totalCategories {
    final cats = products.map((p) => p.category).where((c) => c.isNotEmpty).toSet();
    return cats.length;
  }

  List<SaleModel> get recentSales {
    final sorted = List<SaleModel>.from(sales)..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  }

  double get monthlyPurchases {
    final now = DateTime.now();
    return purchases
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0.0, (sum, p) => sum + p.grandTotal);
  }

  double get monthlyExpenses {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get monthlyReceipts {
    final now = DateTime.now();
    return receipts
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  double get monthlyPayments {
    final now = DateTime.now();
    return payments
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get monthlyProfit => monthlySales - monthlyPurchases - monthlyExpenses;

  double get totalVatCollected {
    final now = DateTime.now();
    return sales
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold(0.0, (sum, s) => sum + s.vatAmount);
  }

  double get totalReceivables => customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);
  double get totalPayables => suppliers.fold(0.0, (sum, s) => sum + s.outstandingBalance);

  double get cashInHand {
    double cash = settings.cashOpeningBalance;
    // Add cash receipts
    cash += receipts.where((r) => r.paymentMethod != 'Bank').fold(0.0, (s, r) => s + r.amount);
    // Add cash sales (non-credit)
    cash += sales.where((s) => s.paymentMethod == 'Cash').fold(0.0, (s, sale) => s + sale.grandTotal);
    // Subtract cash purchases
    cash -= purchases.where((p) => p.paymentMethod == 'Cash').fold(0.0, (s, p) => s + p.grandTotal);
    // Subtract cash payments
    cash -= payments.where((p) => p.paymentMethod != 'Bank').fold(0.0, (s, p) => s + p.amount);
    // Subtract cash expenses
    cash -= expenses.fold(0.0, (s, e) => s + e.amount);
    // Contra adjustments
    for (var c in contraEntries) {
      if (c.fromAccount == 'Cash') cash -= c.amount;
      if (c.toAccount == 'Cash') cash += c.amount;
    }
    return cash;
  }

  double get bankBalance {
    double bank = 0;
    // Add bank receipts
    bank += receipts.where((r) => r.paymentMethod == 'Bank').fold(0.0, (s, r) => s + r.amount);
    // Add bank sales
    bank += sales.where((s) => s.paymentMethod == 'Bank Transfer').fold(0.0, (s, sale) => s + sale.grandTotal);
    // Subtract bank purchases
    bank -= purchases.where((p) => p.paymentMethod == 'Bank Transfer').fold(0.0, (s, p) => s + p.grandTotal);
    // Subtract bank payments
    bank -= payments.where((p) => p.paymentMethod == 'Bank').fold(0.0, (s, p) => s + p.amount);
    // Contra adjustments
    for (var c in contraEntries) {
      if (c.fromAccount == 'Bank') bank -= c.amount;
      if (c.toAccount == 'Bank') bank += c.amount;
    }
    return bank;
  }

  int get overdueInvoicesCount => sales.where((s) => s.isOverdue).length;

  // ============ PAYMENT SUMMARY (Cash vs Online) ============
  double get customerCashPaid => customers.where((c) => c.paymentMethod == 'Cash').fold(0.0, (s, c) => s + c.paidAmount);
  double get customerOnlinePaid => customers.where((c) => c.paymentMethod == 'Online').fold(0.0, (s, c) => s + c.paidAmount);
  double get supplierCashPaid => suppliers.where((s) => s.paymentMethod == 'Cash').fold(0.0, (s, sup) => s + sup.paidAmount);
  double get supplierOnlinePaid => suppliers.where((s) => s.paymentMethod == 'Online').fold(0.0, (s, sup) => s + sup.paidAmount);

  int get customerCashCount => customers.where((c) => c.paymentMethod == 'Cash').length;
  int get customerOnlineCount => customers.where((c) => c.paymentMethod == 'Online').length;
  int get supplierCashCount => suppliers.where((s) => s.paymentMethod == 'Cash').length;
  int get supplierOnlineCount => suppliers.where((s) => s.paymentMethod == 'Online').length;

  // ============ LEDGER HELPERS ============
  List<Map<String, dynamic>> getCustomerLedger(int customerId) {
    List<Map<String, dynamic>> entries = [];
    // Opening balance
    final customer = customers.firstWhere((c) => c.id == customerId, orElse: () => CustomerModel(name: ''));
    if (customer.openingBalance > 0) {
      entries.add({'date': DateTime(2020), 'type': 'Opening Balance', 'ref': '-', 'debit': customer.openingBalance, 'credit': 0.0});
    }
    // Sales (debit)
    for (var s in sales) {
      if (s.customerName == customer.name || s.customerId == customerId) {
        entries.add({'date': s.date, 'type': 'Invoice', 'ref': s.invoiceNumber, 'debit': s.grandTotal, 'credit': 0.0});
      }
    }
    // Receipts (credit)
    for (var r in receipts) {
      if (r.customerId == customerId) {
        entries.add({'date': r.date, 'type': 'Receipt', 'ref': r.receiptNumber, 'debit': 0.0, 'credit': r.amount});
      }
    }
    // Sales Returns (credit)
    for (var r in returns) {
      if (r.customerId == customerId) {
        entries.add({'date': r.date, 'type': 'Sales Return', 'ref': r.returnNumber, 'debit': 0.0, 'credit': r.grandTotal});
      }
    }
    entries.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return entries;
  }

  List<Map<String, dynamic>> getSupplierLedger(int supplierId) {
    List<Map<String, dynamic>> entries = [];
    final supplier = suppliers.firstWhere((s) => s.id == supplierId, orElse: () => SupplierModel(name: ''));
    if (supplier.openingBalance > 0) {
      entries.add({'date': DateTime(2020), 'type': 'Opening Balance', 'ref': '-', 'debit': 0.0, 'credit': supplier.openingBalance});
    }
    // Purchases (credit — we owe them)
    for (var p in purchases) {
      if (p.supplierId == supplierId || p.supplierName == supplier.name) {
        entries.add({'date': p.date, 'type': 'Purchase', 'ref': p.invoiceNumber, 'debit': 0.0, 'credit': p.grandTotal});
      }
    }
    // Payments (debit — we paid them)
    for (var p in payments) {
      if (p.supplierId == supplierId) {
        entries.add({'date': p.date, 'type': 'Payment', 'ref': p.paymentNumber, 'debit': p.amount, 'credit': 0.0});
      }
    }
    // Purchase Returns (debit — they owe us)
    for (var r in purchaseReturns) {
      if (r.supplierId == supplierId) {
        entries.add({'date': r.date, 'type': 'Purchase Return', 'ref': r.returnNumber, 'debit': r.grandTotal, 'credit': 0.0});
      }
    }
    entries.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return entries;
  }
}
