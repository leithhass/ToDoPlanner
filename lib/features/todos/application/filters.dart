import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/todo.dart';
import 'todos_controller.dart';

final queryProvider = StateProvider<String>((_) => '');
final selectedTagProvider = StateProvider<String?>((_) => null);
final showCompletedProvider = StateProvider<bool>((_) => true);
final showTrashProvider = StateProvider<bool>((_) => false);
final selectionProvider = StateProvider<Set<String>>((_) => <String>{});

final availableTagsProvider = Provider<List<String>>((ref) {
  final todos = ref.watch(todosProvider);
  final set = <String>{};
  for (final t in todos.where((e) => e.deletedAt == null)) {
    set.addAll(t.tags);
  }
  final l = set.toList()..sort();
  return l;
});

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final all = ref.watch(todosProvider);
  final q = ref.watch(queryProvider).trim().toLowerCase();
  final tag = ref.watch(selectedTagProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final showTrash = ref.watch(showTrashProvider);

  Iterable<Todo> list = all;
  if (!showTrash) list = list.where((t) => t.deletedAt == null);
  if (!showCompleted) list = list.where((t) => !t.done);
  if (tag != null) list = list.where((t) => t.tags.contains(tag));
  if (q.isNotEmpty) list = list.where((t) => t.title.toLowerCase().contains(q));
  return list.toList();
});
//fonctionnels