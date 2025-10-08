import 'package:flutter/material.dart';
import '../design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12), // espace entre cartes
    this.onTap,
    this.accent, // couleur d’accent (ex: selon priorité)
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final GestureTapCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final a = accent ?? cs.outlineVariant;

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // teinté via theme.dart
        borderRadius: const BorderRadius.all(Tkn.rXl),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              blurRadius: 24,
              spreadRadius: -6,
              offset: const Offset(0, 10),
              color: a.withOpacity(.12), // ombre teintée par l’accent
            ),
        ],
        border: Border.all(color: a.withOpacity(.55)), // contour léger teinté
      ),
      padding: padding,
      child: child,
    );

    return onTap != null
        ? InkWell(
            borderRadius: const BorderRadius.all(Tkn.rXl),
            onTap: onTap,
            child: card,
          )
        : card;
  }
}
