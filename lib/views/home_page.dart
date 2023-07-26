import 'dart:io';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resterizeimage/widgets/bottom_snackbar.dart';
import 'package:resterizeimage/widgets/image_painter.dart';
import 'package:resterizeimage/widgets/image_source.dart';
import 'package:resterizeimage/widgets/row_divider.dart';
import 'package:screenshot/screenshot.dart';
import '../widgets/picked_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? pickedImage;
  ImageSourceHelper imagePickerHelper = ImageSourceHelper();

  final Color bgColor = Colors.grey.shade100;
  double rasterizeValue = 1;

  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: actionButtons(),
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Rasterize Image"),
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
                pickedImage != null
                    ? ImageWidget(
                        onClicked: (ImageSource value) => _pickImage(value),
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
                          _pickImage(source);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.20,
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: DottedDecoration(
                              shape: Shape.box,
                              dash: const [10, 10],
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.add_circled,
                                  size: 40,
                                ),
                                Text(
                                  "Pick An Image",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                )
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
                  height: 5,
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
            await imagePickerHelper.saveImage(image);
            UtilsSnack().showSnackBar("Image saved to your gallery ");
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
            imagePickerHelper.saveAndShare(image);
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
                    height: MediaQuery.of(context).size.height * 0.29,
                    width: MediaQuery.of(context).size.width * 0.45,
                    fit: BoxFit.fitWidth,
                  ),
                  const Text("No Image "),
                ],
              ),
            ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImageSourceHelper.pickImage(source);
    if (image != null) {
      setState(() {
        pickedImage = image;
      });
    }
  }
}
