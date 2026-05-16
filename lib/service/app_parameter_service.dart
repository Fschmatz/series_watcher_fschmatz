import 'package:series_watcher_fschmatz/util/app_constants.dart';

import '../dao/app_parameter_dao.dart';
import '../entity/app_parameter.dart';
import 'store_service.dart';

class AppParameterService extends StoreService {
  final dbParams = AppParameterDAO.instance;

  Future<void> saveParameter(AppParameter parameter) async {
    await dbParams.insertOrUpdate(parameter.toMap());
    await loadAppParameters();
  }

  Future<void> deleteParameter(String key) async {
    await dbParams.delete(key);
    await loadAppParameters();
  }

  Future<List<AppParameter>> getAll() async {
    var resp = await dbParams.queryAllRows();

    return resp.isNotEmpty ? resp.map((map) => AppParameter.fromMap(map)).toList() : [];
  }

  Future<void> saveLastBackupDate() async {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    await saveParameter(AppParameter(key: AppConstants.lastBackupDateAppParameter, value: formattedDate));
  }

  Future<void> saveLastSyncDate() async {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    await saveParameter(AppParameter(key: AppConstants.lastSyncDateAppParameter, value: formattedDate));
  }

  Future<String?> getLastBackupDate() async {
    var resp = await dbParams.queryByKey(AppConstants.lastBackupDateAppParameter);
    return resp != null ? AppParameter.fromMap(resp).getValue() : null;
  }

  Future<List<Map<String, dynamic>>> loadAllParameters() {
    return dbParams.queryAllRows();
  }

  Future<void> deleteAllParameters() async {
    await dbParams.deleteAll();
  }

  Future<void> insertParametersFromRestoreBackup(List<dynamic> jsonData) async {
    for (var item in jsonData) {
      await dbParams.insertOrUpdate(item as Map<String, dynamic>);
    }
    await loadAppParameters();
  }
}
