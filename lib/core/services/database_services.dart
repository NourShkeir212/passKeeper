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
      version: 4, // Updated version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // This runs for a fresh installation.
    // It includes all columns from the beginning.
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL, 
      password TEXT NOT NULL,
      profileTag TEXT NOT NULL
    )
  ''');
    await db.execute('CREATE UNIQUE INDEX idx_user_profile ON users (username, profileTag)');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        categoryOrder INTEGER NOT NULL DEFAULT 0,
        profileTag TEXT NOT NULL,
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
        isFavorite INTEGER NOT NULL DEFAULT 0,
        accountOrder INTEGER NOT NULL DEFAULT 0,
        profileTag TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // This runs for existing users to update their database schema.
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE accounts ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE categories ADD COLUMN categoryOrder INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE accounts ADD COLUMN accountOrder INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN profileTag TEXT NOT NULL DEFAULT "real"');
      await db.execute('ALTER TABLE categories ADD COLUMN profileTag TEXT NOT NULL DEFAULT "real"');
      await db.execute('ALTER TABLE accounts ADD COLUMN profileTag TEXT NOT NULL DEFAULT "real"');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_user_profile ON users (username, profileTag)');
      await db.execute('DROP INDEX IF EXISTS users.username'); // May not exist, that's okay
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_user_profile ON users (username, profileTag)');
    }
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'passkeeper.db');
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }

  // --- User Methods ---
  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      return -1;
    }
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<User?> getUserByUsername(String username, String profileTag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND profileTag = ?',
      whereArgs: [username, profileTag],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> verifyPassword(int userId, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
    );
    return result.isNotEmpty;
  }

  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users', {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Deletes a user and all their associated data based on their username and profile tag.
  /// This is primarily for deleting the decoy account.
  Future<void> deleteUserByUsername(String username, String profileTag) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'username = ? AND profileTag = ?',
      whereArgs: [username, profileTag],
    );
  }

  // --- Category Methods ---
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(int userId, String profileTag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'userId = ? AND profileTag = ?',
      whereArgs: [userId, profileTag],
      orderBy: 'categoryOrder ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> updateCategoryOrder(List<Category> categories) async {
    final db = await database;
    final batch = db.batch();
    for (var category in categories) {
      batch.update('categories', {'categoryOrder': category.categoryOrder}, where: 'id = ?', whereArgs: [category.id]);
    }
    await batch.commit(noResult: true);
  }

  Future<int> countAccountsInCategory(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM accounts WHERE categoryId = ?', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCategoriesBatch(List<int> ids) async {
    final db = await database;
    final batch = db.batch();
    for (var id in ids) {
      batch.delete('categories', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  // --- Account Methods ---
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  Future<void> updateAccountOrder(List<Account> accounts) async {
    final db = await database;
    final batch = db.batch();
    for (var account in accounts) {
      batch.update('accounts', {'accountOrder': account.accountOrder}, where: 'id = ?', whereArgs: [account.id]);
    }
    await batch.commit(noResult: true);
  }

  Future<Account?> getAccountById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Account>> getAccounts(int userId, String profileTag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'userId = ? AND profileTag = ?',
      whereArgs: [userId, profileTag],
      orderBy: 'accountOrder ASC',
    );
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<User?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Account>> getAllAccountsForUser(int userId, String profileTag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'userId = ? AND profileTag = ?',
      whereArgs: [userId, profileTag],
    );
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<void> updateAccountsBatch(List<Account> accounts) async {
    final db = await database;
    final batch = db.batch();
    for (var account in accounts) {
      batch.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
    }
    await batch.commit(noResult: true);
  }

  Future<bool> accountExists({required int userId, required String serviceName, required String username, required String profileTag}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'accounts',
      where: 'userId = ? AND serviceName = ? AND username = ? AND profileTag = ?',
      whereArgs: [userId, serviceName, username, profileTag],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}