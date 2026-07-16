import 'package:flutter/material.dart';

import '../enum/sync_mode.dart';
import '../redux/app_state.dart';
import '../util/app_constants.dart';
import '../widget/sync_tile.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSyncing = context.select((AppState state) => state.isSyncingShows);

    return Scaffold(
      appBar: AppBar(title: const Text("Synchronization")),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    SyncTile(
                      isSyncing: isSyncing,
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      title: "Sync watchlist series",
                      subtitle: "Update series not archived",
                      mode: SyncMode.watchlist,
                      parameterKey: AppConstants.lastSyncWatchlistDateAppParameter,
                      toastMsg: "Synchronizing watchlist series...",
                    ),
                    const Divider(height: 1),
                    SyncTile(
                      isSyncing: isSyncing,
                      icon: const Icon(Icons.fact_check_outlined),
                      title: "Sync active series",
                      subtitle: "Update series that have not ended",
                      mode: SyncMode.active,
                      parameterKey: AppConstants.lastSyncActiveDateAppParameter,
                      toastMsg: "Synchronizing active series...",
                    ),
                    const Divider(height: 1),
                    SyncTile(
                      isSyncing: isSyncing,
                      icon: const Icon(Icons.done_all_outlined),
                      title: "Sync all series",
                      subtitle: "Update all saved series",
                      mode: SyncMode.all,
                      parameterKey: AppConstants.lastSyncDateAppParameter,
                      toastMsg: "Synchronizing all series...",
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isSyncing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text("Synchronizing...", style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
