# 📦 Book Keeper Desktop Application (bk_erp)

[![Flutter](https://img.shields.io/badge/Flutter-Desktop%20(Windows)-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x64-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Database](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Status](https://img.shields.io/badge/Status-Under%20Active%20Development-orange)](#-project-status)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#)

> **Book Keeper Desktop Application** is an offline-first, desktop-based ERP, VAT accounting, and inventory management system designed for small and medium enterprises (originally built for **Ramgram Seed Company (Pvt) Ltd**). It streamlines billing, purchases, supplier credit, customer receivables, stock control, and financial reporting through an intuitive Excel-inspired user interface.

---

## 🚧 Project Status

> **Note:** This project is currently under active development. Core modules such as inventory tracking, VAT tax invoicing, credit ledgers, and SQLite persistence are functional, while additional features, optimizations, and cloud sync capabilities are actively being implemented.

---

## 🌟 Key Features

### 📊 1. Executive Dashboard & Analytics
- **Real-Time Financial KPIs:** Daily sales, invoice counts, monthly revenue/purchases/expenses, cash-in-hand, and bank balance.
- **Visual Analytics:** Interactive daily sales bar charts with 3D gradient bars and income vs. expense distribution breakdown.
- **Live Activity Feed:** Scrollable chronological transaction feed (tax invoices, purchase bills, receipts, credit settlements).
- **Urgent Reorder Alerts:** Prioritized low-stock and out-of-stock monitor sorted by lowest available units first.

### 📦 2. Smart Inventory & Stock Control
- **Duplicate Prevention:** Strict item matching preventing duplicate inventory entries; stock is incremented only through verified purchase vouchers.
- **Nepal-Specific Unit Conversion:** Base unit system in **Kilograms (Kg)** with automatic conversion for:
  - Quintal (100 Kg), Kuntal (50 Kg), Bag (25 Kg)
  - Dharni (10 Kg), Pauwa (5 Kg), Pcs, Box, Litre, Meter
- **Stock Valuation & Thresholds:** Dynamic valuation calculations, safety stock thresholds, and low-stock highlighting.

### 🧾 3. VAT Billing, Invoicing & Receivables
- **IRD-Compliant Tax Invoices:** Automatic subtotal, discount, 13% VAT calculation, and grand total in **Nepali Rupees (Rs.)**.
- **Dual Date System:** Seamless support for both **Nepali Bikram Sambat (BS / Miti)** and Gregorian dates.
- **360° Customer Receivables:** Excel-style spreadsheet interface tracking outstanding customer credit, partial payments, and settlements.
- **PDF Invoice Engine:** High-resolution printable PDF invoices featuring dynamic payment QR codes and company letterhead.

### 🛒 4. Purchases & Supplier Payables
- **Supplier Credit Payables:** Dedicated ledger managing unpaid/partially paid purchase bills with one-click **Pay Credit** settlement.
- **Auto-Fill Supplier Catalog:** Pre-populates typical purchase rates, preferred order quantities, and unit metrics for registered suppliers.
- **Returns Management:** Credit Notes (sales returns restoring stock) and Debit Notes (purchase returns deducting stock).

### 📑 5. Financial Reporting & Excel Sheet Engine
- **Excel Spreadsheet UI:** Interactive sheet views (`Day Book`, `Sales Statement`, `Supplier Statement`, `Profit & Loss`, `Balance Sheet`) with column letters (`A–I`), zebra rows, and summary totals.
- **Direct Excel CSV Export:** Instant one-click export saving cleanly formatted `.csv` reports directly to your local **Downloads** folder.
- **In-Sheet Filtering:** Real-time text search combined with custom Bikram Sambat date range filters.

### 🔒 6. Security, Authentication & Persistence
- **Offline SQLite Engine:** Multi-table relational persistence ensuring all transactions, ledgers, and settings persist across restarts.
- **Workstation Cryptographic Auth:** Salted SHA-256 password hashing with CSPRNG salts (zero plaintext storage).
- **Audit Trails:** Immutable activity logs tracking administrative actions across all ERP modules.

---

## 🛠️ Tech Stack & Architecture

- **Frontend & UI:** [Flutter Desktop](https://flutter.dev/desktop) (Windows x64)
- **Language:** [Dart](https://dart.dev/)
- **State Management:** Provider / `ChangeNotifier` (Reactive singleton `AppData`)
- **Local Database:** SQLite (`sqflite_common_ffi`)
- **Document & Export Services:**
  - `pdf` & `printing` for tax invoices
  - Custom CSV generation engine (`csv_exporter`)
- **Styling:** Custom Material Design with Excel-style data table grids

---

## 📁 Repository Structure

```text
bk_erp/
├── android/                   # Android platform files
├── assets/                    # Static assets & font definitions
├── build/                     # Compiled binaries and release builds
├── image/                     # Application logos, branding & QR codes
├── lib/
│   ├── core/                  # Database helpers, utilities, themes, AppData state
│   ├── features/
│   │   ├── auth/              # Cryptographic authentication & workstation login
│   │   ├── billing/           # Tax invoicing, sales orders & receivables
│   │   ├── customers/         # Customer directories & 360° credit ledgers
│   │   ├── dashboard/         # KPI cards, trend charts & activity monitors
│   │   ├── inventory/         # Product catalog, unit conversions & stock control
│   │   ├── purchases/         # Purchase vouchers & supplier payables
│   │   ├── reports/           # Financial statements & Excel CSV export engine
│   │   └── shell/             # App navigation ribbon, sidebar & user menu
│   └── main.dart              # Application entry point
├── windows/                   # Native Windows desktop runner configuration
├── DATABASE_SCHEMA.sql        # SQLite relational database schema definition
├── pubspec.yaml               # Project dependencies and environment specs
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your Windows machine:
1. **[Flutter SDK](https://docs.flutter.dev/get-started/install/windows)** (v3.19.0 or higher recommended)
2. **[Visual Studio 2022](https://visualstudio.microsoft.com/downloads/)** with **"Desktop development with C++"** workload
3. **[Git](https://git-scm.com/)**

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anishchwdhree/your-repo-name.git
   cd your-repo-name/bk_erp
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run in development mode (Windows):**
   ```bash
   flutter run -d windows
   ```

4. **Build release executable:**
   ```bash
   flutter build windows --no-tree-shake-icons
   ```
   *The compiled `.exe` will be located at:*  
   `build/windows/x64/runner/Release/bk_erp.exe`

---

## 🗓️ Roadmap

- [x] Master inventory with Nepali unit conversions & duplicate protection
- [x] Tax invoice generator with 13% VAT & dynamic QR code
- [x] Excel-style customer receivables and supplier payables grids
- [x] Direct CSV downloads to local system
- [x] Workstation salted SHA-256 login and SQLite persistence
- [ ] Automated encrypted cloud backup & restore
- [ ] Multi-user permission levels (Admin, Cashier, Inventory Manager)
- [ ] Barcode / Thermal receipt printer integration

---

## 👤 Author

Developed by **[Anish Chowdhary](https://github.com/anishchwdhree)**  
Built for **Ramgram Seed Company (Pvt) Ltd**, Nawalparasi, Nepal.
