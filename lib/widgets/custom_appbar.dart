import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/devices.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  static const String profileImage = 'assets/images/home/profile.png';

  const CustomAppbar({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.primary,
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      centerTitle: true,
      title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: DeviceLayout.spacing(16)),
          child: GestureDetector(
            onTap: () {}, //Get.toNamed(AppRoutes.profile),
            child: CircleAvatar(
              radius: DeviceLayout.spacing(20),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: const AssetImage(profileImage),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(DeviceLayout.getProportionateScreenHeight(56));
}
