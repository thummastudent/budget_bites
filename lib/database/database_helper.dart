import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // constructor 
  DatabaseHelper._init();

  // table names (meals for meal details, purchase_logs for tracking purchases)
  static const String tableMeals = 'meals';
  static const String tablePurchaseLogs = 'purchase_logs';

  // column names (common)
  static const String columnId = 'id';

  // meals columns
  static const String columnMealName = 'name';
  static const String columnMealVenueNote = 'venue_note';
  static const String columnMealCuisine = 'cuisine';
  static const String columnMealEstimatedPriceMinor = 'estimated_price_minor';

  // purchase_logs columns
  static const String columnLogMealId = 'meal_id';
  static const String columnLogPurchasedAt= 'purchased_at';
  static const String columnLogActualPriceMinor = 'actual_price_minor';
  static const String columnLogNote = 'note';


  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_tracker.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  // foreign key constraints
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create both related tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMeals (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnMealName TEXT NOT NULL,
        $columnMealVenueNote TEXT NOT NULL DEFAULT '',
        $columnMealCuisine TEXT NOT NULL,
        $columnMealEstimatedPriceMinor INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePurchaseLogs (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnLogMealId INTEGER NOT NULL,
        $columnLogPurchasedAt TEXT NOT NULL,
        $columnLogActualPriceMinor INTEGER NOT NULL,
        $columnLogNote TEXT NOT NULL DEFAULT '',
        FOREIGN KEY ($columnLogMealId) 
          REFERENCES $tableMeals ($columnId) 
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_logs_meal_id ON $tablePurchaseLogs ($columnLogMealId)
    ''');
  }


  // CREATE - Add a new meal entry
  Future<int> insertMeal(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(tableMeals, row);
  }

  // READ - Get all meals
  Future<List<Map<String, dynamic>>> getAllMeals() async {
    final db = await database;
    return await db.query(tableMeals, orderBy: '$columnMealName ASC');
  }

  // READ - Get a single meal by its ID
  Future<Map<String, dynamic>?> getMeal(int id) async {
    final db = await database;
    final results = await db.query(
      tableMeals,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // UPDATE - Modify existing meal entry
  Future<int> updateMeal(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      tableMeals,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Remove item from meals table
  Future<int> deleteMeal(int id) async {
    final db = await database;
    // With foreign_keys = ON and ON DELETE CASCADE, linked purchase logs are deleted automatically
    return await db.delete(
      tableMeals,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }


  // CREATE - Add a new purchase log entry
  Future<int> insertPurchaseLog(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(tablePurchaseLogs, row);
  }

  // READ - Get all purchase logs for a specific meal
  Future<List<Map<String, dynamic>>> getLogsForMeal(int mealId) async {
    final db = await database;
    return await db.query(
      tablePurchaseLogs,
      where: '$columnLogMealId = ?',
      whereArgs: [mealId],
      orderBy: '$columnLogPurchasedAt DESC',
    );
  }

  // READ - Get all purchase logs, ordered by date  
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    final db = await database;
    return await db.query(tablePurchaseLogs, orderBy: '$columnLogPurchasedAt DESC');
  }

  // UPDATE - Modify existing purchase log entry
  Future<int> updatePurchaseLog(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      tablePurchaseLogs,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Remove item from purchase_logs table
  Future<int> deletePurchaseLog(int id) async {
    final db = await database;
    return await db.delete(
      tablePurchaseLogs,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }


  // Get total spending across all purchase logs
  Future<double> getTotalSpending() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM($columnLogActualPriceMinor) as total FROM $tablePurchaseLogs',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}