// import 'package:flutter/material.dart';

// class DeviceLayout {
//   static MediaQueryData? _mediaQueryData;
//   static double get screenWidth => _mediaQueryData?.size.width ?? 375;
//   static double get screenHeight => _mediaQueryData?.size.height ?? 812;
//   static Orientation get orientation =>
//       _mediaQueryData?.orientation ?? Orientation.portrait;

//   static void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);
//   }

//   // Get the proportionate height as per screen size
//   static double getProportionateScreenHeight(double inputHeight) {
//     return (inputHeight / 812.0) * screenHeight;
//   }

//   // Get the proportionate width as per screen size
//   static double getProportionateScreenWidth(double inputWidth) {
//     return (inputWidth / 375.0) * screenWidth;
//   }

//   // Safe vertical padding
//   static double safeVerticalPadding(BuildContext context) {
//     return MediaQuery.of(context).padding.top +
//         MediaQuery.of(context).padding.bottom;
//   }

//   // Responsive font sizes
//   static double fontSize(double size) {
//     return getProportionateScreenWidth(size);
//   }

//   // Responsive spacing
//   static double spacing(double size) {
//     return getProportionateScreenWidth(size);
//   }

//   // Check device type
//   static bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 650;

//   static bool isTablet(BuildContext context) =>
//       MediaQuery.of(context).size.width < 1100 &&
//       MediaQuery.of(context).size.width >= 650;

//   static bool isDesktop(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 1100;
// }

import 'package:flutter/material.dart';

class DeviceLayout {
  static MediaQueryData? _mediaQueryData;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }

  static double get screenWidth => _mediaQueryData?.size.width ?? 375;
  static double get screenHeight => _mediaQueryData?.size.height ?? 812;
  static Orientation get orientation =>
      _mediaQueryData?.orientation ?? Orientation.portrait;

  static double getProportionateScreenHeight(double inputHeight) {
    return (inputHeight / 812.0) * screenHeight;
  }

  static double getProportionateScreenWidth(double inputWidth) {
    return (inputWidth / 375.0) * screenWidth;
  }

  static double fontSize(double size) {
    // Dynamic scaling using screen width
    return getProportionateScreenWidth(size);
  }

  static double spacing(double size) {
    return getProportionateScreenWidth(size);
  }

  static double safeTopPadding(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeBottomPadding(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
}
