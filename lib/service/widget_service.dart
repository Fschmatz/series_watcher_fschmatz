import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../entity/tv_show.dart';

class WidgetService {
  static const String androidWidgetName = 'TvShowWidgetProvider';

  static Future<void> updateNextEpisodeWidget(List<TvShow> tvShows) async {
    try {
      final activeShows = tvShows.where((show) => !show.isArchived && show.showInWidget && show.nextEpisodeInfo != null).toList();

      final List<Map<String, String>> showsData = activeShows.map((show) {
        String durationText = '';
        if (show.nextEpisodeRuntime != null && show.nextEpisodeRuntime! > 0) {
          durationText = '${show.nextEpisodeRuntime} min';
        }
        return {
          'show_name': show.name ?? 'Unknown',
          'next_episode': show.nextEpisodeInfo ?? '',
          'duration': durationText,
        };
      }).toList();

      final jsonString = jsonEncode(showsData);

      await HomeWidget.saveWidgetData<String>('tv_shows_json', jsonString);

      await HomeWidget.updateWidget(
        name: androidWidgetName,
      );
    } catch (e) {
      // Ignore errors if widget is not present or supported
    }
  }
}
