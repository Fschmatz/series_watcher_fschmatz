import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../dao/database_helper.dart';
import '../entity/backup.dart';
import '../service/app_parameter_service.dart';
import 'toast_utils.dart';
import 'utils_functions.dart';

class BackupUtils {
  Future<bool> backupData() async {
    Map<String, dynamic> backup = await _loadBackupData();

    if (backup['tvShows'].isNotEmpty || backup['appParameters'].isNotEmpty) {
      bool success = await _saveListAsJsonAndShare(backup);
      if (success) {
        await AppParameterService().saveLastBackupDate();
        ToastUtils.show('Backup completed!');
        return true;
      }
      return false;
    } else {
      ToastUtils.showErrorMessage('No data found!');
      return false;
    }
  }

  Future<bool> _saveListAsJsonAndShare(Map<String, dynamic> data) async {
    try {
      final directory = await getTemporaryDirectory();
      final newFileName = UtilsFunctions.getBackupFilename();

      final file = File('${directory.path}/$newFileName');

      await file.writeAsString(json.encode(data));

      await Share.shareXFiles([XFile(file.path)], text: 'Backup $newFileName');
      return true;
    } catch (e) {
      ToastUtils.showErrorMessage('Error!');
      return false;
    }
  }

  Future<bool> restoreBackupData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        Backup backup = Backup.fromJson(json.decode(jsonString));

        await _deleteAllData();
        await _insertBackupData(backup);

        ToastUtils.show('Success!');
        return true;
      }
      return false;
    } catch (e) {
      ToastUtils.showErrorMessage('Error!');
      return false;
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
