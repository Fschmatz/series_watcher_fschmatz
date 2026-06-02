import 'package:sqflite/sqflite.dart';

import '../entity/episode_watched.dart';
import 'database_helper.dart';

class EpisodeWatchedDAO {
  static final EpisodeWatchedDAO instance = EpisodeWatchedDAO._privateConstructor();

  EpisodeWatchedDAO._privateConstructor();

  Future<int> insertEpisodeWatched(EpisodeWatched episode) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tableEpisodesWatched, episode.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<EpisodeWatched>> getWatchedEpisodesByTvShow(int idTvShow) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableEpisodesWatched,
      where: '${DatabaseHelper.columnIdTvShowRef} = ?',
      whereArgs: [idTvShow],
    );

    return List.generate(maps.length, (i) {
      return EpisodeWatched.fromMap(maps[i]);
    });
  }

  Future<bool> isEpisodeWatched(int idEpisode) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableEpisodesWatched,
      where: '${DatabaseHelper.columnIdEpisode} = ?',
      whereArgs: [idEpisode],
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteEpisodeWatched(int idEpisode) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(DatabaseHelper.tableEpisodesWatched, where: '${DatabaseHelper.columnIdEpisode} = ?', whereArgs: [idEpisode]);
  }

  Future<int> deleteAllByTvShow(int idTvShow) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(DatabaseHelper.tableEpisodesWatched, where: '${DatabaseHelper.columnIdTvShowRef} = ?', whereArgs: [idTvShow]);
  }

  Future<List<int>> getAllWatchedEpisodeIds() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableEpisodesWatched, columns: [DatabaseHelper.columnIdEpisode]);
    return maps.map((m) => m[DatabaseHelper.columnIdEpisode] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getHistoryLastTwoMonths() async {
    Database db = await DatabaseHelper.instance.database;
    final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60)).toString();

    final sql =
        '''
      SELECT 
        t.name AS tv_show_name,
        e.name AS episode_name,
        ew.season_number,
        ew.episode_number,
        ew.watch_date
      FROM ${DatabaseHelper.tableEpisodesWatched} ew
      INNER JOIN ${DatabaseHelper.tableTvShows} t ON t.id = ew.id_tv_show
      INNER JOIN ${DatabaseHelper.tableEpisodes} e ON e.id = ew.id_episode
      WHERE ew.watch_date >= ?
      ORDER BY ew.watch_date DESC
      LIMIT 200
    ''';

    return await db.rawQuery(sql, [sixtyDaysAgo]);
  }
  Future<int> getWatchedMinutesCurrentMonth() async {
    Database db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final sql = '''
      SELECT SUM(e.runtime) as total
      FROM ${DatabaseHelper.tableEpisodesWatched} ew
      INNER JOIN ${DatabaseHelper.tableEpisodes} e ON e.id = ew.id_episode
      WHERE ew.watch_date >= ?
    ''';

    final result = await db.rawQuery(sql, [firstDayOfMonth]);
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getWatchedMinutesCurrentYear() async {
    Database db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1).toIso8601String();

    final sql = '''
      SELECT SUM(e.runtime) as total
      FROM ${DatabaseHelper.tableEpisodesWatched} ew
      INNER JOIN ${DatabaseHelper.tableEpisodes} e ON e.id = ew.id_episode
      WHERE ew.watch_date >= ?
    ''';

    final result = await db.rawQuery(sql, [firstDayOfYear]);
    return (result.first['total'] as int?) ?? 0;
  }
}
