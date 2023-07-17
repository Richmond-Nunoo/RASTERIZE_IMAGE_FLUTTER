import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageWidget extends StatefulWidget {
  final File image;
  final ValueChanged<ImageSource> onClicked;
  const ImageWidget({super.key, required this.image, required this.onClicked});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
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

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return buildImage(context);
  }

  Widget buildImage(BuildContext context) {
    final imagePath = widget.image.path;
    final image = FileImage(File(imagePath));
    return InkWell(
      onTap: () async {
        final source = await showImageSource(context);
        if (source == null) return;
        widget.onClicked(source);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: InkWell(
              onTap: () {
                print("Remove the Image");
              },
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: IconButton(
                  onPressed: () {
                    print("Remove the Image");
                  },
                  icon: const Icon(
                    CupertinoIcons.delete,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
