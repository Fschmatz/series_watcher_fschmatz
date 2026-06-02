import 'package:flutter/material.dart';

class AppConstants {
  // WIDGETS
  static const EdgeInsets marginSeriesCards = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  // APP PARAMETERS
  static const String lastBackupDateAppParameter = "lastBackupDate";
  static const String lastSyncDateAppParameter = "lastSyncDate";

  // STRINGS
  static const String appVersion = "1.2.3";
  static const String backupFileName = "series_watcher_backup";
  static const String appName = "Series Watcher Fschmatz";
  static const String appNameHomePage = "Series Watcher";
  static const String repositoryLink = "https://github.com/Fschmatz/series_watcher_fschmatz";
  static const String changelogCurrent =
      '''
$appVersion
- Bottom sheet onHold
- History page updates
- Add episode duration on home cards
- UI changes
- Fix bugs
''';

  static const String changelogsOld = '''
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
