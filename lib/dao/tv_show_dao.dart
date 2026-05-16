import 'package:sqflite/sqflite.dart';

import '../entity/tv_show.dart';
import 'database_helper.dart';

class TvShowDAO {
  static final TvShowDAO instance = TvShowDAO._privateConstructor();

  TvShowDAO._privateConstructor();

  Future<int> insertTvShow(TvShow tvShow) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tableTvShows, tvShow.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TvShow>> getAllTvShows() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableTvShows);

    return List.generate(maps.length, (i) {
      return TvShow.fromMap(maps[i]);
    });
  }

  Future<TvShow?> getTvShowById(int id) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTvShows,
      where: '${DatabaseHelper.columnIdTvShow} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TvShow.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteTvShow(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(DatabaseHelper.tableTvShows, where: '${DatabaseHelper.columnIdTvShow} = ?', whereArgs: [id]);
  }

  Future<int> archiveTvShow(int id, bool archive) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      DatabaseHelper.tableTvShows,
      {DatabaseHelper.columnArchived: archive ? 1 : 0},
      where: '${DatabaseHelper.columnIdTvShow} = ?',
      whereArgs: [id],
    );
  }
}
