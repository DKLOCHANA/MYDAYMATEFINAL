// import 'package:flutter/material.dart';
// import 'package:mydaymate/core/theme/app_colors.dart';
// import 'package:mydaymate/core/theme/app_fonts.dart';

// class AppTextStyles {
//   static final TextStyle headlineLarge = TextStyle(
//     fontFamily: AppFonts.fontFamily,
//     fontSize: 36,
//     fontWeight: FontWeight.w500,
//     color:
//         AppColors.primary, // Replace with the correct color or import statement
//   );

//   static final TextStyle headlineMedium = TextStyle(
//     fontFamily: AppFonts.fontFamily,
//     fontSize: 24,
//     fontWeight: FontWeight.w500,
//     color: AppColors.primary,
//   );

//   static final TextStyle titleLarge = TextStyle(
//     fontFamily: AppFonts.fontFamily,
//     fontSize: 18,
//     fontWeight: FontWeight.w500,
//   );

//   static final TextStyle bodyLarge = TextStyle(
//     fontFamily: AppFonts.fontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//   );

//   static final TextStyle bodyMedium = TextStyle(
//     fontFamily: AppFonts.fontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//   );

//   static final TextStyle bodySmall = TextStyle(
//     fontFamily: AppFonts.fontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//   );
// }

import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/theme/app_fonts.dart';
import 'package:mydaymate/core/utils/devices.dart';

class AppTextStyles {
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontFamily: AppFonts.fontFamily,
        fontSize: DeviceLayout.fontSize(36),
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontFamily: AppFonts.fontFamily,
        fontSize: DeviceLayout.fontSize(24),
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontFamily: AppFonts.fontFamily,
        fontSize: DeviceLayout.fontSize(18),
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontFamily: AppFonts.fontFamily,
        fontSize: DeviceLayout.fontSize(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontFamily: AppFonts.fontFamily,
        fontSize: DeviceLayout.fontSize(14),
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontFamily: AppFonts.fontFamily,
        fontSize: DeviceLayout.fontSize(12),
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}
