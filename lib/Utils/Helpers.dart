import 'package:flutter/material.dart';

// Helper class for color conversions
class ColorHelpers {
  /// Converts a Color object to a hex string (e.g., "FF0000" for red).
  static String colorToHex(Color color) {
    // Returns a hex string in RRGGBB format
    return color.value.toRadixString(16).substring(2, 8).toUpperCase();
  }

  /// Converts a hex string (RRGGBB) to a Color object.
  static Color colorFromHex(String hex) {
    // Assumes full opacity (FF) and parses RRGGBB
    return Color(int.parse(hex, radix: 16) + 0xFF000000);
  }
}