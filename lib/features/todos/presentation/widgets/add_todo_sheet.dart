// lib/features/todos/presentation/widgets/add_todo_sheet.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:todolocal/features/todos/domain/todo.dart';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key, required this.suggestedTags});
  final List<String> suggestedTags;

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final c = TextEditingController();
  final tagCtrl = TextEditingController();
  int priority = 1;
  DateTime? dueDate;

  @override
  void dispose() { c.dispose(); tagCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 44, height: 5,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 16),
          Text('Nouvelle tâche', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(controller: c, decoration: const InputDecoration(hintText: 'Ex: Réviser chapitre 3'), autofocus: true,
            onSubmitted: (_) => _submit()),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Priorité'), const SizedBox(width: 12),
          DropdownButton<int>(
  value: priority,
  borderRadius: BorderRadius.circular(14), // 
  items: const [
    DropdownMenuItem(value: 0, child: Text('Low')),
    DropdownMenuItem(value: 1, child: Text('Med')),
    DropdownMenuItem(value: 2, child: Text('High')),
  ],
  onChanged: (v) => setState(() => priority = v ?? 1),
),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 5),
                  initialDate: now,
                );
                if (picked != null) setState(() => dueDate = picked);
              },
              icon: const Icon(Icons.event_rounded),
              label: Text(
                dueDate == null ? 'Échéance'
                                 : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
              ),
            )
          ]),
          const SizedBox(height: 8),
          TextField(controller: tagCtrl, decoration: const InputDecoration(hintText: 'Tags (séparés par des virgules)')),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.add_rounded), label: const Text('Ajouter')),
        ]),
      ),
    );
  }

  void _submit() {
    final txt = c.text.trim();
    if (txt.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString();
    final tags = tagCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    Navigator.of(context).pop(Todo(id: id, title: txt, priority: priority, dueDate: dueDate, tags: tags));
  }
}
