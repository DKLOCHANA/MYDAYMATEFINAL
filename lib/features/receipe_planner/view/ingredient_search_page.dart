import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/widgets/recipe_grid.dart';

class IngredientSearchPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cook with Ingredients'),
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
                    hintText: 'Add ingredients you have...',
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
              return SizedBox();
            }
            return Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 16),
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
                  child: Text('Add ingredients and search for recipes'),
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
}
