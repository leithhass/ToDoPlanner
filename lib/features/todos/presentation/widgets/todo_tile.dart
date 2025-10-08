import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/design_tokens.dart';
import '../../application/filters.dart';
import '../../application/todos_controller.dart';
import '../../domain/todo.dart';

class TodoTile extends ConsumerWidget {
  const TodoTile({super.key, required this.todo});
  final Todo todo;

  String _dueLabel(DateTime? d) {
    if (d == null) return 'Aucune date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tday = DateTime(d.year, d.month, d.day);
    if (tday.isBefore(today)) return 'En retard';
    if (tday == today) return 'Aujourd’hui';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectionProvider).contains(todo.id);
    final cs = Theme.of(context).colorScheme;

    // Couleurs priorité (badges + accent carte)
    late final Color prioBg, prioFg, accent;
    switch (todo.priority) {
      case 2:
        prioBg = cs.errorContainer;     prioFg = cs.onErrorContainer;     accent = cs.error;     // High
        break;
      case 0:
        prioBg = cs.secondaryContainer; prioFg = cs.onSecondaryContainer; accent = cs.secondary; // Low
        break;
      default:
        prioBg = cs.primaryContainer;   prioFg = cs.onPrimaryContainer;   accent = cs.primary;   // Med
    }

    final dueText = _dueLabel(todo.dueDate);
    final dueBg = (todo.dueDate != null && dueText == 'En retard')
        ? cs.errorContainer
        : cs.surfaceContainerHighest;
    final dueFg = (todo.dueDate != null && dueText == 'En retard')
        ? cs.onErrorContainer
        : cs.onSurface;

    return _AccentCard(
      accent: accent, // <- plus besoin d'AppCard.accent, on gère ici
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () async {
        final sel = ref.read(selectionProvider);
        if (sel.isNotEmpty) {
          final s = {...sel};
          s.contains(todo.id) ? s.remove(todo.id) : s.add(todo.id);
          ref.read(selectionProvider.notifier).state = s;
        } else {
          await ref.read(todosProvider.notifier).toggle(todo.id); // cocher/décocher
        }
      },
      child: ListTile(
        onLongPress: () {
          final s = {...ref.read(selectionProvider)};
          s.contains(todo.id) ? s.remove(todo.id) : s.add(todo.id);
          ref.read(selectionProvider.notifier).state = s;
        },
        selected: selected,
        selectedTileColor: cs.primary.withOpacity(.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

        // Leading cliquable pour marquer terminé
        leading: IconButton(
          tooltip: todo.done ? 'Marquer non terminé' : 'Marquer terminé',
          onPressed: () async => ref.read(todosProvider.notifier).toggle(todo.id),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: todo.done
                ? const Icon(Icons.check_circle_rounded, key: ValueKey('d'))
                : const Icon(Icons.radio_button_unchecked_rounded, key: ValueKey('u')),
          ),
        ),

        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            // Badge priorité (rempli)
            Chip(
              label: Text(['Low', 'Med', 'High'][todo.priority]),
              backgroundColor: prioBg,
              labelStyle: TextStyle(color: prioFg, fontWeight: FontWeight.w600),
              visualDensity: VisualDensity.compact,
            ),
            // Échéance
            Chip(
              label: Text(dueText),
              backgroundColor: dueBg,
              labelStyle: TextStyle(color: dueFg),
              visualDensity: VisualDensity.compact,
            ),
            // Tags
            ...todo.tags.take(3).map(
              (t) => Chip(
                label: Text('#$t'),
                backgroundColor: cs.surfaceContainerHighest,
                labelStyle: TextStyle(color: cs.onSurface),
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (todo.tags.length > 3)
              Chip(
                label: Text('+${todo.tags.length - 3}'),
                backgroundColor: cs.surfaceContainerHighest,
                visualDensity: VisualDensity.compact,
              ),
            if (todo.deletedAt != null)
              Chip(
                label: const Text('Corbeille'),
                backgroundColor: cs.surfaceContainerHighest,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),

        // Menu action — coins arrondis
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (v) async {
            final ctrl = ref.read(todosProvider.notifier);
            switch (v) {
              case 'prio_low':  await ctrl.add(todo.copyWith(priority: 0)); break;
              case 'prio_med':  await ctrl.add(todo.copyWith(priority: 1)); break;
              case 'prio_high': await ctrl.add(todo.copyWith(priority: 2)); break;
              case 'trash':     await ctrl.trash(todo.id); break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'prio_low',  child: Text('Priorité: Low')),
            PopupMenuItem(value: 'prio_med',  child: Text('Priorité: Med')),
            PopupMenuItem(value: 'prio_high', child: Text('Priorité: High')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'trash',     child: Text('Envoyer à la corbeille')),
          ],
        ),
      ),
    );
  }
}

/// Carte avec contour/ombre teintés par la couleur d'accent.
/// Implémentée ici pour éviter toute dépendance à un paramètre `accent` externe.
class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.onTap,
  });

  final Widget child;
  final Color accent;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Tkn.rXl),
        boxShadow: [
          if (isLight)
            BoxShadow(
              blurRadius: 24,
              spreadRadius: -6,
              offset: const Offset(0, 10),
              color: accent.withOpacity(.12),
            ),
        ],
        border: Border.all(color: accent.withOpacity(.55)),
      ),
      padding: padding,
      child: child,
    );

    // Ripple
    return Material(
      type: MaterialType.transparency,
      child: onTap != null
          ? InkWell(
              borderRadius: const BorderRadius.all(Tkn.rXl),
              onTap: onTap,
              child: card,
            )
          : card,
    );
  }
}
