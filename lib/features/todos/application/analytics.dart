import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/todo.dart';
import 'todos_controller.dart';

class WeeklyStat {
  final DateTime weekStart; 
  final int created;
  final int completed;
  WeeklyStat(this.weekStart, this.created, this.completed);
}

class TagCount { final String tag; final int count; TagCount(this.tag, this.count); }

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final todos = ref.watch(todosProvider);
  return AnalyticsData.fromTodos(todos);
});

class AnalyticsData {
  final List<WeeklyStat> last8Weeks;
  final List<TagCount> topTags;        
  final List<int> priorityDist;        
  final double completionRate;         

  AnalyticsData(this.last8Weeks, this.topTags, this.priorityDist, this.completionRate);

  static AnalyticsData fromTodos(List<Todo> todos) {

    DateTime monday(DateTime d) => d.subtract(Duration(days: (d.weekday + 6) % 7));
    final now = DateTime.now();
    final start = monday(DateTime(now.year, now.month, now.day));
    final weeks = List.generate(8, (i) => start.subtract(Duration(days: 7 * (7 - i))));

    final stats = <WeeklyStat>[];
    for (final w in weeks) {
      final wEnd = w.add(const Duration(days: 7));
      final created = todos.where((t) => t.createdAt.isAfter(w) && t.createdAt.isBefore(wEnd)).length;
      final completed = todos.where((t) => t.done && t.createdAt.isBefore(wEnd)).length;
      stats.add(WeeklyStat(w, created, completed));
    }

    final tagMap = <String, int>{};
    for (final t in todos.where((t) => t.deletedAt == null)) {
      for (final tag in t.tags) {
        tagMap[tag] = (tagMap[tag] ?? 0) + 1;
      }
    }
    final tagCounts = tagMap.entries.map((e) => TagCount(e.key, e.value)).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final top6 = tagCounts.take(6).toList();

    final prio = [0, 0, 0];
    for (final t in todos.where((t) => t.deletedAt == null)) {
      final p = (t.priority < 0 || t.priority > 2) ? 1 : t.priority;
      prio[p]++;
    }

    final active = todos.where((t) => t.deletedAt == null).toList();
    final comp = active.isEmpty ? 0.0 : active.where((t) => t.done).length / active.length;

    return AnalyticsData(stats, top6, prio, comp);
  }
}
