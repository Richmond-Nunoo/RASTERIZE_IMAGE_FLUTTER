import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as base;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
//import 'package:path_provider/path_provider.dart';

class ImageSourceHelper {
  // pick an image platform specific
  static Future<ImageSource?> showImageSource(BuildContext context) async {
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
            ),
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
              ),
            ],
          ),
        ),
      );
    }
    return null;
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
  // File? _pickedImage;

  // File? get userpickImage => _pickedImage;

  // set pickedImage(File? image) {
  //   _pickedImage = image;
  // }

  // Future<void> pickImage(ImageSource source) async {
  //   try {
  //     final XFile? pickedImage = await ImagePicker().pickImage(source: source);
  //     if (pickedImage == null) return;
  //     final imagePermanent = await saveImagePermanently(pickedImage.path);
  //     _pickedImage = imagePermanent;
  //   } on PlatformException catch (e) {
  //     print("Failed to Pick an Image $e");
  //   }
  // }

  // Future<File> saveImagePermanently(String path) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final name = base.basename(path);
  //   final image = File('${directory.path}/$name');
  //   return File(path).copy(image.path);
  // }
}
