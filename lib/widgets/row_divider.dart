import 'package:flutter/material.dart';

Row rowDivider() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        height: 1,
        width: 100,
        color: Colors.black,
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Text("Rasterize Image"),
      ),
      Container(
        height: 1,
        width: 100,
        color: Colors.black,
      ),
    ],
  );
}
