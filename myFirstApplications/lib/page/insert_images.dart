import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Widget insertImages(width, height) {
  AssetImage assetImage = const AssetImage("images/tiana.jpg");
  Image image = Image(image: assetImage, width: width, height: height);
  return SizedBox(height: height, width: width, child: image);
}

Widget insertAvatar(radius) {
  return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage("assets/images/user.png"));
}
