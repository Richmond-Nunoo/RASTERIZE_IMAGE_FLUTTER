import 'dart:io';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
    final bytes = await rootBundle.load('assets/images/man.jpg');
    final Uint8List imageBytes = bytes.buffer.asUint8List();
    final img = imglib.decodeImage(imageBytes);
    final resizedImage = imglib.copyResize(img!, width: 220, height: 220);

    setState(() {
      image = resizedImage;
    });
  }

  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "1",
            onPressed: () {
              if (rasterizeValue > 1) {
                setState(() {
                  rasterizeValue--;
                });
              } else {
                print("You Cant go below 1");
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
              if (rasterizeValue < 35) {
                setState(() {
                  rasterizeValue++;
                });
              } else {
                print("Thats Enough");
              }
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
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    print("Pick An Image");
                  },
                  child: Container(
                    height: 150,
                    width: 150,
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
                rasterizedImageMethod(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final image = await screenshotController
                            .captureFromWidget(rasterizedImageMethod());
                        await saveImage(image);
                      },
                      icon: const Icon(
                        CupertinoIcons.cloud_download,
                      ),
                      label: const Text(
                        "Save",
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final image = await screenshotController
                            .captureFromWidget(rasterizedImageMethod());
                        saveAndShare(image);
                      },
                      label: const Text(
                        "share",
                      ),
                      icon: const Icon(
                        CupertinoIcons.share,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container rasterizedImageMethod() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      child: SizedBox(
        height: 220,
        width: 220,
        child: CustomPaint(
          painter: ImagePainter(
            fgColor: bgColor,
            tileSize: rasterizeValue,
            image: image,
          ),
        ),
      ),
    );
  }

  saveImage(Uint8List image) async {
    await [Permission.storage].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll('.', "_");
    final String name = "Sreenshot_$time";
    final results = await ImageGallerySaver.saveImage(image, name: name);
    return results["filePath"];
  }
}

void saveAndShare(Uint8List bytes) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final image = File("${directory.path}/screenshot.jpg");
    await image.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(image.path)]);
  } catch (e) {
    print(e.toString());
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
