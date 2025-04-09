import 'package:flutter/material.dart';

enum ColorMode {
  system,
  red,
  pink,
  purple,
  deepPurple,
  indigo,
  blue,
  cyan,
  teal,
  green,
  yellow,
  orange,
  brown,
  blueGrey,
}

extension ColorModeExtension on ColorMode {
  Color get color {
    switch (this) {
      case ColorMode.system:
        return Colors.blue;
      case ColorMode.red:
        return Colors.red;
      case ColorMode.pink:
        return Colors.pink;
      case ColorMode.purple:
        return Colors.purple;
      case ColorMode.deepPurple:
        return Colors.deepPurple;
      case ColorMode.indigo:
        return Colors.indigo;
      case ColorMode.blue:
        return Colors.blue;
      case ColorMode.cyan:
        return Colors.cyan;
      case ColorMode.teal:
        return Colors.teal;
      case ColorMode.green:
        return Colors.green;
      case ColorMode.yellow:
        return Colors.yellow;
      case ColorMode.orange:
        return Colors.orange;
      case ColorMode.brown:
        return Colors.brown;
      case ColorMode.blueGrey:
        return Colors.blueGrey;
    }
  }
}
