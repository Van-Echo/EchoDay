import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../features/backup/application/backup_preferences.dart';
import '../platform/platform_capabilities.dart';
import '../providers/data_providers.dart';

class BackupLifecycleHost extends ConsumerStatefulWidget {
  const BackupLifecycleHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<BackupLifecycleHost> createState() =>
      _BackupLifecycleHostState();
}

class _BackupLifecycleHostState extends ConsumerState<BackupLifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_automaticBackupEnabled) return;
    unawaited(_runAutomaticBackup());
  }

  bool get _automaticBackupEnabled =>
      ref.read(automaticBackupEnabledProvider).value ?? false;

  Future<void> _runAutomaticBackup() async {
    if (!ref.read(platformCapabilitiesProvider).isWindows) return;
    try {
      await ref
          .read(backupMaintenanceServiceProvider)
          .createAutomaticBackupIfDue();
    } on Object catch (error, stackTrace) {
      AppLogger.error('Automatic backup failed', error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(automaticBackupEnabledProvider, (previous, next) {
      if (next.value != true || previous?.value == true) return;
      unawaited(_runAutomaticBackup());
    });
    return widget.child;
  }
}
