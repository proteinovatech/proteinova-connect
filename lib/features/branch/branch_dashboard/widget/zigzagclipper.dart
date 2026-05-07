import 'dart:math' as Math;

import 'package:flutter/material.dart';

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double zigzagSize = 4;
    const int points = 20;

    final radius = size.width / 2;
    final center = Offset(radius, radius);

    for (int i = 0; i <= points; i++) {
      final angle = (i * 2 * 3.1416) / points;
      final r = i % 2 == 0 ? radius : radius - zigzagSize;

      final x = center.dx + r * Math.cos(angle);
      final y = center.dy + r * Math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}