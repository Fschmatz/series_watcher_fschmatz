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
import 'changelog.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => SettingsState();

  const Settings({super.key});
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "General",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Data",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: StoreConnector<AppState, ({bool isSyncing, VoidCallback onSync})>(
                    converter: (store) => (isSyncing: store.state.isSyncingShows, onSync: () => store.dispatch(SyncTvShowsAction())),
                    builder: (context, viewData) => ListTile(
                      onTap: viewData.isSyncing
                          ? null
                          : () {
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text("Last sync: ", style: TextStyle(fontSize: 12)),
                              AppParameterValue(parameterKey: AppConstants.lastSyncDateAppParameter),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Backup",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
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
                            const Text("Last backup: ", style: TextStyle(fontSize: 12)),
                            AppParameterValue(parameterKey: AppConstants.lastBackupDateAppParameter),
                          ],
                        ),
                      ),
                      Divider(),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "About",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text("Changelog"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Changelog()));
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Source Code",
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    onTap: () {
                      UtilsFunctions.openGithubRepository();
                    },
                    leading: const Icon(Icons.open_in_new_outlined),
                    title: const Text("View on GitHub"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
