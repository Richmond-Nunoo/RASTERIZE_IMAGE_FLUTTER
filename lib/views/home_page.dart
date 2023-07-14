import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color bgColor = Colors.grey.shade200;
  imglib.Image? image;

  double tileSize = 0;
  double rasterizeValue = 15.0;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final bytes = await rootBundle.load('assets/images/woman.jpg');
    final Uint8List imageBytes = bytes.buffer.asUint8List();
    final img = imglib.decodeImage(imageBytes);
    final resizedImage = imglib.copyResize(img!, width: 220, height: 220);

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
            heroTag: "1",
            onPressed: () {
              if (rasterizeValue > 5) {
                setState(() {
                  rasterizeValue--;
                });
              } else {
                print("You Cant go below 5");
              }
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "2",
            onPressed: () {
              setState(() {
                rasterizeValue++;
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Restaurize Image"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    print("Pick An Image");
                  },
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: DottedDecoration(
                        shape: Shape.box,
                        dash: const [10, 10],
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.add_circled,
                            size: 50,
                          ),
                          Text("Pick An Image")
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: 100,
                      color: Colors.grey.shade300,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("Ratarized Image"),
                    ),
                    Container(
                      height: 1,
                      width: 100,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 220,
                  width: 220,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      var width = constraints.maxWidth;
                      var height = constraints.maxHeight;
                      var ratio = height / width;
                      var tilesX = rasterizeValue;
                      var tilesY = ratio * tilesX;
                      tileSize = width / tilesY;
                      return CustomPaint(
                        painter: ImagePainter(
                          fgColor: bgColor,
                          tileSize: tileSize,
                          image: image,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {},
                  child: const Text(
                    "Download",
                
                  ),
                )
              ],
            ),
          ),
        ],
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
