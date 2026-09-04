import 'local_date.dart';
import 'todo_item.dart';

enum CompletionFilter { all, incomplete, completed }

final class TodoSearchQuery {
  const TodoSearchQuery({
    this.text = '',
    this.completion = CompletionFilter.all,
    this.fromDate,
    this.toDate,
    this.categoryId,
    this.tagIds = const {},
    this.offset = 0,
    this.limit = 50,
  });

  final String text;
  final CompletionFilter completion;
  final LocalDate? fromDate;
  final LocalDate? toDate;
  final String? categoryId;
  final Set<String> tagIds;
  final int offset;
  final int limit;
}

final class SearchPage<T> {
  const SearchPage({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}

typedef TodoSearchPage = SearchPage<TodoItem>;
