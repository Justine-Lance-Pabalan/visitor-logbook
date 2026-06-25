import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/visitor.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'visitor_logbook.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE visitors(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            srCode TEXT NOT NULL,
            department TEXT NOT NULL,
            purpose TEXT NOT NULL,
            propertyUsed TEXT NOT NULL,
            date TEXT NOT NULL,
            timeIn TEXT NOT NULL,
            timeOut TEXT,
            propertyReturned INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE visitors ADD COLUMN pin TEXT NOT NULL DEFAULT '0000'",
          );
        }
      },
    );
  }
  // INSERT — save a new visitor
  static Future<int> insertVisitor(Visitor visitor) async {
    final db = await database;
    return await db.insert('visitors', visitor.toMap());
  }

  // SELECT — load all visitors
  static Future<List<Visitor>> getVisitors() async {
    final db = await database;
    final maps = await db.query('visitors');
    return maps.map((map) => Visitor.fromMap(map)).toList();
  }

  // UPDATE — save changes to an existing visitor
  static Future<int> updateVisitor(Visitor visitor) async {
    final db = await database;
    return await db.update(
      'visitors',
      visitor.toMap(),
      where: 'id = ?',
      whereArgs: [visitor.id],
    );
  }
}