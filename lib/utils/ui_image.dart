import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class UIImage extends StatelessWidget {
  final ui.Image image;

  const UIImage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _UIImagePainter(image));
  }
}

class _UIImagePainter extends CustomPainter {
  final ui.Image image;

  _UIImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(_UIImagePainter oldDelegate) {
    return image != oldDelegate.image;
  }
}
