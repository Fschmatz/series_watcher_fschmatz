import 'package:async_redux/async_redux.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../util/dialog_backup.dart';
import '../../util/dialog_select_theme.dart';
import '../../util/utils_functions.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../util/app_constants.dart';
import '../widget/app_parameter_value.dart';
import 'app_info.dart';
import 'changelog.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => SettingsState();

  const Settings({super.key});
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    Color themeColorApp = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: <Widget>[
          Card(
            elevation: 1,
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 25),
            color: themeColorApp,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            child: ListTile(
              title: Text(
                "${AppConstants.appName} ${AppConstants.appVersion}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17.5, color: Colors.black),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "General",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp),
            ),
          ),
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return const DialogSelectTheme();
              },
            ),
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text("App theme"),
            subtitle: Text(UtilsFunctions.getThemeStringFormatted(EasyDynamicTheme.of(context).themeMode)),
          ),
          /*       const SettingsSwitch(
              title: "Show album info",
              subtitle: "Show title and artist on card",
              parameterKey: "showAlbumInfo",
              defaultValue: true,
            ),*/
          ListTile(
            title: Text(
              "Data",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp),
            ),
          ),
          StoreConnector<AppState, ({bool isSyncing, VoidCallback onSync})>(
            converter: (store) => (
              isSyncing: store.state.isSyncingShows,
              onSync: () => store.dispatch(SyncTvShowsAction()),
            ),
            builder: (context, viewData) => ListTile(
              onTap: viewData.isSyncing ? null : () {
                viewData.onSync();
                Fluttertoast.showToast(msg: "Synchronizing series...");
              },
              leading: viewData.isSyncing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.sync),
              title: const Text("Sync series data"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Update seasons and episodes for offline use"),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text("Last sync: "),
                      AppParameterValue(parameterKey: AppConstants.lastSyncDateAppParameter),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Backup",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp),
            ),
          ),

          ListTile(
            onTap: () async {
              bool? result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return const DialogBackup(isCreateBackup: true);
                },
              );

              if (result == true && context.mounted) {
                StoreProvider.dispatch<AppState>(context, LoadAppParametersAction());
              }
            },
            leading: const Icon(Icons.save_outlined),
            title: const Text("Backup now"),
            subtitle: Row(
              children: [
                Text("Last backup: "),
                AppParameterValue(parameterKey: AppConstants.lastBackupDateAppParameter),
              ],
            ),
          ),
          ListTile(
            onTap: () async {
              bool? result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return const DialogBackup(isCreateBackup: false);
                },
              );

              if (result == true && context.mounted) {
                StoreProvider.dispatch<AppState>(context, LoadAppParametersAction());
                StoreProvider.dispatch<AppState>(context, LoadTvShowsAction());
                StoreProvider.dispatch<AppState>(context, LoadWatchedEpisodesAction());
              }
            },
            leading: const Icon(Icons.settings_backup_restore_outlined),
            title: const Text("Restore from backup"),
          ),
          ListTile(
            title: Text(
              "About",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App info"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AppInfo()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text("Changelog"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Changelog()));
            },
          ),
        ],
      ),
    );
  }
}
