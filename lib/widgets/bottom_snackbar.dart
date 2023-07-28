import 'package:flutter/material.dart';

class UtilsSnack {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(
      content: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
