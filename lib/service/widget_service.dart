import 'dart:convert';
import 'dart:typed_data';
import 'package:home_widget/home_widget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../entity/tv_show.dart';
class WidgetService {
  static const String androidWidgetName = 'TvShowWidgetProvider';

  static Future<void> updateNextEpisodeWidget(List<TvShow> tvShows) async {
    try {
      final activeShows = tvShows.where((show) => !show.isArchived && show.showInWidget && show.nextEpisodeInfo != null).toList();

      final List<Map<String, String>> showsData = [];

      for (var show in activeShows) {
        String durationText = '';
        if (show.nextEpisodeRuntime != null && show.nextEpisodeRuntime! > 0) {
          durationText = '${show.nextEpisodeRuntime} min';
        }

        String base64Cover = '';

        if (show.posterBytes != null) {
          try {
            final Uint8List compressedCover = await FlutterImageCompress.compressWithList(
              show.posterBytes!,
              minHeight: 100,
              minWidth: 100,
              quality: 70,
              format: CompressFormat.jpeg,
            );
            base64Cover = base64Encode(compressedCover);
          } catch (e) {
            base64Cover = show.posterImage ?? '';
          }
        }

        showsData.add({
          'id': show.id.toString(),
          'show_name': show.name ?? 'Unknown',
          'next_episode': show.nextEpisodeInfo ?? '',
          'duration': durationText,
          'cover': base64Cover,
        });
      }

      final jsonString = jsonEncode(showsData);

      await HomeWidget.saveWidgetData<String>('tv_shows_json', jsonString);

      await HomeWidget.updateWidget(
        name: androidWidgetName,
      );
    } catch (e) {
      // Ignore errors
    }
  }
}
