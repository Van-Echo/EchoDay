import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sync/application/sync_client_controller.dart';
import '../platform/platform_capabilities.dart';

class SyncClientLifecycleHost extends ConsumerStatefulWidget {
  const SyncClientLifecycleHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SyncClientLifecycleHost> createState() =>
      _SyncClientLifecycleHostState();
}

class _SyncClientLifecycleHostState
    extends ConsumerState<SyncClientLifecycleHost>
    with WidgetsBindingObserver {
  late final bool _isAndroid;
  bool _resumedAfterBackground = false;

  @override
  void initState() {
    super.initState();
    _isAndroid = ref.read(platformCapabilitiesProvider).isAndroid;
    if (!_isAndroid) return;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(syncClientControllerProvider.notifier).initialize());
      }
    });
  }

  @override
  void dispose() {
    if (_isAndroid) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isAndroid) return;
    if (state != AppLifecycleState.resumed) {
      _resumedAfterBackground = true;
      return;
    }
    if (!_resumedAfterBackground) return;
    _resumedAfterBackground = false;
    unawaited(ref.read(syncClientControllerProvider.notifier).synchronize());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
