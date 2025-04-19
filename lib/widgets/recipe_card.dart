import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';
import 'package:mydaymate/features/receipe_planner/view/recipe_detail_page.dart';

class RecipeCard extends GetView<FavoritesController> {
  final Recipe recipe;

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final RecipeController recipeController = Get.find<RecipeController>();
        recipeController.getRecipeDetail(recipe.id);
        Get.to(() => RecipeDetailPage());
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    recipe.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.broken_image)),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GetBuilder<FavoritesController>(
                    builder: (controller) => CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                        onPressed: () => controller.toggleFavorite(recipe),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16),
                      SizedBox(width: 4),
                      Text('${recipe.readyInMinutes} min',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  if (recipe.dishTypes.isNotEmpty)
                    Text(
                      recipe.dishTypes.first.capitalize ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
