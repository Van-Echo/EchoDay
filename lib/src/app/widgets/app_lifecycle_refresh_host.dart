import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/todos/application/todo_providers.dart';

final appRefreshRevisionProvider = NotifierProvider<AppRefreshRevision, int>(
  AppRefreshRevision.new,
);

final class AppRefreshRevision extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

class AppLifecycleRefreshHost extends ConsumerStatefulWidget {
  const AppLifecycleRefreshHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleRefreshHost> createState() =>
      _AppLifecycleRefreshHostState();
}

class _AppLifecycleRefreshHostState
    extends ConsumerState<AppLifecycleRefreshHost>
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
    if (state != AppLifecycleState.resumed) return;
    ref.read(appRefreshRevisionProvider.notifier).refresh();
    ref.invalidate(currentTimeProvider);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
