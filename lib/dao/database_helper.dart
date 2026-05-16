import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static const _databaseName = "SeriesWatcher.db";
  static const _databaseVersion = 1;

  // TV Shows
  static const tableTvShows = 'tv_shows';
  static const columnIdTvShow = 'id'; // TMDB ID
  static const columnName = 'name';
  static const columnOriginalName = 'original_name';
  static const columnOverview = 'overview';
  static const columnPosterPath = 'poster_path';
  static const columnPosterImage = 'poster_image';
  static const columnBackdropPath = 'backdrop_path';
  static const columnFirstAirDate = 'first_air_date';
  static const columnVoteAverage = 'vote_average';
  static const columnNumberOfSeasons = 'number_of_seasons';
  static const columnNumberOfEpisodes = 'number_of_episodes';
  static const columnStatus = 'status';
  static const columnPopularity = 'popularity';
  static const columnArchived = 'archived';

  // Seasons
  static const tableSeasons = 'seasons';
  static const columnIdSeason = 'id';
  static const columnIdTvShowSeason = 'id_tv_show';
  static const columnSeasonAirDate = 'air_date';
  static const columnSeasonEpisodeCount = 'episode_count';
  static const columnSeasonName = 'name';
  static const columnSeasonOverview = 'overview';
  static const columnSeasonPosterPath = 'poster_path';
  static const columnSeasonPosterImage = 'poster_image';
  static const columnSeasonNumber = 'season_number';

  // Episodes
  static const tableEpisodes = 'episodes';
  static const columnIdEpisodeDetail = 'id';
  static const columnIdSeasonEpisode = 'id_season';
  static const columnEpisodeAirDate = 'air_date';
  static const columnEpisodeNumberDetail = 'episode_number';
  static const columnEpisodeName = 'name';
  static const columnEpisodeOverview = 'overview';
  static const columnEpisodeStillPath = 'still_path';
  static const columnEpisodeStillImage = 'still_image';
  static const columnEpisodeVoteAverage = 'vote_average';
  static const columnEpisodeRuntime = 'runtime';

  // Episodes Watched (User Progress)
  static const tableEpisodesWatched = 'episodes_watched';
  static const columnIdEpisode = 'id_episode'; // TMDB ID
  static const columnIdTvShowRef = 'id_tv_show';
  static const columnSeasonNumberWatched = 'season_number';
  static const columnEpisodeNumberWatched = 'episode_number';
  static const columnWatchDate = 'watch_date';

  // App Parameters
  static const tableAppParameters = 'app_parameters';
  static const columnParamKey = 'key';
  static const columnParamValue = 'value';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async =>
      _database ??= await initDatabase();

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''    
           CREATE TABLE $tableTvShows (
             $columnIdTvShow INTEGER PRIMARY KEY,
             $columnName TEXT NOT NULL,
             $columnOriginalName TEXT,
             $columnOverview TEXT,
             $columnPosterPath TEXT,
             $columnPosterImage TEXT,
             $columnBackdropPath TEXT,
             $columnFirstAirDate TEXT,
             $columnVoteAverage REAL,
             $columnNumberOfSeasons INTEGER,
             $columnNumberOfEpisodes INTEGER,
             $columnStatus TEXT,
             $columnPopularity REAL,
             $columnArchived INTEGER NOT NULL DEFAULT 0
          )          
          ''');

    await db.execute('''    
           CREATE TABLE $tableSeasons (
             $columnIdSeason INTEGER PRIMARY KEY,
             $columnIdTvShowSeason INTEGER NOT NULL,
             $columnSeasonAirDate TEXT,
             $columnSeasonEpisodeCount INTEGER,
             $columnSeasonName TEXT,
             $columnSeasonOverview TEXT,
             $columnSeasonPosterPath TEXT,
             $columnSeasonPosterImage TEXT,
             $columnSeasonNumber INTEGER NOT NULL,
             FOREIGN KEY ($columnIdTvShowSeason) REFERENCES $tableTvShows ($columnIdTvShow) ON DELETE CASCADE
          )          
          ''');

    await db.execute('''    
           CREATE TABLE $tableEpisodes (
             $columnIdEpisodeDetail INTEGER PRIMARY KEY,
             $columnIdSeasonEpisode INTEGER NOT NULL,
             $columnEpisodeAirDate TEXT,
             $columnEpisodeNumberDetail INTEGER NOT NULL,
             $columnEpisodeName TEXT,
             $columnEpisodeOverview TEXT,
             $columnEpisodeStillPath TEXT,
             $columnEpisodeStillImage TEXT,
             $columnEpisodeVoteAverage REAL,
             $columnEpisodeRuntime INTEGER,
             FOREIGN KEY ($columnIdSeasonEpisode) REFERENCES $tableSeasons ($columnIdSeason) ON DELETE CASCADE
          )          
          ''');

    await db.execute('''    
           CREATE TABLE $tableEpisodesWatched (
             $columnIdEpisode INTEGER PRIMARY KEY,
             $columnIdTvShowRef INTEGER NOT NULL,
             $columnSeasonNumberWatched INTEGER NOT NULL,
             $columnEpisodeNumberWatched INTEGER NOT NULL,            
             $columnWatchDate TEXT NOT NULL
          )          
          ''');

    await db.execute('''
          CREATE TABLE $tableAppParameters (
            $columnParamKey TEXT PRIMARY KEY,
            $columnParamValue TEXT
          )
          ''');
  }
}
