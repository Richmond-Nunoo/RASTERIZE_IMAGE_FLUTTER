import 'package:flutter/material.dart';

class UtilsSnack {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  showSuccessSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.green,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}