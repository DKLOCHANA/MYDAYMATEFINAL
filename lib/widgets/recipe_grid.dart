import 'package:flutter/material.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';

import 'recipe_card.dart';

class RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipeGrid({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeCard(recipe: recipes[index]);
      },
    );
  }
}
