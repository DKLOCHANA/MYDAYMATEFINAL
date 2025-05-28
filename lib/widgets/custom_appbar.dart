import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/devices.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showProfileImage;
  static const String profileImage = 'assets/images/home/profile.png';

  const CustomAppbar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showProfileImage = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    // Calculate responsive values
    final double iconSize = isSmallScreen ? 22 : 24;
    final double avatarRadius =
        screenSize.width * 0.05; // 5% of screen width, max 24
    final double rightPadding = screenSize.width * 0.04; // 4% of screen width

    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: iconSize,
                color: AppColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      centerTitle: true,
      titleSpacing: DeviceLayout.spacing(isSmallScreen ? 0 : 8),
      title: Text(
        title,
        style: isSmallScreen
            ? Theme.of(context).textTheme.titleLarge
            : Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: screenSize.width * 0.05, // Responsive font size
                ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (showProfileImage)
          Padding(
            padding: EdgeInsets.only(right: rightPadding),
            child: GestureDetector(
              onTap: () => Get.toNamed('/profile'),
              child: Hero(
                tag: 'profileImage',
                child: FutureBuilder<String?>(
                  future: _getProfileImagePath(),
                  builder: (context, snapshot) {
                    return CircleAvatar(
                      radius: avatarRadius > 24 ? 24 : avatarRadius,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage:
                          snapshot.hasData && snapshot.data!.isNotEmpty
                              ? FileImage(File(snapshot.data!))
                              : const AssetImage(profileImage) as ImageProvider,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize {
    // Responsive height based on screen size
    return Size.fromHeight(DeviceLayout.getProportionateScreenHeight(56));
  }

  // Simple method to get profile image path
  Future<String?> _getProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('profile_image_path');

      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        return savedImagePath;
      }
    } catch (e) {
      // Ignore errors and return null
    }
    return null;
  }
}
