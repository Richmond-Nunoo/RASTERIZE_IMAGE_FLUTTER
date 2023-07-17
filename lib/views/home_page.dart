import 'dart:io';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resterizeimage/widgets/bottom_snackbar.dart';
import 'package:resterizeimage/widgets/image_source.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/picked_image.dart';
import 'package:path/path.dart' as base;

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
      final imagePermanent = await saveImagePermanently(pickedImage.path);
      setState(() => this.pickedImage = imagePermanent);
    } on PlatformException catch (e) {
      print("Failed to Pick an Image $e");
    }
  }

  final Color bgColor = Colors.grey.shade300;

  double tileSize = 0;
  double rasterizeValue = 1;

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
                        onImageRemoved: () {
                          setState(() {
                            pickedImage = null;
                          });
                        },
                      )
                    : GestureDetector(
                        onTap: () async {
                          final source =
                              await ImageSourceHelper.showImageSource(context);

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
            if (pickedImage != null) {
              if (rasterizeValue > 1) {
                setState(() {
                  rasterizeValue--;
                });
              } else {
                UtilsSnack()
                    .showSnackBar("Rasterization Limited to this point");
              }
            } else {
              UtilsSnack().showSnackBar("Invalid Image");
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
            if (pickedImage != null) {
              if (rasterizeValue < 35) {
                setState(() {
                  rasterizeValue++;
                });
              } else {
                UtilsSnack()
                    .showSnackBar("Rasterization Limited to this point");
              }
            } else {
              UtilsSnack().showSnackBar("Invalid Image");
            }
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  SizedBox rasterizedImageMethod() {
    return SizedBox(
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
          : Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    "assets/images/photo.svg",
                    height: 200,
                    width: 200,
                    fit: BoxFit.fitWidth,
                  ),
                  const Text("Select An Image to Rasterize"),
                ],
              ),
            ),
    );
  }

  saveImage(Uint8List image) async {
    await [
      Permission.storage,
    ].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll('.', "_");
    final String name = "Sreenshot_$time";
    final results = await ImageGallerySaver.saveImage(image, name: name);
    return results["filePath"];
  }
}

Future<File> saveImagePermanently(String path) async {
  final directory = await getApplicationDocumentsDirectory();
  final name = base.basename(path);
  final image = File('${directory.path}/$name');
  return File(path).copy(image.path);
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
