import 'package:sqflite/sqflite.dart';
import 'package:projecten/database/database_service.dart';
import 'package:projecten/data_model/models.dart';

class Doelen {
  final tabelNaam = 'doelen';
  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tabelNaam(
    "id" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "created_at" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int
    "updated_at" INTEGER,
    PRIMARY KEY("id" AUTONCREMENT)
    );""");
  }

  Future<int> create({required String title}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $tabelNaam (title,created_at) VALUES (?,?)''',
            [title, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<List<Doel>> fetchAll() async {
    final database = await DatabaseService().database;
    final doelen = await database.rawQuery(
        """SELECT * from $tabelNaam ORDER BY COALESCE(updated_at,created_at""");
    return doelen.map((doen) => Doel.fromSqfliteDatabase(doen)).toList();
  }

  Future<Doel> fetchById(int id) async {
    final database = await DatabaseService().database;
    final doel = await database.rawQuery(
      """SELECT * from $tabelNaam WHERE id = ?""", [id]);
    return Doel.fromSqfliteDatabase(doel.first);
  }

  Future<int> update({required int id, String? title}) async {
    final database = await DatabaseService().database;
    return await database.update(
        tabelNaam,
        {
            if (title != null) 'title': title,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
        where: 'id = ?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tabelNaam WHERE id = ?''', [id]);
  }

}

