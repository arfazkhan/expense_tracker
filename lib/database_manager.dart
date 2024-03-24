import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/transaction_model.dart';

class DatabaseManager {
  DatabaseManager._(); // private constructor
  static final DatabaseManager instance = DatabaseManager._();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE transactions(id INTEGER PRIMARY KEY, date TEXT, title TEXT, price REAL)",
        );
      },
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('transactions');
    return List.generate(maps.length, (i) {
      return TransactionModel(
        id: maps[i]['id'],
        date: DateTime.parse(maps[i]['date']),
        title: maps[i]['title'],
        price: maps[i]['price'],
      );
    });
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await db!.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db!.delete(
      'transactions',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
