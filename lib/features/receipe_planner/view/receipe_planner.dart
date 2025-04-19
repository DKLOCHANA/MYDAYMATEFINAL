import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/view/favorites_page.dart';
import 'package:mydaymate/features/receipe_planner/view/ingredient_search_page.dart';
import 'package:mydaymate/widgets/recipe_grid.dart';

class receipe_planner extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plannerr'),
        actions: [
          IconButton(
            icon: Icon(Icons.king_bed),
            onPressed: () => Get.to(() => IngredientSearchPage()),
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Get.to(() => FavoritesPage()),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => showFiltersDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    recipeController.fetchRandomRecipes();
                  },
                ),
              ),
              onSubmitted: (value) {
                recipeController.searchRecipes(value);
              },
            ),
          ),
          Obx(() {
            if (recipeController.selectedDiets.isNotEmpty) {
              return Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('Filters: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recipeController.selectedDiets.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Chip(
                              label:
                                  Text(recipeController.selectedDiets[index]),
                              onDeleted: () {
                                recipeController.toggleDietFilter(
                                    recipeController.selectedDiets[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        recipeController.clearFilters();
                      },
                      child: Text('Clear'),
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox();
            }
          }),
          Expanded(
            child: Obx(() {
              if (recipeController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (recipeController.filteredRecipes.isEmpty) {
                return Center(child: Text('No recipes found'));
              } else {
                return RecipeGrid(recipes: recipeController.filteredRecipes);
              }
            }),
          ),
        ],
      ),
    );
  }

  void showFiltersDialog(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();

    Get.dialog(
      AlertDialog(
        title: Text('Filter by Diet'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: recipeController.availableDiets.length,
            itemBuilder: (context, index) {
              final diet = recipeController.availableDiets[index];
              return Obx(() => CheckboxListTile(
                    title: Text(diet),
                    value: recipeController.selectedDiets.contains(diet),
                    onChanged: (bool? value) {
                      recipeController.toggleDietFilter(diet);
                    },
                  ));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              recipeController.clearFilters();
              Get.back();
            },
            child: Text('Clear All'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// class RecipeGrid extends StatelessWidget {
//   final List<Recipe> recipes;

//   RecipeGrid({required this.recipes});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: EdgeInsets.all(16),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.75,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: recipes.length,
//       itemBuilder: (context, index) {
//         return RecipeCard(recipe: recipes[index]);
//       },
//     );
//   }
// }
