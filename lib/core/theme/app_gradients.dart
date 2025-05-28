import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.primaryVariant,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      AppColors.secondary,
      AppColors.secondaryVariant,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
