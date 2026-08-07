# bk_erp — Ramgarm Seed Company (Pvt) Ltd — VAT / Billing ERP

A Windows desktop ERP built with Flutter for **Ramgarm Seed Company (Pvt) Ltd**, Ramgram-10-Laxmipur, Nawalparasi.

In-memory (singleton `AppData`) business logic with Flutter Material UI. All prices in Nepali Rupees (Rs), all dates support the Nepali Bikram Sambat (BS / Miti) calendar alongside Gregorian dates.

## Build & Run

```bash
cd bk_erp
flutter pub get
flutter build windows --no-tree-shake-icons
```

Executable output: `build\windows\x64\runner\Release\bk_erp.exe`

## Modules / Features

### Dashboard
- Quick actions for New Invoice, New Purchase, Add Customer
- Today's sales, invoice count, monthly sales/purchases/expenses, receivables, payables, cash in hand, bank balance, low-stock / out-of-stock counts, recent sales

### Inventory
- Master catalog with search, category (group) filters (All Items / Raw Materials / Finished Goods / Services), sorting by name / stock / valuation
- Add / Edit Item dialog with autocomplete that suggests from suppliers and existing inventory
- Stock levels (`currentStock`), reorder level, low-stock highlighting, total stock units & valuation
- Nepal-specific unit system (base = Kg): Kg, Quintal (100), Kuntal (50), Bag (25), Pcs, Box, Dharni (10), Pauwa (5), Litre, Meter

### Purchases
- Purchase entries with auto-populated cart from the supplier's `suppliedItems` (split on `,` / `;`)
- Each cart line pre-filled from the supplier's typical quantity (`defaultQty`), typical rate (`defaultRate`) and unit (`defaultUnit`), falling back to the product's own purchase price/unit
- Payment methods: Cash, Bank Transfer, Cheque, Credit; Nepali bank list; paid amount per purchase
- Auto-creates missing products in inventory on save; stock increases by the purchased quantity (converted to Kg)
- Supplier ledger and supplier payables screens; credit payment tracking

### Sales / Billing
- Tax invoices (VAT) with unit conversion, discount, payment method, bank/cash
- Items Sold screen: one row per sale line item (each sale/customer appears separately)
- Sales returns (Credit Notes) — stock restored; purchase returns (Debit Notes) — stock reduced
- Sales Orders and estimates (Quote), convertible to invoice

### Stock
- Stock Summary screen with filters (in-stock / low / out), total units & valuation
- Stock updates instantly on every sale (`-quantityInKg`), purchase (`+quantityInKg`), return, or deletion

### Customers & Suppliers
- Add / Edit dialogs with opening balance, payment method, bank details
- Outstanding balances updated automatically on sales, receipts, returns, purchases, payments
- Customer statement and supplier statement reports with PDF export

### Receipts & Payments
- Money-in (receipts) and money-out (payments) with bank/cash handling
- Receipts reduce customer outstanding; payments reduce supplier outstanding

### Expenses, Bank Accounts & Accounting
- Expense tracking; bank account balances computed from receipts/sales/purchases/payments/contra
- Contra entries (Cash ↔ Bank), Journal Vouchers, audit log

### Reports & PDF
- Customer Statements, Supplier Statements, Stock Reports, Daybook (all with date-range filters)
- Excel-style statement PDF tables: column letter row (A–I), `#`/S.NO row numbers, gray header, alternating row colors, grid borders
- PDF generators: Tax Invoice, Estimate/Quote, Purchase Order, Credit Note, Statement

### Other
- Purchase Orders (PO), Delivery Notes, Sales Orders (SO)
- Nepali date (Miti) auto-filled as today's BS date

## Changelog / Fixes

### Recent fixes
- **Duplicate items prevented (fixed):** Inventory now refuses to create a second item with the same name — stock is added only through Purchases. This was the cause of "doubled" stock: a purchase auto-creates the item with its stock, and if the item was then added again in Inventory, a second identical row was created and the summary summed both (100 + 100 = 200).
- **Stock doubling on purchase (fixed):** selecting an item name now auto-fills only **Buy Unit, Sell Unit and Purchase Rate**. **Opening Stock is never auto-filled** — it stays at 0, so stock comes **only from purchases**: buy 100 kg → stock = 100 kg. The purchase auto-create also now guards against creating the same item twice if the cart has duplicate rows.
- **Add Item auto-fill:** selecting an item name from the autocomplete suggestions auto-fills Buy Unit, Sell Unit and Purchase Rate. Selling Rate and Minimum Stock are left empty for the user to fill.
- **Items Sold merged rows (fixed):** `items_sold_screen.dart` previously aggregated rows by product+unit, so multiple customers appeared combined in a single row. It now shows one row per sale line item (sort and search preserved).
- **Purchase dialog supplier selection (fixed):** `_onSupplierSelected` now always clears and re-populates the cart when the supplier changes, using each product's own purchase price/unit with the supplier's defaults as fallback.
- **Customer dialog duplicate product (fixed):** adding the same product from the supplier list no longer duplicates the entry.

### Verified stock-flow notes
- `AppData` is a singleton (`ChangeNotifier`); screens rebuild via `ListenableBuilder` and read fresh data on navigation.
- `addPurchase` adds `quantityInKg` once per item; `addSale` subtracts `quantityInKg` once per item; `addReturn` restores it; `deletePurchase`/`deleteSale` reverse it.
- `AppData` is in-memory only; the drift `AppDatabase` scaffolding (`lib/core/database`) is defined but not yet wired to persistence.
