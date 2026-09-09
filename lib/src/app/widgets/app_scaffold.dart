import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../features/sync/application/sync_client_controller.dart';
import '../../features/sync/application/sync_host_controller.dart';
import '../../features/sync/presentation/sync_status_badge.dart';
import '../../features/sync/server/secure_sync_host_service.dart';
import '../layout/adaptive_window.dart';
import '../platform/platform_capabilities.dart';
import '../providers/data_providers.dart';
import '../router/app_routes.dart';
import 'app_lifecycle_refresh_host.dart';

abstract final class AppScaffoldSettingKeys {
  static const navigationRailExtended = 'shell.navigationRailExtended';
}

final navigationRailExtendedProvider = StreamProvider<bool?>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(AppScaffoldSettingKeys.navigationRailExtended)
      .map((setting) => setting == null ? null : setting.value == 'true');
});

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    required this.selectedIndex,
    required this.title,
    required this.body,
    this.floatingActionButton,
    super.key,
  });

  final int selectedIndex;
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appRefreshRevisionProvider);
    final localizations = AppLocalizations.of(context);
    final hostSync = ref.watch(syncHostControllerProvider);
    final clientSync = ref.watch(syncClientControllerProvider);
    final showingClientStatus = hostSync.mode == SyncOperatingMode.client;
    final syncIssueCount = showingClientStatus
        ? clientSync.conflicts.length
        : hostSync.conflicts.length +
              hostSync.devices.where((device) => device.requiresUpgrade).length;
    final syncWarning = showingClientStatus
        ? clientSync.needsAttention
        : hostSync.mode == SyncOperatingMode.host &&
              (hostSync.lifecycle == SyncHostLifecycle.failed ||
                  hostSync.messageCode != null);
    Widget settingsIcon(IconData icon) => SyncStatusBadge(
      icon: icon,
      semanticLabel: localizations.syncAttentionSemantics,
      issueCount: syncIssueCount,
      hasWarning: syncWarning,
    );
    final destinations = [
      _Destination(
        label: localizations.navCalendar,
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month_rounded),
        location: AppRoutes.calendar,
      ),
      _Destination(
        label: localizations.navDayTodos,
        icon: const Icon(Icons.checklist_outlined),
        selectedIcon: const Icon(Icons.checklist_rounded),
        location: AppRoutes.dayTodosFor(DateTime.now()),
      ),
      _Destination(
        label: localizations.navSearch,
        icon: const Icon(Icons.search_outlined),
        selectedIcon: const Icon(Icons.search_rounded),
        location: AppRoutes.search,
      ),
      _Destination(
        label: localizations.navSettings,
        icon: settingsIcon(Icons.settings_outlined),
        selectedIcon: settingsIcon(Icons.settings_rounded),
        location: AppRoutes.settings,
      ),
      _Destination(
        label: localizations.navAbout,
        icon: const Icon(Icons.info_outline_rounded),
        selectedIcon: const Icon(Icons.info_rounded),
        location: AppRoutes.about,
      ),
    ];
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final widestLabel = destinations
        .map(
          (destination) => (TextPainter(
            text: TextSpan(text: destination.label, style: labelStyle),
            textDirection: Directionality.of(context),
          )..layout()).width,
        )
        .reduce((left, right) => left > right ? left : right);
    final extendedRailWidth = (widestLabel + 96).clamp(144.0, 196.0);

    void navigate(int index) {
      if (index == selectedIndex) return;
      if (index == 0) {
        context.go(destinations[index].location);
      } else {
        context.push(destinations[index].location);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = AdaptiveWindow.classify(constraints.maxWidth);
        final useRail = !windowClass.isCompact;
        final canExtendRail =
            constraints.maxWidth >= AdaptiveWindow.extendedNavigationBreakpoint;
        final savedExtended = ref.watch(navigationRailExtendedProvider).value;
        final railExtended = canExtendRail && (savedExtended ?? canExtendRail);
        final isAndroid = ref.watch(platformCapabilitiesProvider).isAndroid;
        final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
        final content = AdaptiveWindowScope(
          windowClass: windowClass,
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: body,
          ),
        );
        final shellBody = useRail
            ? Row(
                children: [
                  NavigationRail(
                    key: ValueKey(
                      windowClass.isMedium
                          ? 'medium-navigation-rail'
                          : 'expanded-navigation-rail',
                    ),
                    selectedIndex: selectedIndex,
                    extended: railExtended,
                    minExtendedWidth: extendedRailWidth,
                    onDestinationSelected: navigate,
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: destination.icon,
                          selectedIcon: destination.selectedIcon,
                          label: Text(destination.label),
                        ),
                    ],
                    trailing: canExtendRail
                        ? Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: IconButton(
                                  key: const ValueKey(
                                    'navigation-rail-width-toggle',
                                  ),
                                  tooltip: railExtended
                                      ? localizations.collapseNavigation
                                      : localizations.expandNavigation,
                                  onPressed: () async {
                                    await ref
                                        .read(settingsRepositoryProvider)
                                        .set(
                                          AppScaffoldSettingKeys
                                              .navigationRailExtended,
                                          '${!railExtended}',
                                        );
                                  },
                                  icon: Icon(
                                    railExtended
                                        ? Icons
                                              .keyboard_double_arrow_left_rounded
                                        : Icons
                                              .keyboard_double_arrow_right_rounded,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(child: content),
                ],
              )
            : content;
        final protectedBody = isAndroid
            ? SafeArea(top: false, child: shellBody)
            : shellBody;
        final canPop = GoRouter.maybeOf(context)?.canPop() ?? false;

        return PopScope(
          canPop: selectedIndex == 0 || canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectedIndex != 0) context.go(AppRoutes.calendar);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            floatingActionButton: keyboardVisible ? null : floatingActionButton,
            appBar: isAndroid && selectedIndex == 0
                ? null
                : AppBar(
                    title: windowClass.isCompact
                        ? Text(title, overflow: TextOverflow.ellipsis)
                        : Row(
                            children: [
                              Text(localizations.appTitle),
                              const SizedBox(width: 8),
                              Text(
                                localizations.appSubtitle,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 24),
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                            ],
                          ),
                  ),
            body: protectedBody,
            bottomNavigationBar: useRail || keyboardVisible
                ? null
                : SafeArea(
                    top: false,
                    child: NavigationBar(
                      key: const ValueKey('compact-bottom-navigation'),
                      selectedIndex: selectedIndex,
                      onDestinationSelected: navigate,
                      destinations: [
                        for (final destination in destinations)
                          NavigationDestination(
                            icon: destination.icon,
                            selectedIcon: destination.selectedIcon,
                            label: destination.label,
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final String location;
}
