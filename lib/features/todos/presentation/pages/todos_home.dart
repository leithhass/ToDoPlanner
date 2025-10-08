import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todolocal/features/todos/domain/todo.dart';

import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/empty_state.dart';

import '../../application/filters.dart';
import '../../application/grouping.dart';
import '../../application/todos_controller.dart';

import '../widgets/add_todo_sheet.dart';
import '../widgets/tag_filter_bar.dart';
import '../widgets/todo_tile.dart';
import 'insights_page.dart';

import '../../../../infrastructure/export_service.dart';

class TodosHome extends ConsumerWidget {
  const TodosHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered      = ref.watch(filteredTodosProvider);
    final groups        = groupByStatus(filtered);
    final selection     = ref.watch(selectionProvider);
    final inSelection   = selection.isNotEmpty;
    final showCompleted = ref.watch(showCompletedProvider);
    final showTrash     = ref.watch(showTrashProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(inSelection ? '${selection.length} sélectionnée(s)' : 'Mes tâches'),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: const SizedBox.expand(),
          ),
        ),
        actions: [
          if (inSelection) ...[
            IconButton(
              tooltip: 'Marquer terminé',
              onPressed: () async {
                await ref.read(todosProvider.notifier).bulkToggle(selection, true);
                ref.read(selectionProvider.notifier).state = {};
              },
              icon: const Icon(Icons.check_circle_rounded),
            ),
            IconButton(
              tooltip: 'Corbeille',
              onPressed: () async {
                final ids = {...selection};
                await ref.read(todosProvider.notifier).bulkTrash(ids);
                ref.read(selectionProvider.notifier).state = {};
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tâches envoyées à la corbeille'),
                      action: SnackBarAction(
                        label: 'Annuler',
                        onPressed: () async {
                          for (final id in ids) {
                            await ref.read(todosProvider.notifier).restore(id);
                          }
                        },
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_rounded),
            ),
          ] else ...[
            IconButton(
              tooltip: showCompleted ? 'Masquer terminées' : 'Afficher terminées',
              onPressed: () =>
                  ref.read(showCompletedProvider.notifier).state = !showCompleted,
              icon: Icon(
                showCompleted ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              ),
            ),
            IconButton(
              tooltip: showTrash ? 'Masquer corbeille' : 'Afficher corbeille',
              onPressed: () {
                final v = !showTrash;
                ref.read(showTrashProvider.notifier).state = v;
                ref.read(todosProvider.notifier).setIncludeDeleted(v);
              },
              icon: Icon(
                showTrash ? Icons.delete_sweep_rounded : Icons.delete_outline_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Insights',
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsightsPage())),
              icon: const Icon(Icons.insights_rounded),
            ),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (v) async {
                switch (v) {
                  case 'export':
                    final file = await ExportService.exportToJson();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exporté: ${file.path.split('/').last}')),
                      );
                    }
                    break;
                  case 'import':
                    final n = await ExportService.importFromJson(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Import: $n élément(s)')),
                      );
                    }
                    await ref.read(todosProvider.notifier).refresh();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'export', child: Text('Exporter JSON')),
                PopupMenuItem(value: 'import', child: Text('Importer JSON')),
              ],
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ],
      ),

      floatingActionButton: inSelection
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final created = await showModalBottomSheet<Todo>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Tkn.rXl),
                  ),
                  builder: (_) => AddTodoSheet(
                    suggestedTags: ref.read(availableTagsProvider),
                  ),
                );
                if (created != null) {
                  await ref.read(todosProvider.notifier).add(created);
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter'),
            ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(Tkn.s6, Tkn.s3, Tkn.s6, Tkn.s6),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => ref.read(queryProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Rechercher une tâche…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: Tkn.s3),

            const TagFilterBar(),
            const SizedBox(height: Tkn.s4),

            if (filtered.isEmpty)
              const Expanded(
                child: EmptyState(
                  title: 'Rien à afficher',
                  message: 'Ajoute ta première tâche avec “Ajouter”.',
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (_, i) {
                    final g = groups[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                          child: Text(
                            g.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        ...g.items.map((t) => TodoTile(todo: t)),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
