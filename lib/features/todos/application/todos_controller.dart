import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/todo_box.dart';
import '../domain/todo.dart';
import '../../../services/notification_service.dart';

class TodosNotifier extends Notifier<List<Todo>> {
  bool includeDeleted = false;

  @override
  List<Todo> build() => TodoBox.all(includeDeleted: includeDeleted);

  Future<void> refresh() async {
    state = TodoBox.all(includeDeleted: includeDeleted);
  }

  NotificationService get _notifs => ref.read(notificationServiceProvider);

  Future<void> add(Todo t) async {
    await TodoBox.put(t);
    await _notifs.scheduleFor(t);
    await refresh();
  }

  Future<void> toggle(String id) async {
    final before = state.firstWhere((e) => e.id == id);
    await TodoBox.toggle(id);
    await refresh();
    final after = state.firstWhere((e) => e.id == id, orElse: () => before);
    if (after.done) await _notifs.cancelFor(after);
  }

  Future<void> trash(String id) async {
    final t = state.firstWhere((e) => e.id == id);
    await _notifs.cancelFor(t);
    await TodoBox.trash(id);
    await refresh();
  }

  Future<void> restore(String id) async {
    await TodoBox.restore(id);
    await refresh();
    final t = state.firstWhere((e) => e.id == id);
    await _notifs.scheduleFor(t);
  }

  Future<void> bulkToggle(Iterable<String> ids, bool done) async {
    await TodoBox.bulkToggleDone(ids, done);
    await refresh();
    if (done) {
      for (final id in ids) {
        final t = state.firstWhere((e) => e.id == id, orElse: () => Todo(id: id, title: ''));
        await _notifs.cancelFor(t);
      }
    }
  }

  Future<void> bulkTrash(Iterable<String> ids) async {
    for (final id in ids) {
      final t = state.firstWhere((e) => e.id == id, orElse: () => Todo(id: id, title: ''));
      await _notifs.cancelFor(t);
    }
    await TodoBox.bulkTrash(ids);
    await refresh();
  }

  void setIncludeDeleted(bool v) {
    includeDeleted = v;
    refresh();
  }
}

final todosProvider = NotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);
