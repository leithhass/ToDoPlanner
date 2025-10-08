class Todo {
  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  final DateTime? dueDate;      
  final int priority;           
  final List<String> tags;      
  final DateTime? deletedAt;    

  Todo({
    required this.id,
    required this.title,
    this.done = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = 1,
    this.tags = const [],
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? title,
    bool? done,
    DateTime? createdAt,
    DateTime? dueDate,
    int? priority,
    List<String>? tags,
    DateTime? deletedAt,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority,
        'tags': tags,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  static Todo fromMap(Map m) => Todo(
        id: m['id'] as String,
        title: m['title'] as String,
        done: (m['done'] ?? false) as bool,
        createdAt: DateTime.parse(m['createdAt'] as String),
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null,
        priority: (m['priority'] ?? 1) as int,
        tags: (m['tags'] as List?)?.cast<String>() ?? const [],
        deletedAt: m['deletedAt'] != null ? DateTime.parse(m['deletedAt'] as String) : null,
      );
}
