import 'package:flutter/material.dart';

class Tkn {
  static const seed = Color(0xFF5B86E5);

  static const rSm = Radius.circular(12);
  static const rMd = Radius.circular(20);
  static const rXl = Radius.circular(28);

  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;

  static const softShadow = [
    BoxShadow(
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 10),
      color: Color(0x14000000), 
    ),
  ];

  static Color tintedSurface(ColorScheme cs, [double opacity = .04]) {
    return Color.alphaBlend(cs.primary.withOpacity(opacity), cs.surface);
  }
}
