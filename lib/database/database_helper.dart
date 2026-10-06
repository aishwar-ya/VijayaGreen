import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'vijayagreen.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // ============================================================
    // TRANSACTIONS TABLE
    // ============================================================

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        partyName TEXT,
        paymentMethod TEXT
      )
    ''');

    // ============================================================
    // CUSTOMERS TABLE
    // ============================================================

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        receivable REAL NOT NULL DEFAULT 0
      )
    ''');

    // ============================================================
    // SUPPLIERS TABLE
    // ============================================================

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        category TEXT,
        payable REAL NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 2 - Customers
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          receivable REAL NOT NULL DEFAULT 0
        )
      ''');
    }

    // Version 3 - Suppliers
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE suppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          category TEXT,
          payable REAL NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;

    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getTransactionsByType(String type) async {
    final db = await database;

    return await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(
    int id,
    Map<String, dynamic> transaction,
  ) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE type = 'income'
    ''');

    final total = result.first['total'];

    return total == null ? 0.0 : (total as num).toDouble();
  }

  Future<double> getTotalExpenses() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE type = 'expense'
    ''');

    final total = result.first['total'];

    return total == null ? 0.0 : (total as num).toDouble();
  }

  // ============================================================
  // CUSTOMERS
  // ============================================================

  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;

    return await db.insert('customers', customer);
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;

    return await db.query('customers', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getCustomer(int id) async {
    final db = await database;

    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updateCustomer(int id, Map<String, dynamic> customer) async {
    final db = await database;

    return await db.update(
      'customers',
      customer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;

    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalReceivable() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(receivable) AS total
      FROM customers
    ''');

    final total = result.first['total'];

    return total == null ? 0.0 : (total as num).toDouble();
  }

  // ============================================================
  // SUPPLIERS
  // ============================================================

  Future<int> insertSupplier(Map<String, dynamic> supplier) async {
    final db = await database;

    return await db.insert('suppliers', supplier);
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final db = await database;

    return await db.query('suppliers', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getSupplier(int id) async {
    final db = await database;

    final result = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updateSupplier(int id, Map<String, dynamic> supplier) async {
    final db = await database;

    return await db.update(
      'suppliers',
      supplier,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;

    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalPayable() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(payable) AS total
      FROM suppliers
    ''');

    final total = result.first['total'];

    return total == null ? 0.0 : (total as num).toDouble();
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
