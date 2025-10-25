import 'package:flutter/material.dart';

class ColorHelpers {
  static String colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2, 8).toUpperCase();
  }

  static Color colorFromHex(String hexString) {
    return Color(int.parse(hexString, radix: 16) + 0xFF000000);
  }
}