import 'dart:io';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/pick_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? pickedImage;

  Future pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final imageTemp = File(pickedImage.path);
      setState(() => this.pickedImage = imageTemp);
    } on PlatformException catch (e) {
      print("Failed to Pick an Image $e");
    }
  }

  final Color bgColor = Colors.grey.shade200;

  double tileSize = 0;
  double rasterizeValue = 15.0;

  @override
  void initState() {
    super.initState();
  }

  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: actionButtons(),
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
                pickedImage != null
                    ? ImageWidget(
                        onClicked: (ImageSource value) => pickImage(value),
                        image: pickedImage!,
                      )
                    : GestureDetector(
                        onTap: () async {
                          final source = await showImageSource(context);

                          if (source == null) return;
                          pickImage(source);
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
                rowDivider(),
                const SizedBox(
                  height: 10,
                ),
                rasterizedImageMethod(),
                const SizedBox(
                  height: 20,
                ),
                shareButtons()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row shareButtons() {
    return Row(
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
        ),
      ],
    );
  }

  Row rowDivider() {
    return Row(
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
    );
  }

  Row actionButtons() {
    return Row(
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
        child: pickedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: ImagePainter(
                    fgColor: bgColor,
                    tileSize: rasterizeValue,
                    image: pickedImage,
                  ),
                ),
              )
            : const Center(
                child: Text("Error"),
              ),
      ),
    );
  }

  Future<ImageSource?> showImageSource(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text("Camera"),
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: const Text("Gallery"),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            )
          ],
        ),
      );
    } else if (Platform.isAndroid) {
      return showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              )
            ],
          ),
        ),
      );
    }
    return null;
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

    //final aspectRatio = img.width / img.height;
    const targetWidth = 220.0;
    const targetHeight = 220.0;

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
