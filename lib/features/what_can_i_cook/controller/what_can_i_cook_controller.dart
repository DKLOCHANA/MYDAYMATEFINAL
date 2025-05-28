import 'package:get/get.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/features/grocery/model/grocery_item.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe_detail.dart';

class WhatCanICookController extends GetxController {
  final GroceryController _groceryController = Get.find<GroceryController>();
  final RecipeController _recipeController = Get.find<RecipeController>();

  final RxBool isLoading = false.obs;
  final RxList<Recipe> matchingRecipes = <Recipe>[].obs;
  final RxList<String> availableIngredients = <String>[].obs;
  final RxInt matchThreshold = 3.obs;

  // Track recipe details to better display missing ingredients
  final RxMap<int, RecipeDetail?> recipeDetails = <int, RecipeDetail?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    extractAvailableIngredients();
    findMatchingRecipes();
  }

  // Extract ingredients from grocery items
  void extractAvailableIngredients() {
    List<String> ingredients = [];

    // Get items that are in stock (not needing restock)
    final inStockItems =
        _groceryController.items.where((item) => !item.needsRestock).toList();

    if (inStockItems.isEmpty) {
      Get.snackbar(
        'No ingredients found',
        'Add some items to your grocery list and mark them as in stock',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Process each available grocery item
    for (var item in inStockItems) {
      // Add the item name as an ingredient
      ingredients.add(item.name.toLowerCase());
    }

    // Remove duplicates and update the list
    availableIngredients.value = ingredients.toSet().toList();

    // Send to recipe controller for searching
    _recipeController.availableIngredients.clear();
    _recipeController.availableIngredients.addAll(availableIngredients);
  }

  // Find recipes that match available ingredients
  Future<void> findMatchingRecipes() async {
    isLoading.value = true;

    try {
      if (availableIngredients.isEmpty) {
        matchingRecipes.clear();
        isLoading.value = false;
        return;
      }

      // Search for recipes using ingredients
      await _recipeController.searchByIngredients();

      // Get the matching recipes
      matchingRecipes.value = _recipeController.recipes;

      // Pre-fetch recipe details for better ingredient matching
      for (var recipe in matchingRecipes.take(10)) {
        await _fetchRecipeDetails(recipe.id);
      }

      // Show feedback to user
      if (matchingRecipes.isEmpty) {
        Get.snackbar(
          'No matching recipes',
          'Try adding more ingredients to your grocery list',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Found recipes',
          'Found ${matchingRecipes.length} recipes you can cook with your ingredients',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error finding matching recipes: $e');
      Get.snackbar(
        'Error',
        'An error occurred while searching for recipes',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch recipe details for better ingredient matching
  Future<RecipeDetail?> _fetchRecipeDetails(int recipeId) async {
    try {
      // If we already have this detail cached
      if (recipeDetails.containsKey(recipeId) &&
          recipeDetails[recipeId] != null) {
        return recipeDetails[recipeId];
      }

      await _recipeController.getRecipeDetail(recipeId);
      final detail = _recipeController.recipeDetail.value;

      if (detail != null && detail.id == recipeId) {
        recipeDetails[recipeId] = detail;
        return detail;
      }

      return null;
    } catch (e) {
      print('Error fetching recipe details for $recipeId: $e');
      return null;
    }
  }

  // Refresh ingredients from grocery list
  void refreshIngredients() {
    extractAvailableIngredients();
    findMatchingRecipes();
  }

  // Get missing ingredients for a recipe with exact matching
  Future<List<String>> getMissingIngredients(Recipe recipe) async {
    List<String> missingIngredients = [];

    // Get or fetch recipe detail for accurate ingredient list
    RecipeDetail? detail = await _fetchRecipeDetails(recipe.id);

    if (detail == null || detail.ingredients.isEmpty) {
      // Fallback to basic matching using dishTypes and title words
      List<String> possibleIngredients = [...recipe.dishTypes];

      // Add words from title that might be ingredients
      final commonNonIngredients = [
        'and',
        'with',
        'the',
        'in',
        'on',
        'for',
        'a',
        'of'
      ];
      final titleWords = recipe.title
          .toLowerCase()
          .split(' ')
          .where(
              (word) => !commonNonIngredients.contains(word) && word.length > 2)
          .toList();
      possibleIngredients.addAll(titleWords);

      // Check which ingredients are missing
      for (var ingredient in possibleIngredients) {
        bool found = false;
        for (var available in availableIngredients) {
          if (ingredient.toLowerCase().contains(available.toLowerCase()) ||
              available.toLowerCase().contains(ingredient.toLowerCase())) {
            found = true;
            break;
          }
        }
        if (!found) {
          missingIngredients.add(ingredient);
        }
      }
    } else {
      // Use detailed ingredients for accurate matching
      for (var ingredientMap in detail.ingredients) {
        final ingredientName = ingredientMap['name'] as String;
        bool found = false;

        for (var available in availableIngredients) {
          if (ingredientName.toLowerCase().contains(available.toLowerCase()) ||
              available.toLowerCase().contains(ingredientName.toLowerCase())) {
            found = true;
            break;
          }
        }

        if (!found) {
          final amount = ingredientMap['amount'] as double?;
          final unit = ingredientMap['unit'] as String?;

          String formattedIngredient = ingredientName;
          if (amount != null && unit != null && unit.isNotEmpty) {
            formattedIngredient =
                '${amount.toStringAsFixed(1)} $unit $ingredientName';
          }

          missingIngredients.add(formattedIngredient);
        }
      }
    }

    return missingIngredients;
  }

  // Add missing ingredients to grocery list
  Future<void> addMissingIngredientsToGroceryList(Recipe recipe) async {
    try {
      // Get missing ingredients with improved matching
      final missingIngredients = await getMissingIngredients(recipe);

      if (missingIngredients.isEmpty) {
        Get.snackbar(
          'No missing ingredients',
          'You have all ingredients for ${recipe.title}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Add missing ingredients to grocery list
      for (var ingredientStr in missingIngredients) {
        // Extract name only from formatted string if needed
        String name = ingredientStr;
        double quantity = 1.0;
        String unit = "item";

        // Try to parse quantities if provided in format "1.0 unit name"
        final parts = ingredientStr.split(' ');
        if (parts.length >= 3) {
          try {
            quantity = double.parse(parts[0]);
            unit = parts[1];
            name = parts.sublist(2).join(' ');
          } catch (e) {
            // If parsing fails, use the whole string as the name
            name = ingredientStr;
          }
        }

        _groceryController.addItem(
          name: name,
          category: 'Other',
          quantity: quantity,
          unit: unit,
          needsRestock: true,
        );
      }

      // Show success message
      Get.snackbar(
        'Added to grocery list',
        'Added ${missingIngredients.length} ingredients for ${recipe.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error adding missing ingredients: $e');
      Get.snackbar(
        'Error',
        'Could not add ingredients to grocery list',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Calculate percentage of ingredients available for a recipe
  Future<double> getIngredientsMatchPercentage(Recipe recipe) async {
    try {
      RecipeDetail? detail = await _fetchRecipeDetails(recipe.id);

      if (detail == null || detail.ingredients.isEmpty) {
        return 0.0; // Cannot determine match percentage
      }

      int totalIngredients = detail.ingredients.length;
      int matchedIngredients = 0;

      for (var ingredientMap in detail.ingredients) {
        final ingredientName = ingredientMap['name'] as String;

        for (var available in availableIngredients) {
          if (ingredientName.toLowerCase().contains(available.toLowerCase()) ||
              available.toLowerCase().contains(ingredientName.toLowerCase())) {
            matchedIngredients++;
            break;
          }
        }
      }

      if (totalIngredients == 0) return 0.0;
      return (matchedIngredients / totalIngredients) * 100;
    } catch (e) {
      return 0.0;
    }
  }
}
