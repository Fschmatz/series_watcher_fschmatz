import 'package:flutter/material.dart';

import '../entity/history_item.dart';
import '../service/tv_show_local_service.dart';
import '../util/utils_functions.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _history = [];
  int _minutesMonth = 0;
  int _minutesYear = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await TvShowLocalService().getHistoryCurrentMonth();
    final month = await TvShowLocalService().getWatchedMinutesCurrentMonth();
    final year = await TvShowLocalService().getWatchedMinutesCurrentYear();
    if (mounted) {
      setState(() {
        _history = history;
        _minutesMonth = month;
        _minutesYear = year;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watch History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _history.isEmpty ? 2 : _history.length + 1,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_view_month, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This Month',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_minutesMonth min',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.secondary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This Year',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_minutesYear min',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No history for this month')),
                  );
                }

                final item = _history[index - 1];
                final s = item.seasonNumber.toString().padLeft(2, '0');
                final e = item.episodeNumber.toString().padLeft(2, '0');

                return Column(
                  children: [
                    ListTile(
                      key: ValueKey("${item.tvShowName}_${item.seasonNumber}_${item.episodeNumber}"),
                      title: Text(item.tvShowName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('S${s}E$e - ${item.episodeName}'),
                      trailing: Text(UtilsFunctions.formatDate(item.watchDate)),
                    ),
                    if (index < _history.length) const Divider(),
                  ],
                );
              },
            ),
    );
  }
}
