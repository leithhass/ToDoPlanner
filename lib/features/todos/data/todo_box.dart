import 'package:hive_flutter/hive_flutter.dart';
import '../domain/todo.dart';

class TodoBox {
  static const boxName = 'todos_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(boxName);
  }

  static Box<Map> get _box => Hive.box<Map>(boxName);

  static List<Todo> all({bool includeDeleted = false}) {
    final list = _box.values
        .map((m) => Todo.fromMap(Map<String, dynamic>.from(m)))
        .where((t) => includeDeleted ? true : t.deletedAt == null)
        .toList();

    list.sort((a, b) {
      int rank(Todo t) {
        if (t.done) return 5; 
        if (t.deletedAt != null) return 6; 
        final now = DateTime.now();
        if (t.dueDate == null) return 4; 
        final today = DateTime(now.year, now.month, now.day);
        final tday = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
        if (tday.isBefore(today)) return 0; 
        if (tday == today) return 1; 
        return 2; 
      }

      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;

      final p = b.priority.compareTo(a.priority); 
      if (p != 0) return p;

      final da = a.dueDate ?? DateTime(9999);
      final db = b.dueDate ?? DateTime(9999);
      return da.compareTo(db);
    });

    return list;
  }

  static Future<void> put(Todo t) => _box.put(t.id, t.toMap());

  static Future<void> toggle(String id) async {
    final m = Map<String, dynamic>.from(_box.get(id)!);
    m['done'] = !(m['done'] as bool);
    await _box.put(id, m);
  }

  static Future<void> trash(String id) async {
    final m = Map<String, dynamic>.from(_box.get(id)!);
    m['deletedAt'] = DateTime.now().toIso8601String();
    await _box.put(id, m);
  }

  static Future<void> restore(String id) async {
    final m = Map<String, dynamic>.from(_box.get(id)!);
    m['deletedAt'] = null;
    await _box.put(id, m);
  }

  static Future<void> purge(String id) => _box.delete(id);

  static Future<void> bulkToggleDone(Iterable<String> ids, bool done) async {
    for (final id in ids) {
      final m = Map<String, dynamic>.from(_box.get(id)!);
      m['done'] = done;
      await _box.put(id, m);
    }
  }

  static Future<void> bulkTrash(Iterable<String> ids) async {
    for (final id in ids) {
      final m = Map<String, dynamic>.from(_box.get(id)!);
      m['deletedAt'] = DateTime.now().toIso8601String();
      await _box.put(id, m);
    }
  }
}
