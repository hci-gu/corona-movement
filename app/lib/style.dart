import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static Color main = Colors.yellow[700];
  static Color secondary = Colors.blueGrey[600];

  static Color secondaryText = Colors.grey[600];

  static LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Colors.blueGrey[900],
      Colors.blueGrey[800],
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}
