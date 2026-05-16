import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../dao/database_helper.dart';
import '../entity/backup.dart';
import '../service/app_parameter_service.dart';

class BackupUtils {

  Future<void> _loadStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  // Always using Android Download folder
  Future<String> _loadDirectory() async {
    bool dirDownloadExists = true;
    String directory = "/storage/emulated/0/Download/";

    dirDownloadExists = await Directory(directory).exists();
    if (dirDownloadExists) {
      directory = "/storage/emulated/0/Download/";
    } else {
      directory = "/storage/emulated/0/Downloads/";
    }

    return directory;
  }

  Future<void> backupData(String fileName) async {
    await _loadStoragePermission();

    Map<String, dynamic> backup = await _loadBackupData();

    if (backup['tvShows'].isNotEmpty || backup['appParameters'].isNotEmpty) {
      await _saveListAsJson(backup, fileName);
      await AppParameterService().saveLastBackupDate();

      Fluttertoast.showToast(
        msg: "Backup completed!",
      );
    } else {
      Fluttertoast.showToast(
        msg: "No data found!",
      );
    }
  }

  Future<void> _saveListAsJson(Map<String, dynamic> data, String fileName) async {
    try {
      String directory = await _loadDirectory();

      final file = File('$directory/$fileName.json');

      await file.writeAsString(json.encode(data));
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error!",
      );
    }
  }

  Future<void> restoreBackupData(String fileName) async {
    await _loadStoragePermission();

    try {
      String directory = await _loadDirectory();

      final file = File('$directory/$fileName.json');
      final jsonString = await file.readAsString();
      Backup backup = Backup.fromJson(json.decode(jsonString));

      await _deleteAllData();
      await _insertBackupData(backup);

      Fluttertoast.showToast(
        msg: "Success!",
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error!",
      );
    }
  }

  Future<Map<String, dynamic>> _loadBackupData() async {
    Database db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> tvShows = await db.query(DatabaseHelper.tableTvShows);
    List<Map<String, dynamic>> seasons = await db.query(DatabaseHelper.tableSeasons);
    List<Map<String, dynamic>> episodes = await db.query(DatabaseHelper.tableEpisodes);
    List<Map<String, dynamic>> episodesWatched = await db.query(DatabaseHelper.tableEpisodesWatched);
    List<Map<String, dynamic>> appParameters = await AppParameterService().loadAllParameters();

    Backup backupEntity = Backup(
      tvShows: tvShows,
      seasons: seasons,
      episodes: episodes,
      episodesWatched: episodesWatched,
      appParameters: appParameters,
    );

    return backupEntity.toJson();
  }

  Future<void> _deleteAllData() async {
    Database db = await DatabaseHelper.instance.database;

    await db.delete(DatabaseHelper.tableEpisodesWatched);
    await db.delete(DatabaseHelper.tableEpisodes);
    await db.delete(DatabaseHelper.tableSeasons);
    await db.delete(DatabaseHelper.tableTvShows);

    await AppParameterService().deleteAllParameters();
  }

  Future<void> _insertBackupData(Backup backup) async {
    Database db = await DatabaseHelper.instance.database;

    for (var tvShow in backup.tvShows) {
      await db.insert(DatabaseHelper.tableTvShows, tvShow, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var season in backup.seasons) {
      await db.insert(DatabaseHelper.tableSeasons, season, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var episode in backup.episodes) {
      await db.insert(DatabaseHelper.tableEpisodes, episode, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (var episodeWatched in backup.episodesWatched) {
      await db.insert(DatabaseHelper.tableEpisodesWatched, episodeWatched, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await AppParameterService().insertParametersFromRestoreBackup(backup.appParameters);
  }
}
