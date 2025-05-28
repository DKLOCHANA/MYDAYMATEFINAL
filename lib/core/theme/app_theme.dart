import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/theme/app_text_styles.dart';

import 'package:mydaymate/core/utils/devices.dart';

class AppTheme {
  static ThemeData theme(BuildContext context) {
    return ThemeData(
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge(context),
        headlineMedium: AppTextStyles.headlineMedium(context),
        bodyLarge: AppTextStyles.bodyLarge(context),
        bodyMedium: AppTextStyles.bodyMedium(context),
        bodySmall: AppTextStyles.bodySmall(context),
        titleLarge: AppTextStyles.titleLarge(context),
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.black,
        secondary: AppColors.secondary,
        onSecondary: AppColors.black,
        error: AppColors.error,
        onError: AppColors.black,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.secondary),
          foregroundColor: MaterialStateProperty.all(AppColors.black),
          elevation: MaterialStateProperty.all(0),
          minimumSize: MaterialStateProperty.all(
            Size(
                double.infinity, DeviceLayout.getProportionateScreenHeight(48)),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DeviceLayout.spacing(15)),
            ),
          ),
          textStyle:
              MaterialStateProperty.all(AppTextStyles.titleLarge(context)),
        ),
      ),
    );
  }
}
