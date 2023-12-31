import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resterizeimage/widgets/image_source.dart';

class ImageWidget extends StatefulWidget {
  final File image;
  final ValueChanged<ImageSource> onClicked;
  final VoidCallback onImageRemoved;
  const ImageWidget({
    super.key,
    required this.image,
    required this.onClicked,
    required this.onImageRemoved,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
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
        final source = await ImageSourceHelper.showImageSource(context);
        if (source == null) return;
        widget.onClicked(source);
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.loose,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.28,
            width: MediaQuery.of(context).size.width * 0.50,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: InkWell(
              onTap: () async {
                widget.onImageRemoved();
                print("Removed Images");
              },
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: const Icon(
                  CupertinoIcons.delete,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
