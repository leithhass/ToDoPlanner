import 'package:flutter/material.dart';

/// Design tokens (couleurs, rayons, espacements, ombres)
class Tkn {
  /// Couleur de marque (tu peux changer la seed)
  static const seed = Color(0xFF5B86E5);

  /// Rayons très arrondis
  static const rSm = Radius.circular(12);
  static const rMd = Radius.circular(20);
  static const rXl = Radius.circular(28);

  /// Spacing (grille de 8)
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;

  /// Ombre douce
  static const softShadow = [
    BoxShadow(
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 10),
      color: Color(0x14000000), // 8% black
    ),
  ];

  /// Teinte la surface par la couleur de marque (léger voile)
  static Color tintedSurface(ColorScheme cs, [double opacity = .04]) {
    return Color.alphaBlend(cs.primary.withOpacity(opacity), cs.surface);
  }
}
