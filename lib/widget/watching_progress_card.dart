import 'package:flutter/material.dart';

class WatchingProgressCard extends StatelessWidget {
  final int watchedCount;
  final int totalCount;
  final double progress;
  final EdgeInsetsGeometry? margin;

  const WatchingProgressCard({super.key, required this.watchedCount, required this.totalCount, required this.progress, this.margin});

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (progress * 100).toInt();

    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.insights_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Watching Progress',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
              Text(
                '$watchedCount / $totalCount ($progressPercentage%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
