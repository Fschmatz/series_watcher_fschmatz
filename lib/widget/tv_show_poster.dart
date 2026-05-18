import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../util/api_configs.dart';

class TvShowPoster extends StatelessWidget {
  final TvShow? tvShow;
  final double width;
  final double height;
  final double borderRadius;

  const TvShowPoster({super.key, required this.tvShow, this.width = 100, this.height = 180, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: _buildImage(context));
  }

  Widget _buildImage(BuildContext context) {
    if (tvShow?.posterBytes != null) {
      return Image.memory(
        tvShow!.posterBytes!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else if (tvShow?.posterPath != null) {
      return Image.network(
        '${ApiConfigs.imageBaseUrl}${tvShow!.posterPath}',
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    } else {
      return _buildPlaceholder(context);
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.movie_outlined),
    );
  }
}
