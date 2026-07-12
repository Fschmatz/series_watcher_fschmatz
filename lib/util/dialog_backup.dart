import 'package:flutter/material.dart';

import 'backup_utils.dart';

class DialogBackup extends StatefulWidget {
  final bool isCreateBackup;

  const DialogBackup({super.key, required this.isCreateBackup});

  @override
  State<DialogBackup> createState() => _DialogBackupState();
}

class _DialogBackupState extends State<DialogBackup> {
  Future<bool> _createBackup() async {
    return await BackupUtils().backupData();
  }

  Future<bool> _restoreFromBackup() async {
    return await BackupUtils().restoreBackupData();
  }

  Future<void> _executeBackup() async {
    bool? result;

    if (widget.isCreateBackup) {
      await _createBackup();
    } else {
      result = await _restoreFromBackup();
    }

    if (mounted) {
      Navigator.of(context).pop(result);
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
