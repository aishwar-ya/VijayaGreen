import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    await _ensureExistingOwnerAccount(_database!);

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    assert(() {
      stderr.writeln('VIJAYAGREEN DATABASE LOCATION: $databasePath');
      return true;
    }());

    final path = join(databasePath, 'vijayagreen.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _ensureExistingOwnerAccount(Database db) async {
    const email = 'aishwaryayakkara@gmail.com';
    const password = 'aishu123';
    const ownerName = 'ayshu';

    final existing = await db.query(
      'owner_account',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('owner_account', {
        'email': email,
        'password_hash': _hashPassword(password),
        'owner_name': ownerName,
      });
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // ==========================================================
    // TRANSACTIONS TABLE
    // ==========================================================

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

    // ==========================================================
    // CUSTOMERS TABLE
    // ==========================================================

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        receivable REAL NOT NULL DEFAULT 0
      )
    ''');

    // ==========================================================
    // SUPPLIERS TABLE
    // ==========================================================

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        category TEXT,
        payable REAL NOT NULL DEFAULT 0
      )
    ''');

    // ==========================================================
    // OWNER ACCOUNT TABLE
    // ==========================================================

    await db.execute('''
      CREATE TABLE owner_account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        owner_name TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ==========================================================
    // VERSION 2 - CUSTOMERS
    // ==========================================================

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

    // ==========================================================
    // VERSION 3 - SUPPLIERS
    // ==========================================================

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

    // ==========================================================
    // VERSION 4 - OWNER ACCOUNT
    // ==========================================================

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE owner_account (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          owner_name TEXT NOT NULL
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
  // OWNER ACCOUNT / AUTHENTICATION
  // ============================================================

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  Future<bool> ownerAccountExists() async {
    final db = await database;

    final result = await db.query('owner_account', limit: 1);

    return result.isNotEmpty;
  }

  Future<int> createOwnerAccount({
    required String email,
    required String password,
    required String ownerName,
  }) async {
    final db = await database;

    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'owner_account',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return 0;
    }

    return await db.insert('owner_account', {
      'email': normalizedEmail,
      'password_hash': _hashPassword(password),
      'owner_name': ownerName.trim(),
    });
  }

  Future<Map<String, dynamic>?> getOwnerAccount() async {
    final db = await database;

    final result = await db.query('owner_account', limit: 1);

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, dynamic>?> getOwnerAccountByEmail(String email) async {
    final db = await database;

    final normalizedEmail = email.trim().toLowerCase();

    final result = await db.query(
      'owner_account',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, dynamic>?> verifyOwnerLogin({
    required String email,
    required String password,
  }) async {
    final account = await getOwnerAccountByEmail(email);

    if (account == null) {
      return null;
    }

    final enteredPasswordHash = _hashPassword(password);

    if (account['password_hash'] != enteredPasswordHash) {
      return null;
    }

    return account;
  }

  Future<bool> changeOwnerPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await database;

    final account = await getOwnerAccount();

    if (account == null) {
      return false;
    }

    final currentHash = _hashPassword(currentPassword);

    if (account['password_hash'] != currentHash) {
      return false;
    }

    final newHash = _hashPassword(newPassword);

    await db.update(
      'owner_account',
      {'password_hash': newHash},
      where: 'id = ?',
      whereArgs: [account['id']],
    );

    return true;
  }

  Future<bool> resetOwnerPassword({
    required String email,
    required String newPassword,
  }) async {
    final db = await database;

    final account = await getOwnerAccount();

    if (account == null) {
      return false;
    }

    final normalizedEmail = email.trim().toLowerCase();
    final newHash = _hashPassword(newPassword);

    final updatedRows = await db.update(
      'owner_account',
      {'email': normalizedEmail, 'password_hash': newHash},
      where: 'id = ?',
      whereArgs: [account['id']],
    );

    return updatedRows > 0;
  }

  // ============================================================
  // BACKUP DATABASE
  // ============================================================

  Future<String?> backupDatabase() async {
    try {
      final db = await database;

      // Make sure all pending database changes are written.
      await db.execute('PRAGMA wal_checkpoint(FULL)');

      final databasePath = await getDatabasesPath();

      final databaseFile = File(join(databasePath, 'vijayagreen.db'));

      if (!await databaseFile.exists()) {
        return null;
      }

      // Read the database as bytes.
      final databaseBytes = await databaseFile.readAsBytes();

      // Let Android/Windows/etc. choose the save location.
      // Passing bytes directly is important for Android.
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save VijayaGreen Backup',
        fileName: 'vijayagreen_backup.db',
        bytes: databaseBytes,
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null) {
        return null;
      }

      return result.toString();
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // RESTORE DATABASE
  // ============================================================

  Future<bool> restoreDatabase() async {
    File? currentDatabase;
    File? candidateDatabase;
    File? recoveryDatabase;
    File? previousDatabase;
    Database? validationDatabase;

    bool databaseClosed = false;
    bool replacementStarted = false;

    Future<void> deleteIfExists(File file) async {
      if (await file.exists()) {
        await file.delete();
      }
    }

    Future<void> removeDatabaseSidecars(String path) async {
      await deleteIfExists(File('$path-wal'));
      await deleteIfExists(File('$path-shm'));
      await deleteIfExists(File('$path-journal'));
    }

    Future<void> validateDatabase(Database db) async {
      final integrity = await db.rawQuery('PRAGMA integrity_check');

      if (integrity.isEmpty || integrity.first.values.first != 'ok') {
        throw Exception('Database integrity check failed.');
      }

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );

      final tableNames = tables
          .map((row) => row['name'] as String?)
          .whereType<String>()
          .toSet();

      const requiredTables = {
        'transactions',
        'customers',
        'suppliers',
        'owner_account',
      };

      if (!tableNames.containsAll(requiredTables)) {
        throw Exception('Database is missing required tables.');
      }
    }

    try {
      // 1. Select the backup.
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select VijayaGreen Backup',
        type: FileType.custom,
        allowedExtensions: ['db'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final backupBytes = result.files.single.bytes;

      if (backupBytes == null || backupBytes.isEmpty) {
        return false;
      }

      final databasePath = await getDatabasesPath();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      currentDatabase = File(join(databasePath, 'vijayagreen.db'));

      candidateDatabase = File(
        join(databasePath, 'vijayagreen_restore_candidate_$timestamp.db'),
      );

      recoveryDatabase = File(
        join(databasePath, 'vijayagreen_recovery_$timestamp.db'),
      );

      previousDatabase = File(
        join(databasePath, 'vijayagreen_previous_$timestamp.db'),
      );

      // 2. Prepare and validate the candidate separately.
      await candidateDatabase.writeAsBytes(backupBytes, flush: true);

      validationDatabase = await openDatabase(
        candidateDatabase.path,
        readOnly: true,
        singleInstance: false,
      );

      await validateDatabase(validationDatabase);

      await validationDatabase.close();
      validationDatabase = null;

      // 3. Checkpoint and close the current database.
      if (_database != null) {
        await _database!.rawQuery('PRAGMA wal_checkpoint(FULL)');
      }

      await closeDatabase();
      databaseClosed = true;

      // 4. Preserve and validate the current database.
      if (await currentDatabase.exists()) {
        await currentDatabase.copy(recoveryDatabase.path);

        if (!await recoveryDatabase.exists()) {
          throw Exception('Could not create recovery copy.');
        }

        final originalSize = await currentDatabase.length();
        final recoverySize = await recoveryDatabase.length();

        if (originalSize == 0 || originalSize != recoverySize) {
          throw Exception('Recovery copy verification failed.');
        }

        validationDatabase = await openDatabase(
          recoveryDatabase.path,
          readOnly: true,
          singleInstance: false,
        );

        await validateDatabase(validationDatabase);

        await validationDatabase.close();
        validationDatabase = null;
      }

      // 5. Move the original aside before installing the candidate.
      replacementStarted = true;

      await removeDatabaseSidecars(currentDatabase.path);

      if (await currentDatabase.exists()) {
        await currentDatabase.rename(previousDatabase.path);
      }

      // 6. Install and open the candidate.
      await candidateDatabase.rename(currentDatabase.path);

      _database = await _initDatabase();

      await validateDatabase(_database!);

      await _ensureExistingOwnerAccount(_database!);

      // Keep both recovery files; do not delete them automatically.
      return true;
    } catch (e) {
      // Close any database opened during the failed operation.
      try {
        if (validationDatabase != null) {
          await validationDatabase.close();
          validationDatabase = null;
        }
      } catch (_) {}

      try {
        if (_database != null) {
          await closeDatabase();
        }
      } catch (_) {}

      // If replacement began, try to recover the original file.
      if (replacementStarted &&
          currentDatabase != null &&
          previousDatabase != null &&
          await previousDatabase.exists()) {
        try {
          await removeDatabaseSidecars(currentDatabase.path);
          await deleteIfExists(currentDatabase);

          await previousDatabase.rename(currentDatabase.path);

          _database = await _initDatabase();
          await validateDatabase(_database!);

          await _ensureExistingOwnerAccount(_database!);
        } catch (_) {
          // Preserve the recovery file for manual recovery.
          try {
            if (_database != null) {
              await closeDatabase();
            }
          } catch (_) {}
        }
      } else if (databaseClosed &&
          currentDatabase != null &&
          await currentDatabase.exists()) {
        // Replacement did not move the original; reopen it.
        try {
          _database = await _initDatabase();
          await validateDatabase(_database!);
        } catch (_) {
          try {
            if (_database != null) {
              await closeDatabase();
            }
          } catch (_) {}
        }
      }

      return false;
    } finally {
      // Remove only temporary candidate files.
      // Never delete the recovery or previous database here.
      try {
        if (validationDatabase != null) {
          await validationDatabase.close();
        }
      } catch (_) {}

      try {
        if (candidateDatabase != null) {
          await deleteIfExists(candidateDatabase);
          await removeDatabaseSidecars(candidateDatabase.path);
        }
      } catch (_) {}
    }
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
