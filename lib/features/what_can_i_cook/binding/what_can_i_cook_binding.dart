import 'package:get/get.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/what_can_i_cook/controller/what_can_i_cook_controller.dart';

class WhatCanICookBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure we have all required controllers
    if (!Get.isRegistered<GroceryController>()) {
      Get.put(GroceryController());
    }
    if (!Get.isRegistered<RecipeController>()) {
      Get.put(RecipeController());
    }
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController());
    }

    // Register the What Can I Cook controller
    Get.put(WhatCanICookController());
  }
}
