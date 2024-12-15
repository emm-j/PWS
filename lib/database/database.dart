import 'package:sqflite/sqflite.dart';
import 'package:projecten/database/database_service.dart';
import 'package:projecten/data_model/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projecten/database/database_service.dart';
import 'package:projecten/data_model/models.dart';

class Doelen {
  final tabelNaam = 'doelen';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tabelNaam(
      level INTEGER PRIMARY KEY,
      gehaald INTEGER NOT NULL DEFAULT 0
    );""");
  }

  Future<int> create({required int level, required bool gehaald}) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tabelNaam,
      {
        'level': level,
        'gehaald': gehaald ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Zorgt ervoor dat bestaande records worden overschreven
    );
  }

  Future<List<Doel>> fetchAll() async {
    final database = await DatabaseService().database;
    final doelen = await database.rawQuery(
      "SELECT * FROM $tabelNaam ORDER BY level ASC",
    );
    return doelen.map((doel) => Doel.fromSqfliteDatabase(doel)).toList();
  }

  Future<Doel?> fetchByLevel(int level) async {
    final database = await DatabaseService().database;
    final doelen = await database.query(
      tabelNaam,
      where: 'level = ?',
      whereArgs: [level],
    );
    if (doelen.isNotEmpty) {
      return Doel.fromSqfliteDatabase(doelen.first);
    }
    return null;
  }

  Future<int> update({required int level, required bool gehaald}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tabelNaam,
      {'gehaald': gehaald ? 1 : 0},
      where: 'level = ?',
      whereArgs: [level],
    );
  }

  Future<void> delete(int level) async {
    final database = await DatabaseService().database;
    await database.delete(
      tabelNaam,
      where: 'level = ?',
      whereArgs: [level],
    );
  }
}
