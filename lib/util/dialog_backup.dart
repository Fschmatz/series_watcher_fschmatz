import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'backup_utils.dart';

class DialogBackup extends StatefulWidget {
  final bool isCreateBackup;

  const DialogBackup({super.key, required this.isCreateBackup});

  @override
  State<DialogBackup> createState() => _DialogBackupState();
}

class _DialogBackupState extends State<DialogBackup> {
  Future<void> _createBackup() async {
    await BackupUtils().backupData(AppConstants.backupFileName);
  }

  Future<void> _restoreFromBackup() async {
    await BackupUtils().restoreBackupData(AppConstants.backupFileName);
  }

  Future<void> _executeBackup() async {
    Navigator.of(context).pop();

    if (widget.isCreateBackup) {
      _createBackup();
    } else {
      _restoreFromBackup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm"),
      content: Text(widget.isCreateBackup ? "Create backup ?" : "Restore backup ?"),
      actions: [
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            _executeBackup();
          },
        ),
      ],
    );
  }
}
