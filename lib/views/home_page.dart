import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color fgColor = Colors.black;

  final Color bgColor = Colors.grey.shade200;

  imglib.Image? image;

  double tileSize = 0;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final bytes = await rootBundle.load('assets/images/man.jpg');
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
                  const width = 300;
                  const height = 300;
                  const ratio = height / width;
                  const tilesX = 30;
                  const tilesY = ratio * tilesX;
                  tileSize = width / tilesX;
                  return GestureDetector(
                    onPanUpdate: (details) {},
                    child: CustomPaint(
                      painter: ImagePainter(
                        fgColor: Colors.white,
                        tileSize: tileSize,
                        image: image,
                      ),
                    ),
                  );
                },
              ),
            ),
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
        final r = c.r;
        final g = c.g;
        final b = c.b;
        final color = Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt());
        paint.color = color;
        final rect =
            Rect.fromLTWH(x.toDouble(), y.toDouble(), tileSize, tileSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
