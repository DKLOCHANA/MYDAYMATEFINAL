import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';
import 'package:mydaymate/core/utils/devices.dart';
import 'recipe_card.dart';

class RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final ScrollController? scrollController;

  const RecipeGrid({
    Key? key,
    required this.recipes,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Determine grid layout based on screen width
    // For larger tablets, we can show 3 columns
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

    // Adjust aspect ratio based on screen dimensions for better card appearance
    final aspectRatio = _calculateAspectRatio(screenWidth, screenSize.height);

    // Calculate responsive spacing
    final horizontalPadding = DeviceLayout.spacing(screenWidth < 360 ? 8 : 16);
    final gridSpacing = DeviceLayout.spacing(screenWidth < 360 ? 8 : 16);

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(horizontalPadding),
      physics: BouncingScrollPhysics(), // Smoother scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        // Add a "load more" functionality when reaching the end
        if (index == recipes.length - 4) {
          // This is optional: pre-load more recipes when approaching the end
          _loadMoreIfNeeded();
        }

        // Pass the screen width to the RecipeCard
        return RecipeCard(
          recipe: recipes[index],
        );
      },
    );
  }

  // Calculate optimal grid columns based on screen width
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth >= 900) return 4; // Extra large screens
    if (screenWidth >= 600) return 3; // Large tablets
    if (screenWidth >= 400) return 2; // Small tablets and large phones
    return 2; // Small phones get 1 column
  }

  // Calculate optimal aspect ratio based on screen dimensions
  double _calculateAspectRatio(double width, double height) {
    // Base aspect ratio (width/height) for our recipe cards
    double baseRatio = 0.55;

    // Adjust ratio for different device types
    if (width >= 900) {
      // Large screens - slightly wider cards
      return baseRatio * 1.05;
    } else if (width < 360) {
      // Very small screens - narrower cards
      return baseRatio * 0.9;
    } else if (width > height) {
      // Landscape mode - wider cards
      return baseRatio * 1.2;
    }

    // Standard phones in portrait
    return baseRatio;
  }

  // Optional: Lazy load more recipes as user scrolls down
  void _loadMoreIfNeeded() {
    // If you have pagination, you could trigger a load-more here
    // For example:
    // final controller = Get.find<RecipeController>();
    // if (!controller.isLoading.value && controller.hasMorePages) {
    //   controller.loadNextPage();
    // }
  }
}
