import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';

import 'recipe_controller.dart';

class FavoritesController extends GetxController {
  var favorites = <Recipe>[].obs;

  bool isRecipeFavorite(int recipeId) {
    return favorites.any((recipe) => recipe.id == recipeId);
  }

  void toggleFavorite(Recipe recipe) {
    if (isRecipeFavorite(recipe.id)) {
      favorites.removeWhere((favRecipe) => favRecipe.id == recipe.id);
      recipe.isFavorite = false;
    } else {
      recipe.isFavorite = true;
      favorites.add(recipe);
    }
    update();

    // Also update in the recipes list
    final recipeController = Get.find<RecipeController>();
    for (var r in recipeController.recipes) {
      if (r.id == recipe.id) {
        r.isFavorite = recipe.isFavorite;
      }
    }
    recipeController.update();
  }
}
