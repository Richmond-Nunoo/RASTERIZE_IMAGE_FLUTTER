import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//  final Color fgColor = Colors.black;

  final Color bgColor = Colors.grey.shade200;

  imglib.Image? image;

  double tileSize = 0;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final bytes = await rootBundle.load('assets/images/woman.jpg');
    final Uint8List imageBytes = bytes.buffer.asUint8List();
    final img = imglib.decodeImage(imageBytes);
    final resizedImage = imglib.copyResize(img!, width: 300, height: 300);

    setState(() {
      image = resizedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.remove),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ],
      ),
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Restaurize Image"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final ratio = height / width;
                  const tilesX = 30;
                  final tilesY = ratio * tilesX;
                  tileSize = width / tilesY;
                  return GestureDetector(
                    onPanUpdate: (details) {
                      print(width);
                    },
                    child: CustomPaint(
                      painter: ImagePainter(
                        fgColor: bgColor,
                        tileSize: tileSize,
                        image: image,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {},
              child: const Text("Download"),
            )
          ],
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final Color fgColor;
  final double tileSize;
  final imglib.Image? image;

  ImagePainter(
      {required this.fgColor, required this.tileSize, required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final paint = Paint()..color = fgColor;

    for (var y = 0; y < image!.height; y += tileSize.toInt()) {
      for (var x = 0; x < image!.width; x += tileSize.toInt()) {
        final c = image!.getPixelSafe(x, y);
        //final alpha = Random().nextDouble();
        final alpha = c.a / 255.0;
        final r = (c.r * alpha);
        final g = (c.g * alpha);
        final b = (c.b * alpha);

        final color = Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt());

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
