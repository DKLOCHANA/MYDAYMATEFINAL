import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/grocery/controller/grocery_controller.dart';
import 'package:mydaymate/widgets/recipe_grid.dart';

class IngredientSearchPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();

    // Ensure grocery controller is initialized
    if (!Get.isRegistered<GroceryController>()) {
      Get.put(GroceryController());
    }
    final GroceryController groceryController = Get.find<GroceryController>();

    // Auto-populate ingredients from grocery list when page loads
    _populateIngredientsFromGrocery(recipeController, groceryController);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cook with Ingredients'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh from grocery list',
            onPressed: () => _refreshIngredientsFromGrocery(
                recipeController, groceryController),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Add more ingredients...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    recipeController.getIngredientSuggestions(value);
                  },
                ),
                Obx(() {
                  if (recipeController.suggestedIngredients.isEmpty) {
                    return SizedBox();
                  }
                  return Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: recipeController.suggestedIngredients.length,
                      itemBuilder: (context, index) {
                        final ingredient =
                            recipeController.suggestedIngredients[index];
                        return ListTile(
                          title: Text(ingredient),
                          onTap: () {
                            recipeController.addIngredient(ingredient);
                            searchController.clear();
                          },
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            if (recipeController.availableIngredients.isEmpty) {
              return _buildNoIngredientsMessage();
            }
            return Container(
              height: 60,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients you have:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recipeController.availableIngredients.length,
                      itemBuilder: (context, index) {
                        final ingredient =
                            recipeController.availableIngredients[index];
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(ingredient),
                            onDeleted: () =>
                                recipeController.removeIngredient(ingredient),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => recipeController.searchByIngredients(),
              child: Text('Find Recipes'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (recipeController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (recipeController.recipes.isEmpty) {
                return Center(
                  child: Text('No recipes found with your ingredients'),
                );
              } else {
                return RecipeGrid(recipes: recipeController.recipes);
              }
            }),
          ),
        ],
      ),
    );
  }

  // Method to populate ingredients from grocery list on page load
  void _populateIngredientsFromGrocery(
      RecipeController recipeController, GroceryController groceryController) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only auto-populate if ingredients list is empty
      if (recipeController.availableIngredients.isEmpty) {
        // Get grocery items that are not marked for restocking
        final availableItems = groceryController.items
            .where((item) => !item.needsRestock)
            .toList();

        // Clear existing ingredients and add from grocery
        recipeController.availableIngredients.clear();

        // Add each ingredient
        for (var item in availableItems) {
          recipeController.availableIngredients.add(item.name.toLowerCase());
        }

        // Add some common staple ingredients most kitchens have
        final commonStaples = ['salt', 'pepper', 'oil', 'water'];
        for (var staple in commonStaples) {
          if (!recipeController.availableIngredients.contains(staple)) {
            recipeController.availableIngredients.add(staple);
          }
        }

        // Automatically search for recipes if ingredients were found
        if (recipeController.availableIngredients.isNotEmpty) {
          recipeController.searchByIngredients();
        }
      }
    });
  }

  // Method to refresh ingredients from grocery list
  void _refreshIngredientsFromGrocery(
      RecipeController recipeController, GroceryController groceryController) {
    // Get grocery items that are not marked for restocking
    final availableItems =
        groceryController.items.where((item) => !item.needsRestock).toList();

    // Clear existing ingredients and add from grocery
    recipeController.availableIngredients.clear();

    // Add each ingredient
    for (var item in availableItems) {
      recipeController.availableIngredients.add(item.name.toLowerCase());
    }

    // Add some common staple ingredients most kitchens have
    final commonStaples = ['salt', 'pepper', 'oil', 'water'];
    for (var staple in commonStaples) {
      if (!recipeController.availableIngredients.contains(staple)) {
        recipeController.availableIngredients.add(staple);
      }
    }

    // Update UI
    Get.snackbar('Ingredients Refreshed',
        'Found ${recipeController.availableIngredients.length} ingredients',
        snackPosition: SnackPosition.BOTTOM);

    // Search for recipes with updated ingredients
    recipeController.searchByIngredients();
  }

  Widget _buildNoIngredientsMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No ingredients found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add ingredients you have or add items to your grocery list.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
