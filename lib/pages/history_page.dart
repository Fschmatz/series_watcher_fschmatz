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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await TvShowLocalService().getHistoryLastTwoMonths();
    if (mounted) {
      setState(() {
        _history = history;
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
          : _history.isEmpty
          ? const Center(child: Text('No history for the last 2 months'))
          : ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final s = item.seasonNumber.toString().padLeft(2, '0');
                final e = item.episodeNumber.toString().padLeft(2, '0');

                return ListTile(
                  key: ValueKey("${item.tvShowName}_${item.seasonNumber}_${item.episodeNumber}"),
                  title: Text(item.tvShowName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('S${s}E$e - ${item.episodeName}'),
                  trailing: Text(UtilsFunctions.formatDate(item.watchDate)),
                );
              },
            ),
    );
  }
}
