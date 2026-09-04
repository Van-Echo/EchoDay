abstract final class AppRoutes {
  static const String calendar = '/';
  static const String dayTodos = '/day/:date';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String about = '/about';

  static String dayTodosFor(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '/day/$year-$month-$day';
  }

  static String dayTodosForLocalDate(Object date) => '/day/$date';
}
