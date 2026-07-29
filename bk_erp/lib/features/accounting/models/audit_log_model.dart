class AuditLogModel {
  final int? id;
  final DateTime timestamp;
  final String action; // Created, Updated, Deleted
  final String documentType; // Invoice, Receipt, Expense, etc.
  final String documentRef; // e.g. INV-00001
  final String description;
  final String user;

  AuditLogModel({
    this.id,
    required this.timestamp,
    required this.action,
    required this.documentType,
    required this.documentRef,
    required this.description,
    this.user = 'Admin',
  });
}
