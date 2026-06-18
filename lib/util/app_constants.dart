import 'package:flutter/material.dart';

class AppConstants {
  // WIDGETS
  static const EdgeInsets marginSeriesCards = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  // APP PARAMETERS
  static const String lastBackupDateAppParameter = "lastBackupDate";
  static const String lastSyncDateAppParameter = "lastSyncDate";
  static const String showNextEpisodeNameAppParameter = "showNextEpisodeName";
  static const String showNextEpisodeDurationAppParameter = "showNextEpisodeDuration";
  static const String showRemainingEpisodesAppParameter = "showRemainingEpisodes";
  static const String showSeriesStatusAppParameter = "showSeriesStatus";

  // STRINGS
  static const String appVersion = "1.4.1";
  static const String backupFileName = "series_watcher_backup";
  static const String appName = "Series Watcher Fschmatz";
  static const String appNameHomePage = "Series Watcher";
  static const String repositoryLink = "https://github.com/Fschmatz/series_watcher_fschmatz";
  static const String changelogCurrent =
  '''
$appVersion
- Add image to widget
- UI changes
- Flutter 3.44
''';

  static const String changelogsOld = '''
1.3.2
- Add widget
- Home settings
- UI changes
- Fix bugs
- New Redux logic

1.2.3
- Bottom sheet onHold
- History page updates
- Add episode duration on home cards
- UI changes
- Fix bugs

1.1.0
- More UI changes
- Add button to mark episode as watched
- Fix bugs

1.0.0
- Add remaining episodes
- Material Expressive Design
- UI changes

0.6.0
- UI Changes
- Add backup and restore
- Add delete TV Shows
- Add History Page

0.5.0  
- Add insert TV Shows
- Add mark season as watched
- Delete TV Show from watchlist
- Add mark episode as watched
- Show seasons and episodes of TV Show
- Add tables
- Add AppParameters
- Home
- Get API data
- Bug fixes
- Save
- DB  
  
0.1.0
- Project start 
''';
}
