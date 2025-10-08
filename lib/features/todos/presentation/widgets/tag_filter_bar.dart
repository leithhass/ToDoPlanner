import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/filters.dart';

class TagFilterBar extends ConsumerWidget {
  const TagFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(availableTagsProvider);
    final selected = ref.watch(selectedTagProvider);

    if (tags.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tag = i == 0 ? null : tags[i - 1];
          final isSel = selected == tag;
          return ChoiceChip(
            label: Text(i == 0 ? 'Tous' : '#$tag'),
            selected: isSel,
            selectedColor: cs.primaryContainer,
            backgroundColor: cs.surfaceContainerHighest,
            labelStyle: TextStyle(
              color: isSel ? cs.onPrimaryContainer : cs.onSurface,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            ),
            side: isSel ? BorderSide(color: cs.primary) : BorderSide(color: cs.outlineVariant),
            onSelected: (_) => ref.read(selectedTagProvider.notifier).state = tag,
          );
        },
      ),
    );
  }
}
