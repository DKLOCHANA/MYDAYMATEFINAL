import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/what_can_i_cook/controller/what_can_i_cook_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/view/recipe_detail_page.dart';
import 'package:mydaymate/core/utils/devices.dart';

class WhatCanICookPage extends GetView<WhatCanICookController> {
  const WhatCanICookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive sizing based on screen width
    final responsiveSizing = ResponsiveSizing(screenWidth, screenHeight);

    // Ensure FavoritesController is initialized
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'What Can I Cook?',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: responsiveSizing.fontSize * 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              color: theme.primaryColor,
              Icons.refresh,
              size: responsiveSizing.iconSize * 1.2,
            ),
            tooltip: 'Refresh ingredients',
            onPressed: () => controller.refreshIngredients(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSizing.padding,
            vertical: responsiveSizing.padding * 0.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available ingredients section
              _buildAvailableIngredientsSection(context, responsiveSizing),

              SizedBox(height: responsiveSizing.spacing),

              // Matching recipes section
              Expanded(
                child: _buildMatchingRecipesSection(context, responsiveSizing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableIngredientsSection(
      BuildContext context, ResponsiveSizing sizing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Ingredients',
              style: TextStyle(
                fontSize: sizing.fontSize * 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: sizing.spacing * 0.5),
        Obx(() {
          if (controller.availableIngredients.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: sizing.spacing),
              child: Text(
                'No ingredients found in your grocery list.',
                style: TextStyle(
                  fontSize: sizing.fontSize,
                  color: Colors.grey[700],
                ),
              ),
            );
          }

          return Container(
            height: sizing.containerHeight * 0.2,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(sizing.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: sizing.borderRadius * 0.4,
                  offset: Offset(0, sizing.spacing * 0.2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.availableIngredients.length,
              padding: EdgeInsets.symmetric(
                horizontal: sizing.padding * 0.25,
                vertical: sizing.containerHeight * 0.03,
              ),
              itemBuilder: (context, index) {
                final ingredient = controller.availableIngredients[index];

                // Adjust padding based on text length
                final textLength = ingredient.length;
                final textScaleFactor = textLength > 10 ? 0.5 : 1.0;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.padding * 0.25,
                  ),
                  child: Chip(
                    label: Text(
                      ingredient,
                      style: TextStyle(
                        fontSize: sizing.fontSize * 0.85,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(
                      horizontal: sizing.spacing * textScaleFactor * 0.4,
                      vertical: 0,
                    ),
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: sizing.spacing * textScaleFactor * 0.2,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMatchingRecipesSection(
      BuildContext context, ResponsiveSizing sizing) {
    // Calculate optimal grid layout based on screen width
    final crossAxisCount = _calculateCrossAxisCount(sizing.screenWidth);

    // Dynamic aspect ratio based on screen dimensions
    final childAspectRatio =
        _calculateChildAspectRatio(sizing.screenWidth, sizing.screenHeight);

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: sizing.containerHeight * 0.15,
                height: sizing.containerHeight * 0.15,
                child: CircularProgressIndicator(
                  strokeWidth: sizing.borderRadius * 0.25,
                ),
              ),
              SizedBox(height: sizing.spacing),
              Text(
                'Finding recipes you can make...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: sizing.fontSize,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.matchingRecipes.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizing.padding * 1.25,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: sizing.iconSize * 3,
                    color: Colors.grey,
                  ),
                  SizedBox(height: sizing.spacing),
                  Text(
                    'No matching recipes found',
                    style: TextStyle(
                      fontSize: sizing.fontSize * 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: sizing.spacing * 0.5),
                  Text(
                    'Add more items to your grocery list or mark them as in stock',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: sizing.fontSize,
                    ),
                  ),
                  SizedBox(height: sizing.spacing * 1.5),
                  ElevatedButton(
                    onPressed: () => controller.findMatchingRecipes(),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing.padding * 1.5,
                        vertical: sizing.padding * 0.75,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(sizing.borderRadius * 1.75),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: sizing.fontSize * 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recipes You Can Make',
                style: TextStyle(
                  fontSize: sizing.fontSize * 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(() => Text(
                    '${controller.matchingRecipes.length} recipes',
                    style: TextStyle(
                      fontSize: sizing.fontSize * 0.9,
                      color: Colors.grey[600],
                    ),
                  )),
            ],
          ),
          SizedBox(height: sizing.spacing * 0.5),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: sizing.spacing,
                mainAxisSpacing: sizing.spacing * 0.75,
              ),
              itemCount: controller.matchingRecipes.length,
              itemBuilder: (context, index) {
                final recipe = controller.matchingRecipes[index];
                return _buildRecipeCard(context, recipe, sizing);
              },
            ),
          ),
        ],
      );
    });
  }

  // Calculate optimal grid columns based on screen width
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth >= 900) return 4; // Extra large screens
    if (screenWidth >= 600) return 3; // Large tablets
    if (screenWidth >= 360) return 2; // Small tablets and large phones
    return 1; // Small phones
  }

  // Calculate optimal aspect ratio based on screen dimensions
  double _calculateChildAspectRatio(double width, double height) {
    // Base ratio that works well for recipe cards
    final baseRatio = 0.75;

    // Adjust based on device aspect ratio (more square on wider screens)
    final deviceRatio = width / height;

    if (deviceRatio > 1.0) {
      // Landscape orientation or tablet - more square cards
      return baseRatio * 1.1;
    } else if (width < 360) {
      // Very small screens - more vertical cards
      return baseRatio * 0.9;
    }

    return baseRatio;
  }

  Widget _buildRecipeCard(
      BuildContext context, Recipe recipe, ResponsiveSizing sizing) {
    return FutureBuilder<List<String>>(
      future: controller.getMissingIngredients(recipe),
      builder: (context, snapshot) {
        final missingIngredients = snapshot.data ?? [];

        return Stack(
          children: [
            // Base recipe card
            _buildBaseRecipeCard(context, recipe, missingIngredients, sizing),

            // Add "Add Missing Ingredients" button
            if (missingIngredients.isNotEmpty)
              Positioned(
                right: sizing.spacing * 0.5,
                bottom: sizing.spacing * 0.5,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        controller.addMissingIngredientsToGroceryList(recipe),
                    borderRadius:
                        BorderRadius.circular(sizing.borderRadius * 1.75),
                    child: Padding(
                      padding: EdgeInsets.all(sizing.padding * 0.3),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sizing.padding * 0.4,
                          vertical: sizing.padding * 0.2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius:
                              BorderRadius.circular(sizing.borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: sizing.borderRadius * 0.3,
                              offset: Offset(0, sizing.borderRadius * 0.1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: sizing.iconSize * 0.8,
                            ),
                            SizedBox(width: sizing.spacing * 0.2),
                            Text(
                              'Add ${missingIngredients.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sizing.fontSize * 0.75,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Show "All Ingredients Available" badge if no missing ingredients
            if (missingIngredients.isEmpty)
              Positioned(
                right: sizing.spacing * 0.5,
                top: sizing.spacing * 0.5,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.padding * 0.4,
                    vertical: sizing.padding * 0.2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(sizing.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: sizing.borderRadius * 0.3,
                        offset: Offset(0, sizing.borderRadius * 0.1),
                      ),
                    ],
                  ),
                  child: Text(
                    'Ready to Cook!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sizing.fontSize * 0.75,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBaseRecipeCard(BuildContext context, Recipe recipe,
      List<String> missingIngredients, ResponsiveSizing sizing) {
    // Dynamic image height based on container size
    final imageHeight = sizing.containerHeight * 0.4;

    return GestureDetector(
      onTap: () {
        // Navigate to recipe details
        Get.find<RecipeController>().getRecipeDetail(recipe.id);
        Get.to(() => RecipeDetailPage());
      },
      child: Card(
        elevation: sizing.borderRadius * 0.3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizing.borderRadius * 1.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(sizing.borderRadius * 1.25),
                    topRight: Radius.circular(sizing.borderRadius * 1.25),
                  ),
                  child: Image.network(
                    recipe.image,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          size: sizing.iconSize * 2,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
                // Show match percentage
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FutureBuilder<double>(
                    future: controller.getIngredientsMatchPercentage(recipe),
                    builder: (context, snapshot) {
                      final matchPercentage = snapshot.data?.toInt() ?? 0;

                      if (!snapshot.hasData || matchPercentage == 0) {
                        return const SizedBox();
                      }

                      // Background color based on match percentage
                      Color backgroundColor;
                      if (matchPercentage > 80) {
                        backgroundColor = Colors.green.withOpacity(0.8);
                      } else if (matchPercentage > 50) {
                        backgroundColor = Colors.orange.withOpacity(0.8);
                      } else {
                        backgroundColor = Colors.red.withOpacity(0.8);
                      }

                      return Container(
                        color: backgroundColor,
                        padding: EdgeInsets.symmetric(
                          vertical: sizing.borderRadius * 0.15,
                        ),
                        child: Center(
                          child: Text(
                            '$matchPercentage% Match',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: sizing.fontSize * 0.8,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(sizing.padding * 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: sizing.fontSize,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sizing.spacing * 0.25),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: sizing.iconSize,
                      ),
                      SizedBox(width: sizing.spacing * 0.25),
                      Text(
                        '${recipe.readyInMinutes} min',
                        style: TextStyle(
                          fontSize: sizing.fontSize * 0.8,
                        ),
                      ),
                    ],
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

// Helper class for responsive sizing
class ResponsiveSizing {
  final double screenWidth;
  final double screenHeight;

  // Calculated properties
  late final double fontSize;
  late final double iconSize;
  late final double padding;
  late final double spacing;
  late final double borderRadius;
  late final double containerHeight;

  ResponsiveSizing(this.screenWidth, this.screenHeight) {
    // Base these values on screen dimensions, not hardcoded numbers
    fontSize = screenWidth * 0.035;
    iconSize = screenWidth * 0.05;
    padding = screenWidth * 0.04;
    spacing = screenHeight * 0.02;
    borderRadius = screenWidth * 0.03;
    containerHeight = screenHeight * 0.4;

    // Apply constraints to prevent extremes on very large or small screens
    if (fontSize < 12) fontSize = 12;
    if (fontSize > 18) fontSize = 18;

    if (iconSize < 16) iconSize = 16;
    if (iconSize > 30) iconSize = 30;

    if (padding < 12) padding = 12;
    if (padding > 32) padding = 32;

    if (spacing < 8) spacing = 8;
    if (spacing > 24) spacing = 24;

    if (borderRadius < 8) borderRadius = 8;
    if (borderRadius > 20) borderRadius = 20;
  }
}
