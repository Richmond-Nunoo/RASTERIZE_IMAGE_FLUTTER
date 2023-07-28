import 'dart:io';
import 'package:image/image.dart' as imglib;
import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  final Color fgColor;
  final double tileSize;
  final File? image;

  ImagePainter({
    required this.fgColor,
    required this.tileSize,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final bytes = image!.readAsBytesSync();
    final img = imglib.decodeImage(bytes);

    if (img == null) return;

    final paint = Paint()..color = fgColor;
    // Enable anti-aliasing for smoother rendering
    paint.isAntiAlias = true;

    const targetWidth = 220.0;
    const targetHeight = 243.0;

    final resizedImage = imglib.copyResize(
      img,
      width: targetWidth.toInt(),
      height: targetHeight.toInt(),
    );

    for (var y = 0; y < resizedImage.height; y += tileSize.toInt()) {
      for (var x = 0; x < resizedImage.width; x += tileSize.toInt()) {
        final c = resizedImage.getPixelSafe(x, y);
        final alpha = c.a / 255.0;
        final r = (c.r * alpha).toInt();
        final g = (c.g * alpha).toInt();
        final b = (c.b * alpha).toInt();

        final color = Color.fromARGB(255, r, g, b);

        final factor = alpha < 0.5 ? 2.0 : 1.0;

        final blendedColor =
            Color.alphaBlend(color.withOpacity(alpha * factor), fgColor);

        paint.color = blendedColor.withOpacity(alpha);
        final rect =
            Rect.fromLTWH(x.toDouble(), y.toDouble(), tileSize, tileSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


