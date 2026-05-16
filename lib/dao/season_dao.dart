import 'package:sqflite/sqflite.dart';
import '../entity/season.dart';
import 'database_helper.dart';

class SeasonDAO {
  static final SeasonDAO instance = SeasonDAO._privateConstructor();
  SeasonDAO._privateConstructor();

  Future<int> insertSeason(Season season) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tableSeasons, season.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Season>> getSeasonsByTvShow(int idTvShow) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSeasons,
      where: '${DatabaseHelper.columnIdTvShowSeason} = ?',
      whereArgs: [idTvShow],
      orderBy: DatabaseHelper.columnSeasonNumber,
    );

    return List.generate(maps.length, (i) {
      return Season.fromMap(maps[i]);
    });
  }

  Future<void> deleteByTvShow(int idTvShow) async {
    Database db = await DatabaseHelper.instance.database;
    await db.delete(
      DatabaseHelper.tableSeasons,
      where: '${DatabaseHelper.columnIdTvShowSeason} = ?',
      whereArgs: [idTvShow],
    );
  }
}
