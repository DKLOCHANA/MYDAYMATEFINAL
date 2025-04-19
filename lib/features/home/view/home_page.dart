import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/core/routes/app_routes.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/widgets/home_card.dart';
import '../controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 1 / 3 * MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 36 + 20,
                  ),
                  height: 1 / 3 * MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, Color(0xFFB2FFFB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("MyDayMate",
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            Spacer(),
                            GestureDetector(
                              onTap: () => Get.toNamed('/profile'),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                foregroundImage: AssetImage(
                                    "assets/images/home/profile.png"),
                              ),
                            ),
                          ],
                        ),
                        Obx(
                          () => Text(
                              "Good Morning, ${controller.username.value}!",
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text("Today's Plan",
                            style: Theme.of(context).textTheme.bodyLarge),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: Colors.black),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Assessment",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                Text("Saturday, 10th July 2021",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.chatbot),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/home/bot.png"),
                        SizedBox(width: 20),
                        Text("Need Any Assistance?",
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),

                // Grid of 4 HomeCardContainers
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  children: [
                    // Task Manager Card
                    HomeCardContainer(
                      title: 'Task Manager',
                      subtitle: 'Organize your tasks',
                      backgroundImage: 'assets/images/home/tasks.png',
                      onTap: () => Get.toNamed(AppRoutes.taskList),
                      borderColor: Colors.blue,
                    ),

                    // Meal Planner Card
                    HomeCardContainer(
                      title: 'Meal Planner',
                      subtitle: 'Plan your diet',
                      backgroundImage: 'assets/images/home/f2.png',
                      onTap: () => Get.toNamed(AppRoutes.recipe),
                      borderColor: Colors.green,
                    ),

                    // Finance Tracker Card
                    HomeCardContainer(
                      title: 'Finance Tracker',
                      subtitle: 'Manage expenses',
                      backgroundImage: 'assets/images/home/f1.png',
                      onTap: () => Get.toNamed(AppRoutes.financial),
                      borderColor: Colors.amber,
                    ),

                    // Smart Assistant Card
                    HomeCardContainer(
                      title: 'Grocery Planner',
                      subtitle: 'Get help anytime',
                      backgroundImage: 'assets/images/home/f3.png',
                      onTap: () => Get.toNamed(AppRoutes.grocery),
                      borderColor: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
