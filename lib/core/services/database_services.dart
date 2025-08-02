import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/account_model.dart';
import '../../model/category_model.dart';
import '../../model/user_model.dart';


class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'passkeeper.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    '''); // FIX: Removed trailing comma

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        categoryOrder INTEGER NOT NULL DEFAULT 0, -- FIX: Added comma
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        serviceName TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        recoveryAccount TEXT,
        phoneNumbers TEXT,
        accountOrder INTEGER NOT NULL DEFAULT 0, -- FIX: Added comma
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE categories ADD COLUMN categoryOrder INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE accounts ADD COLUMN accountOrder INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'passkeeper.db');
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
    print("Database deleted successfully.");
  }

  // --- User Methods ---
  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      return await db.insert('users', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      return -1;
    }
  }

  /// Fetches a user by their username only.
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // --- Category Methods ---
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'categoryOrder ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Counts how many accounts are left in a specific category.
  Future<int> countAccountsInCategory(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM accounts WHERE categoryId = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes a category. All accounts within it will be deleted by the database
  /// because we used "ON DELETE CASCADE".
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // --- Account Methods ---
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Gets a single account by its ID. We need this to find its categoryId before deleting.
  Future<Account?> getAccountById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }


  Future<List<Account>> getAccounts(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'accountOrder ASC', // ORDER BY
    );
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  /// Verifies if the provided password matches the user's current password.
  Future<bool> verifyPassword(int userId, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
    );
    return result.isNotEmpty;
  }

  /// Updates the user's password in the database.
  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Checks if an account already exists for a user.
  Future<bool> accountExists({
    required int userId,
    required String serviceName,
    required String username,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'accounts',
      where: 'userId = ? AND serviceName = ? AND username = ?',
      whereArgs: [userId, serviceName, username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> updateCategoryOrder(List<Category> categories) async {
    final db = await database;
    final batch = db.batch();
    for (var category in categories) {
      batch.update('categories', {'categoryOrder': category.categoryOrder}, where: 'id = ?', whereArgs: [category.id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateAccountOrder(List<Account> accounts) async {
    final db = await database;
    final batch = db.batch();
    for (var account in accounts) {
      batch.update('accounts', {'accountOrder': account.accountOrder}, where: 'id = ?', whereArgs: [account.id]);
    }
    await batch.commit(noResult: true);
  }
}