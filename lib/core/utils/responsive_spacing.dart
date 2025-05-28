import 'package:flutter/material.dart';
import 'package:mydaymate/core/utils/devices.dart';

class Spacing {
  static EdgeInsets all(double value) =>
      EdgeInsets.all(DeviceLayout.spacing(value));

  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: DeviceLayout.spacing(horizontal),
        vertical: DeviceLayout.spacing(vertical),
      );

  static EdgeInsets only({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left: DeviceLayout.spacing(left),
        right: DeviceLayout.spacing(right),
        top: DeviceLayout.spacing(top),
        bottom: DeviceLayout.spacing(bottom),
      );
}
