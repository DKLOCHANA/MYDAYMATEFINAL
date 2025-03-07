import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/routes/app_pages.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/core/theme/app_theme.dart';
import 'package:mydaymate/core/utils/devices.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyDayMate',
      theme: AppTheme.theme,
      initialRoute: AppRoutes.financial,
      getPages: AppPages.pages,
      builder: (context, child) {
        DeviceLayout.init(context);
        return child!;
      },
    );
  }
}
