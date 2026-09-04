import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../router/app_routes.dart';

class AppScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
        icon: Icons.tune_outlined,
        selectedIcon: Icons.tune_rounded,
        location: AppRoutes.settings,
      ),
      _Destination(
        label: localizations.navAbout,
        icon: Icons.info_outline_rounded,
        selectedIcon: Icons.info_rounded,
        location: AppRoutes.about,
      ),
    ];

    void navigate(int index) {
      context.go(destinations[index].location);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 840;
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
                      extended: constraints.maxWidth >= 1160,
                      onDestinationSelected: navigate,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
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
