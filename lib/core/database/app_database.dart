import 'package:sqlite3/sqlite3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _db;

  AppDatabase._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // Get the app directory for storing the database file
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'inventory_app.db');

    final db = sqlite3.open(dbPath);

    // Create the projects table
    db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectName TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    // Create the products table (include displayQuantity for new DBs)
    db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        wholesalePrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        displayQuantity INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'available',
        createdAt TEXT NOT NULL
      );
    ''');

    // Migration: make sure old DBs have the displayQuantity column
    try {
      final ResultSet cols = db.select("PRAGMA table_info('products')");
      var hasDisplay = cols.any((r) => r['name'] == 'displayQuantity');
      if (!hasDisplay) {
        db.execute(
            "ALTER TABLE products ADD COLUMN displayQuantity INTEGER NOT NULL DEFAULT 0");
      }
    } catch (e) {
      // ignore migration errors
    }

    return db;
  }

  // Register Project
  Future<void> registerProject(String name, String user, String pass) async {
    final db = await database;
    final stmt = db.prepare(
        'INSERT INTO projects (projectName, username, password) VALUES (?, ?, ?)');
    stmt.execute([name, user, pass]);
    stmt.dispose();
  }

  // Login Check
  Future<Map<String, dynamic>?> login(String user, String pass) async {
    final db = await database;
    final ResultSet results = db.select(
      'SELECT * FROM projects WHERE username = ? AND password = ?',
      [user, pass],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Product methods
  Future<int> addProduct({
    required String name,
    required double wholesalePrice,
    required double sellingPrice,
    required int quantity,
    String status = 'available',
  }) async {
    final db = await database;
    final stmt = db.prepare(
      'INSERT INTO products (name, wholesalePrice, sellingPrice, quantity, status, createdAt) VALUES (?, ?, ?, ?, ?, ?)',
    );
    final now = DateTime.now().toIso8601String();
    stmt.execute([name, wholesalePrice, sellingPrice, quantity, status, now]);
    stmt.dispose();

    final ResultSet res = db.select('SELECT last_insert_rowid() AS id');
    return (res.first['id'] as int);
  }

  Future<List<Map<String, Object?>>> getProducts() async {
    final db = await database;
    final ResultSet results =
        db.select('SELECT * FROM products ORDER BY createdAt DESC');
    return results.map((r) => Map<String, Object?>.from(r)).toList();
  }

  Future<Map<String, Object?>?> getProductById(int id) async {
    final db = await database;
    final ResultSet results =
        db.select('SELECT * FROM products WHERE id = ?', [id]);
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required double wholesalePrice,
    required double sellingPrice,
    required int quantity,
  }) async {
    final db = await database;
    final stmt = db.prepare(
        'UPDATE products SET name = ?, wholesalePrice = ?, sellingPrice = ?, quantity = ? WHERE id = ?');
    stmt.execute([name, wholesalePrice, sellingPrice, quantity, id]);
    stmt.dispose();
  }

  Future<void> setProductStatus(int id, String status) async {
    final db = await database;
    final stmt = db.prepare('UPDATE products SET status = ? WHERE id = ?');
    stmt.execute([status, id]);
    stmt.dispose();
  }

  Future<void> increaseProductStock(int id, int amount) async {
    if (amount <= 0) return;
    final db = await database;
    final stmt =
        db.prepare('UPDATE products SET quantity = quantity + ? WHERE id = ?');
    stmt.execute([amount, id]);
    stmt.dispose();
  }

  Future<void> sendProductToDisplay(int id, int amount) async {
    if (amount <= 0) return;
    final db = await database;
    db.execute('BEGIN TRANSACTION');
    try {
      final ResultSet res = db.select(
          'SELECT quantity, displayQuantity FROM products WHERE id = ?', [id]);
      if (res.isEmpty) throw Exception('Product not found');
      final row = res.first;
      final int currentQty = (row['quantity'] as num).toInt();
      final int currentDisplay = row['displayQuantity'] == null
          ? 0
          : (row['displayQuantity'] as num).toInt();
      if (amount > currentQty) throw Exception('Insufficient stock');
      final newDisplay = currentDisplay + amount;
      final stmt = db.prepare(
          'UPDATE products SET quantity = quantity - ?, displayQuantity = ? WHERE id = ?');
      stmt.execute([amount, newDisplay, id]);
      stmt.dispose();
      db.execute('COMMIT');
    } catch (e) {
      try {
        db.execute('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }
}
