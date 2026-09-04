import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/data_providers.dart';
import '../router/app_routes.dart';

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
    final localizations = AppLocalizations.of(context);
    final destinations = [
      _Destination(
        label: localizations.navCalendar,
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        location: AppRoutes.calendar,
      ),
      _Destination(
        label: localizations.navDayTodos,
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist_rounded,
        location: AppRoutes.dayTodosFor(DateTime.now()),
      ),
      _Destination(
        label: localizations.navSearch,
        icon: Icons.search_outlined,
        selectedIcon: Icons.search_rounded,
        location: AppRoutes.search,
      ),
      _Destination(
        label: localizations.navSettings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        location: AppRoutes.settings,
      ),
      _Destination(
        label: localizations.navAbout,
        icon: Icons.info_outline_rounded,
        selectedIcon: Icons.info_rounded,
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
      context.go(destinations[index].location);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
        final savedExtended = ref.watch(navigationRailExtendedProvider).value;
        final railExtended = savedExtended ?? constraints.maxWidth >= 1160;
        final content = ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: body,
        );

        return Scaffold(
          floatingActionButton: floatingActionButton,
          appBar: AppBar(
            title: Row(
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          body: useRail
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      extended: railExtended,
                      minExtendedWidth: extendedRailWidth,
                      onDestinationSelected: navigate,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
                      trailing: Expanded(
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
                                    ? Icons.keyboard_double_arrow_left_rounded
                                    : Icons.keyboard_double_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: navigate,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: destination.label,
                      ),
                  ],
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
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}
