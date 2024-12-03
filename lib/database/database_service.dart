import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:projecten/database/database.dart';
class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }


  Future<String> get padnaardb async {
    const naam = 'data.db';
    final pad = await getDatabasesPath();
    return join(pad, naam);
  }

  Future<Database> _initialize() async {
    final pad = await padnaardb;
    var database = await openDatabase(
      pad,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> create(Database database, int version) async =>
      await Doelen().createTable(database);
}