import '../domain/todo.dart';

class TodoGroup {
  final String label;
  final List<Todo> items;
  const TodoGroup(this.label, this.items);
}

List<TodoGroup> groupByStatus(List<Todo> list) {
  final overdue = <Todo>[], today = <Todo>[], upcoming = <Todo>[],
        nodate = <Todo>[], done = <Todo>[], trash = <Todo>[];

  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  for (final t in list) {
    if (t.deletedAt != null) { trash.add(t); continue; }
    if (t.done) { done.add(t); continue; }
    if (t.dueDate == null) { nodate.add(t); continue; }
    final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
    if (d.isBefore(todayDate)) overdue.add(t);
    else if (d == todayDate)   today.add(t);
    else                       upcoming.add(t);
  }

  final groups = <TodoGroup>[];
  if (overdue.isNotEmpty) groups.add(TodoGroup('En retard', overdue));
  if (today.isNotEmpty)   groups.add(TodoGroup('Aujourd’hui', today));
  if (upcoming.isNotEmpty)groups.add(TodoGroup('À venir', upcoming));
  if (nodate.isNotEmpty)  groups.add(TodoGroup('Sans date', nodate));
  if (done.isNotEmpty)    groups.add(TodoGroup('Terminées', done));
  if (trash.isNotEmpty)   groups.add(TodoGroup('Corbeille', trash));
  return groups;
}
