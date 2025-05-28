import 'package:flutter/material.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/utils/devices.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, // Required for Ink to show
        foregroundColor: Colors.white,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.9),
              AppColors.secondary,
              AppColors.secondary.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
        ),
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: DeviceLayout.spacing(14),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: DeviceLayout.fontSize(isSmallScreen ? 14 : 16),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
