import 'package:flutter/material.dart';
import 'design_tokens.dart';

ThemeData buildTheme(Brightness brightness) {
  final cs = ColorScheme.fromSeed(seedColor: Tkn.seed, brightness: brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,

    // Fond légèrement teinté pour casser le gris
    scaffoldBackgroundColor: Tkn.tintedSurface(cs, .045),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: cs.onSurface,
      ),
      iconTheme: IconThemeData(color: cs.onSurfaceVariant),
    ),

    // Cartes "panel" douces et un peu teintées
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Color.alphaBlend(cs.primary.withOpacity(.03), cs.surfaceContainer),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Tkn.rXl),
      ),
    ),

    // Champs (recherche, formulaires)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Tkn.rMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Tkn.rMd),
        borderSide: BorderSide(color: cs.primary.withOpacity(.35), width: 1.2),
      ),
    ),

    // Chips plus visibles (fallback global)
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide(color: cs.outlineVariant),
      labelStyle: TextStyle(color: cs.onSurface),
      backgroundColor: cs.surfaceContainerHighest,
    ),

    // FAB bien visible (CTA)
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 0,
      shape: const StadiumBorder(),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
  );
}
