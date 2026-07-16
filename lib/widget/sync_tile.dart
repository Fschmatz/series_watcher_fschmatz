import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../enum/sync_mode.dart';
import '../redux/actions.dart';
import '../util/toast_utils.dart';
import 'app_parameter_value.dart';

class SyncTile extends StatelessWidget {
  final bool isSyncing;
  final String title;
  final String subtitle;
  final SyncMode mode;
  final String parameterKey;
  final String toastMsg;
  final Icon icon;

  const SyncTile({
    super.key,
    required this.isSyncing,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.parameterKey,
    required this.toastMsg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: isSyncing
            ? null
            : () {
                context.dispatch(SyncTvShowsAction(mode: mode));
                ToastUtils.show(toastMsg);
              },
        leading: icon,
        title: Text(title),
        enabled: !isSyncing,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("Last sync: "),
                AppParameterValue(parameterKey: parameterKey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
