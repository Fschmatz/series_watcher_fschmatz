import 'package:async_redux/async_redux.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:series_watcher_fschmatz/redux/actions.dart';
import 'package:series_watcher_fschmatz/redux/app_state.dart';

import 'app_theme.dart';

final Store<AppState> store = Store<AppState>(
  initialState: AppState.initialState(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 50;

  store.dispatch(LoadAppParametersAction());
  store.dispatch(LoadTvShowsAction());
  store.dispatch(LoadWatchedEpisodesAction());

  runApp(
    StoreProvider<AppState>(
      store: store,
      child: EasyDynamicThemeWidget(
        child: const AppTheme(),
      ),
    ),
  );
}
