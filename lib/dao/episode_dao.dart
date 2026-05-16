import 'package:sqflite/sqflite.dart';

import '../entity/episode.dart';
import 'database_helper.dart';

class EpisodeDAO {
  static final EpisodeDAO instance = EpisodeDAO._privateConstructor();

  EpisodeDAO._privateConstructor();

  Future<int> insertEpisode(Episode episode) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tableEpisodes, episode.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Episode>> getEpisodesBySeason(int idSeason) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, s.${DatabaseHelper.columnSeasonNumber}
      FROM ${DatabaseHelper.tableEpisodes} e
      JOIN ${DatabaseHelper.tableSeasons} s ON e.${DatabaseHelper.columnIdSeasonEpisode} = s.${DatabaseHelper.columnIdSeason}
      WHERE e.${DatabaseHelper.columnIdSeasonEpisode} = ?
      ORDER BY e.${DatabaseHelper.columnEpisodeNumberDetail}
    ''', [idSeason]);

    return List.generate(maps.length, (i) {
      return Episode.fromMap(maps[i]);
    });
  }

  Future<void> deleteBySeason(int idSeason) async {
    Database db = await DatabaseHelper.instance.database;
    await db.delete(DatabaseHelper.tableEpisodes, where: '${DatabaseHelper.columnIdSeasonEpisode} = ?', whereArgs: [idSeason]);
  }

  Future<Episode?> getNextEpisodeToWatch(int idTvShow) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT e.*, s.${DatabaseHelper.columnSeasonNumber} 
      FROM ${DatabaseHelper.tableEpisodes} e
      JOIN ${DatabaseHelper.tableSeasons} s ON e.${DatabaseHelper.columnIdSeasonEpisode} = s.${DatabaseHelper.columnIdSeason}
      WHERE s.${DatabaseHelper.columnIdTvShowSeason} = ? 
        AND s.${DatabaseHelper.columnSeasonNumber} != 0
        AND e.${DatabaseHelper.columnIdEpisodeDetail} NOT IN (SELECT ${DatabaseHelper.columnIdEpisode} FROM ${DatabaseHelper.tableEpisodesWatched} WHERE ${DatabaseHelper.columnIdTvShowRef} = ?)
      ORDER BY s.${DatabaseHelper.columnSeasonNumber}, e.${DatabaseHelper.columnEpisodeNumberDetail}
      LIMIT 1
    ''',
      [idTvShow, idTvShow],
    );

    if (maps.isNotEmpty) {
      return Episode.fromMap(maps.first);
    }

    return null;
  }

  Future<int> getRemainingEpisodesCount(int idTvShow) async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT COUNT(e.${DatabaseHelper.columnIdEpisodeDetail}) as count
      FROM ${DatabaseHelper.tableEpisodes} e
      JOIN ${DatabaseHelper.tableSeasons} s ON e.${DatabaseHelper.columnIdSeasonEpisode} = s.${DatabaseHelper.columnIdSeason}
      WHERE s.${DatabaseHelper.columnIdTvShowSeason} = ? 
        AND s.${DatabaseHelper.columnSeasonNumber} != 0
        AND e.${DatabaseHelper.columnIdEpisodeDetail} NOT IN (SELECT ${DatabaseHelper.columnIdEpisode} FROM ${DatabaseHelper.tableEpisodesWatched} WHERE ${DatabaseHelper.columnIdTvShowRef} = ?)
      ''',
      [idTvShow, idTvShow],
    );

    if (maps.isNotEmpty) {
      return Sqflite.firstIntValue(maps) ?? 0;
    }
    return 0;
  }
}
