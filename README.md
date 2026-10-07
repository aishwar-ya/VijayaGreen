<div align="center">

<img src="assets/readme/intro.svg" alt="VijayaGreen - From the garden to the ledger" width="720"/>

# 🌿 VijayaGreen

### *From the garden to the ledger.*

A simple, owner-focused accounting application for **Vijaya Garden**, a family-owned garden and nursery business.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

</div>

---

## 📑 Table of Contents

- [About VijayaGreen](#-about-vijayagreen)
- [Designed for Vijaya Garden](#-designed-for-vijaya-garden)
- [Features](#-features)
- [Data Management](#-data-management)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Android APK](#-android-apk)
- [Data & Privacy](#-data--privacy)
- [Future Enhancements](#-future-enhancements)
- [Why VijayaGreen?](#-why-vijayagreen)
- [License](#-license)

---

## 📖 About VijayaGreen

**VijayaGreen** is an owner-focused accounting application built for **Vijaya Garden**, a family-owned garden and nursery business.

Its purpose is to simplify daily record keeping: money coming in, money going out, what customers owe, and what is owed to suppliers, all in one place on the owner's device.

---

## 🏡 Designed for Vijaya Garden

VijayaGreen follows the way the business actually runs day to day:

- **Recording income** from plant sales, seeds, pots, gardening supplies, and landscaping work
- **Recording expenses** such as plants/seedlings, fertilizer, transport, electricity, labour, and water
- **Managing customers** and the amounts they still have to pay
- **Managing suppliers** and the amounts still to be paid to them
- **Tracking receivables and payables** with running totals
- **Viewing transactions** in a searchable, filterable ledger
- **Monitoring the financial position** through the current balance and category-wise reports

---

## ✨ Features

### 🏠 Dashboard
- Total income and total expenses at a glance
- Quick actions: Add Income, Add Expense, Customers, Suppliers
- Pending payments summary: customer payments (amount to receive) and supplier payments (amount to pay)
- Recent transactions list
- Current balance
- Bottom navigation: Home, Ledger, Reports, Profile

### 💰 Income Management
- Record income with amount, category, date, optional customer name, payment method, and notes
- Categories: Plant Sales, Seeds, Pots & Containers, Gardening Supplies, Landscaping, Other
- Payment methods: Cash, Bank Transfer, Card, Other
- Saved to the local SQLite database with a confirmation dialog

### 🧾 Expense Management
- Record expenses with amount, category, date, optional supplier name, payment method, and notes
- Categories: Plants / Seedlings, Fertilizer, Pots & Containers, Transport, Electricity, Labour, Garden Maintenance, Water, Other
- Payment methods: Cash, Bank Transfer, Card, Other
- Saved to the local SQLite database with a confirmation dialog

### 📒 Ledger
- Current balance based on all recorded transactions
- Total income and total expense summary cards
- Complete transaction list
- Search by transaction details
- Filter by All, Income, or Expense

### 👥 Customer Management
- Add, edit, and delete customers
- Store name, phone number, and amount to receive
- Search by name or phone number
- Total amount to receive across all customers

### 🚚 Supplier Management
- Add, edit, and delete suppliers
- Store name, phone number, category, and amount to pay
- Search by name, phone number, or category
- Total amount to pay across all suppliers

### 📊 Reports
- Financial overview with current balance
- Total income and total expenses
- Income by category
- Expenses by category
- Net result (profit / loss)

### 👤 Profile
- Garden and owner information display
- About VijayaGreen dialog
- Logout with confirmation

### 🔐 Login Screens
- Login screen with show/hide password
- Create Account form with validation (required fields, email format, phone length, minimum 6-character password, password confirmation)

> **Note:** The login and account screens are currently interface-level only. Login does not verify credentials against the database, and Create Account does not save an account. See [Future Enhancements](#-future-enhancements).

---

## 🗄️ Data Management

VijayaGreen stores all business records **locally on the device** in a SQLite database named `vijayagreen.db`. There is no cloud synchronization and no server.

The database (schema version 3) contains three tables:

| Table | Purpose | Fields |
|-------|---------|--------|
| `transactions` | Income and expense entries | `id`, `type`, `category`, `description`, `amount`, `date`, `partyName`, `paymentMethod` |
| `customers` | Customers and what they owe | `id`, `name`, `phone`, `receivable` |
| `suppliers` | Suppliers and what is owed to them | `id`, `name`, `phone`, `category`, `payable` |

Notes:

- `type` is either `income` or `expense`; `partyName` holds the optional customer or supplier name entered with a transaction.
- Customer receivable and supplier payable amounts are entered and edited on the customer/supplier records themselves. They are not automatically linked to income or expense entries.
- The app does not currently include a database backup or restore feature.

---

## 🧰 Technology Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Dart** (SDK `^3.13.4`) | Programming language |
| **Material Design 3** | App theming and UI components |
| **SQLite** | Local database |
| **sqflite** `^2.4.2` | SQLite access on Android/iOS |
| **sqflite_common_ffi** `^2.3.6` | SQLite access on Windows/Linux desktop |
| **path** `^1.9.1` | Building the database file path |
| **cupertino_icons** `^1.0.8` | Icon set |

---

## 📁 Project Structure

```text
VijayaGreen/
├── assets/
│   ├── images/
│   │   ├── vijayagreen_icon.png
│   │   └── vijayagreen_logo.png
│   └── readme/
│       └── intro.svg
├── lib/
│   ├── main.dart
│   ├── database/
│   │   └── database_helper.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── create_account_screen.dart
│       ├── dashboard_screen.dart
│       ├── income_screen.dart
│       ├── expense_screen.dart
│       ├── ledger_screen.dart
│       ├── customers_screen.dart
│       ├── suppliers_screen.dart
│       ├── reports_screen.dart
│       └── profile_screen.dart
├── android/
├── windows/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (with a Dart SDK compatible with `^3.13.4`)
- Android Studio or VS Code with the Flutter extension
- For Windows desktop: Visual Studio with the "Desktop development with C++" workload
- For Android: Android SDK and an emulator or physical device

### Check your setup

```bash
flutter doctor
```

### Run the app

```bash
git clone https://github.com/aishwar-ya/VijayaGreen.git
cd VijayaGreen
flutter pub get
flutter run
```

To run on Windows desktop:

```bash
flutter run -d windows
```

---

## 📱 Android APK

The project includes an Android configuration. To build a release APK:

```bash
flutter build apk --release
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

> **Note:** The current Android release configuration uses the default debug signing key and the placeholder application ID `com.example.nursery_accounts`. Set up your own signing key and application ID before distributing the app.

---

## 🔒 Data & Privacy

- All business records stay **locally on the device**.
- VijayaGreen does not currently upload data anywhere.
- Database files (such as `vijayagreen.db`) and any copies you make of them contain private business information, including transactions, customer names, phone numbers, and balances. Keep them private.
- **Do not commit** passwords, private financial information, API keys, database files, or any confidential business data to GitHub.

---

## 🔮 Future Enhancements

The following are **not implemented yet**:

- Real owner authentication (credential verification at login)
- Saving the account created on the Create Account screen
- Change Password and Forgot Password
- Database backup and restore
- Cloud backup / synchronization
- Editing and deleting individual transactions
- Linking customer receivables and supplier payables to income and expense entries
- PDF reports
- Excel / CSV export
- Advanced analytics
- Multiple staff accounts
- Payment reminders

---

## 🌱 Why VijayaGreen?

A garden business runs on small, frequent transactions: a few saplings sold in the morning, a fertilizer delivery in the afternoon, a customer who will pay next week, a supplier waiting for payment. Without one clear record, these details are easy to lose.

VijayaGreen keeps those everyday details together, so the owner can see what came in, what went out, who owes what, and where the business stands, without complicated accounting software.

---

## 📄 License

VijayaGreen is developed for **Vijaya Garden** and is not currently distributed under an open-source license. All rights reserved.

---

<div align="center">

🌱 **VijayaGreen**

Built for Vijaya Garden.

*"From the garden to the ledger."*

</div>