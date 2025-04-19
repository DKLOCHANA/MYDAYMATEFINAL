import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    final FavoritesController favoritesController =
        Get.find<FavoritesController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
        actions: [
          Obx(() {
            if (recipeController.recipeDetail.value == null) return SizedBox();
            return IconButton(
              icon: Icon(
                recipeController.recipeDetail.value!.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: recipeController.recipeDetail.value!.isFavorite
                    ? Colors.red
                    : null,
              ),
              onPressed: () {
                final recipe = Recipe(
                  id: recipeController.recipeDetail.value!.id,
                  title: recipeController.recipeDetail.value!.title,
                  image: recipeController.recipeDetail.value!.image,
                  readyInMinutes:
                      recipeController.recipeDetail.value!.readyInMinutes,
                  servings: recipeController.recipeDetail.value!.servings,
                  dishTypes: recipeController.recipeDetail.value!.dishTypes,
                  diets: recipeController.recipeDetail.value!.diets,
                  isFavorite: recipeController.recipeDetail.value!.isFavorite,
                );
                favoritesController.toggleFavorite(recipe);
                recipeController.recipeDetail.value!.isFavorite =
                    recipe.isFavorite;
                recipeController.update();
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (recipeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (recipeController.recipeDetail.value == null) {
          return Center(child: Text('Recipe details not available'));
        } else {
          final recipe = recipeController.recipeDetail.value!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  recipe.image,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.timer),
                          SizedBox(width: 8),
                          Text('${recipe.readyInMinutes} minutes'),
                          SizedBox(width: 24),
                          Icon(Icons.people),
                          SizedBox(width: 8),
                          Text('${recipe.servings} servings'),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (recipe.diets.isNotEmpty) ...[
                        Text(
                          'Diets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: recipe.diets
                              .map((diet) => Chip(
                                    label: Text(diet.capitalize ?? ''),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 16),
                      ],
                      Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = recipe.ingredients[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text('• '),
                                Text(
                                  '${ingredient['amount'].toStringAsFixed(1)} ${ingredient['unit']} ${ingredient['name']}',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: recipe.instructions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(recipe.instructions[index]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
