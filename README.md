<div align="center">

# 🌿 VijayaGreen

### *From the garden to the ledger.*

A simple, owner-focused accounting application for **Vijaya Garden**, a family-owned garden and nursery business.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

🌱 **Plant it** &nbsp;•&nbsp; 💧 **Record it** &nbsp;•&nbsp; 🌳 **Watch it grow**

</div>

---

## 📑 Table of Contents

- [About](#-about)
- [Designed for Vijaya Garden](#-designed-for-vijaya-garden)
- [Features](#-features)
- [Data Management](#️-data-management)
- [Technology Stack](#️-technology-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Data & Privacy](#-data--privacy)
- [Future Enhancements](#-future-enhancements)
- [Why VijayaGreen?](#-why-vijayagreen)
- [License](#-license)

---

## 📖 About

**VijayaGreen** is a simple accounting application created for **Vijaya Garden**, a family-owned garden and nursery business.

It provides one place to manage daily financial records, including income, expenses, customer receivables, supplier payables, transactions, and financial reports, keeping everyday record-keeping simple and easy to manage.

---

## 🏡 Designed for Vijaya Garden

VijayaGreen is built around the day-to-day needs of a garden and nursery business. It is designed primarily for the **owner**, with a simple interface that avoids complicated accounting workflows.

The application helps the owner:

- 🌼 Record income and sales
- 💰 Track business expenses
- 👥 Manage customer records and receivables
- 🚚 Manage supplier records and payables
- 📒 Review financial transactions
- 📊 Monitor the overall financial position

The goal is simple:

> **Record the day, check the numbers, and keep the business organized.**

---

## ✨ Features

### 🔐 Owner Account

- Owner login
- Create owner account
- Owner profile
- Logout

### 💰 Income Management

- Add income transactions
- Select income category
- Enter transaction amount
- Add customer or party name
- Add notes or description
- Select payment method
- Select transaction date

### 💸 Expense Management

- Add expense transactions
- Select expense category
- Enter transaction amount
- Add supplier or party name
- Add notes or description
- Select payment method
- Select transaction date

### 📒 Ledger

- View income and expense transactions
- Search and filter transactions
- View transaction details
- View total income, total expenses, and current balance

### 👥 Customer Management

- Add, view, edit, and delete customers
- Store customer phone numbers
- Record amounts to receive
- Search customers
- View total receivables

### 🚚 Supplier Management

- Add, view, edit, and delete suppliers
- Store supplier phone numbers
- Record supply categories
- Record amounts to pay
- Search suppliers
- View total payables

### 📊 Reports

- Current balance
- Total income and total expenses
- Income and expense categories
- Net result
- Monthly reporting information

### 👤 Profile

- Owner information
- Garden information
- Account type
- About VijayaGreen
- Logout

---

## 🗄️ Data Management

VijayaGreen uses a local **SQLite database** to store business records. Data is stored on the device, so previously recorded information remains available after logging out and logging in again.

The database manages three types of records:

| Record | Information stored |
|---|---|
| **Transactions** | Type, category, amount, date, customer/supplier name, description, payment method |
| **Customers** | Name, phone number, amount to receive |
| **Suppliers** | Name, phone number, supply category, amount to pay |

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Application framework |
| **Dart** | Programming language |
| **SQLite** | Local database |
| **sqflite** | SQLite database integration |
| **path** | Database path management |
| **Material Design** | User interface components |

---

## 📂 Project Structure

```text
VijayaGreen/
│
├── assets/
│   └── images/
│       ├── vijayagreen_logo.png
│       └── vijayagreen_icon.png
│
├── lib/
│   ├── main.dart
│   │
│   ├── database/
│   │   └── database_helper.dart
│   │
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
│
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (includes Dart)
- Visual Studio Code or Android Studio
- A supported Flutter development platform (SQLite support is provided through the `sqflite` package)

Verify your Flutter installation:

```bash
flutter doctor
```

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/aishwar-ya/VijayaGreen.git
   ```

2. **Navigate to the project**

   ```bash
   cd VijayaGreen
   ```

3. **Install dependencies**

   ```bash
   flutter pub get
   ```

4. **Run the application**

   ```bash
   flutter run
   ```

   To run on Windows:

   ```bash
   flutter run -d windows
   ```

---

## 🔐 Data & Privacy

VijayaGreen is designed primarily for the internal use of Vijaya Garden, and business records are stored locally using SQLite.

The public GitHub repository should not contain:

- Passwords
- Private contact information
- Personal financial information
- API keys
- Other confidential business information

---

## 🌱 Future Enhancements

Possible future improvements include:

- ☁️ Cloud backup and synchronization
- 📄 PDF report generation
- 📊 Advanced financial analytics
- 📥 Excel or CSV export
- 👥 Multiple staff accounts
- 🔔 Payment reminders
- 💾 Database backup and restore

> These are potential future enhancements and are not part of the current implementation.

---

## 🌿 Why VijayaGreen?

A garden business grows through many small daily activities.

A plant is sold.
A supplier is paid.
A customer has a pending payment.
A new expense is recorded.

VijayaGreen brings these everyday records together in one simple application.

*From the garden to the ledger.*

---

## 📄 License

This project is developed for Vijaya Garden and is not currently distributed under an open-source license.

---

<div align="center">

🌱 **VijayaGreen**
Built for Vijaya Garden.
*From the garden to the ledger.*

</div>