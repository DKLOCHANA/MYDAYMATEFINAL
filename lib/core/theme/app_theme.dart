import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        titleLarge: AppTextStyles.titleLarge,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.black,
          secondary: AppColors.secondary,
          onSecondary: AppColors.black,
          error: AppColors.error,
          onError: AppColors.black,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.black,
        elevation: 0,
        minimumSize:
            const Size(double.infinity, 48), // Full width with height of 48
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        textStyle: AppTextStyles.titleLarge,
      )),
    );
  }
}
