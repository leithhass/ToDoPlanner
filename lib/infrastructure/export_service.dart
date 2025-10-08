import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../features/todos/data/todo_box.dart';
import '../features/todos/domain/todo.dart';

class ExportService {
  static Future<File> exportToJson() async {
    final list = TodoBox.all(includeDeleted: true).map((e) => e.toMap()).toList();
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now();
    final name =
        'todos_${ts.year}${ts.month.toString().padLeft(2, '0')}${ts.day.toString().padLeft(2, '0')}_${ts.hour.toString().padLeft(2, '0')}${ts.minute.toString().padLeft(2, '0')}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(list));
    return file;
  }


  static Future<int> importFromJson(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        return _importParseAndSave(content);
      }

      final pasted = await _promptPasteJson(context);
      if (pasted == null) return 0;
      return _importParseAndSave(pasted);
    } catch (e) {
      final pasted = await _promptPasteJson(context, error: e.toString());
      if (pasted == null) return 0;
      return _importParseAndSave(pasted);
    }
  }

  static int _safeInt(dynamic x) {
    if (x is int) return x;
    if (x is num) return x.toInt();
    if (x is String) return int.tryParse(x) ?? 0;
    return 0;
  }

  static Future<int> _importParseAndSave(String content) async {
    final data = jsonDecode(content);
    if (data is! List) return 0;

    var imported = 0;
    for (final m in data) {
      try {
        final map = Map<String, dynamic>.from(m as Map);
        if (map['priority'] != null) map['priority'] = _safeInt(map['priority']);
        final t = Todo.fromMap(map);
        await TodoBox.put(t);
        imported++;
      } catch (_) {
      }
    }
    return imported;
  }

  static Future<String?> _promptPasteJson(BuildContext context, {String? error}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importer depuis JSON (coller)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Sélecteur de fichiers indisponible.\n$Error',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
                ),
              const Text('Colle ici le contenu JSON exporté (liste de tâches).'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: '[ {...}, {...} ]',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Importer')),
        ],
      ),
    );
  }
}
