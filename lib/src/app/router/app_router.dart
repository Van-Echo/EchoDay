import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/presentation/about_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/day_todos/presentation/day_todos_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../widgets/not_found_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.calendar,
    routes: [
      GoRoute(
        path: AppRoutes.calendar,
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(
        path: AppRoutes.dayTodos,
        builder: (context, state) => DayTodosPage(
          date: state.pathParameters['date'] ?? '',
          openTodoId: state.uri.queryParameters['todo'],
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
