import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import '../entity/backup.dart';
import '../service/app_parameter_service.dart';

class BackupUtils {
 /* final playlistDao = PlaylistDao.instance;

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

    if (backup['playlists'].isNotEmpty) {
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

  *//*  try {
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
    }*//*
  }

  Future<Map<String, dynamic>> _loadBackupData() async {
    List<Map<String, dynamic>> playlistsJson = await playlistDao.queryAllRows();
    List<Map<String, dynamic>> parametersJson = await AppParameterService().loadAllParameters();

    Backup backupEntity = Backup(playlists: playlistsJson, parameters: parametersJson);

    Map<String, dynamic> backupJson = backupEntity.toJson();

    return backupJson;
  }

  Future<void> _deleteAllData() async {
    await playlistDao.deleteAll();
    await AppParameterService().deleteAllParameters();
  }

  Future<void> _insertBackupData(Backup backup) async {
    await PlaylistService().insertBackupData(backup);

    await AppParameterService().insertParametersFromRestoreBackup(backup.parameters);
  }*/
}
