import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';

class ReceipeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RecipeController());
    Get.put(FavoritesController());
  }
}
