import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/view/favorites_page.dart';
import 'package:mydaymate/features/receipe_planner/view/ingredient_search_page.dart';
import 'package:mydaymate/widgets/recipe_grid.dart';
import 'package:mydaymate/core/theme/app_colors.dart';
import 'package:mydaymate/core/utils/devices.dart';

class receipe_planner extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    final FavoritesController favoritesController =
        Get.find<FavoritesController>();
    final theme = Theme.of(context);
    final primaryColor = AppColors.primary;
    final secondaryColor = AppColors.secondary;

    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: DeviceLayout.spacing(isSmallScreen ? 0 : 8),
        title: Text(
          'Meal Planner',
          style: isSmallScreen
              ? Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.primary)
              : Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: screenSize.width * 0.05,
                    color: AppColors.primary, // Responsive font size
                  ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Ingredient search button
          Container(
            margin: EdgeInsets.symmetric(horizontal: DeviceLayout.spacing(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.kitchen_outlined,
                color: primaryColor,
              ),
              tooltip: 'Ingredients',
              onPressed: () => Get.to(() => IngredientSearchPage()),
            ),
          ),
          // Favorites button
          Container(
            margin: EdgeInsets.symmetric(horizontal: DeviceLayout.spacing(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.favorite_outline,
                color: primaryColor,
              ),
              tooltip: 'Favorites',
              onPressed: () => Get.to(() => FavoritesPage()),
            ),
          ),
          // Filters button
          Container(
            margin: EdgeInsets.all(DeviceLayout.spacing(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: primaryColor,
              ),
              tooltip: 'Filters',
              onPressed: () => showFiltersDialog(context),
            ),
          ),
          SizedBox(width: DeviceLayout.spacing(8)),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
              Colors.grey.shade100.withOpacity(0.5),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Recipe Finder Card
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DeviceLayout.spacing(16),
                vertical: DeviceLayout.spacing(8),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.8,
                    colors: [
                      primaryColor.withOpacity(0.8),
                      primaryColor,
                      primaryColor.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: DeviceLayout.spacing(12),
                      offset: Offset(0, DeviceLayout.spacing(4)),
                      spreadRadius: DeviceLayout.spacing(2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                      DeviceLayout.spacing(isSmallScreen ? 16 : 20)),
                  child: Column(
                    children: [
                      Text(
                        'Find Delicious Recipes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(12)),

                      // Search bar with glass effect
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DeviceLayout.spacing(8),
                          vertical: DeviceLayout.spacing(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(DeviceLayout.spacing(12)),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search recipes...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: DeviceLayout.fontSize(
                                  isSmallScreen ? 14 : 16),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: DeviceLayout.spacing(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              onPressed: () {
                                searchController.clear();
                                recipeController.fetchRandomRecipes();
                              },
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            recipeController.searchRecipes(value);
                          },
                        ),
                      ),
                      SizedBox(height: DeviceLayout.spacing(16)),

                      // Stats row with glass effect
                      Obx(() {
                        final recipeCount =
                            recipeController.filteredRecipes.length;
                        final favoriteCount =
                            favoritesController.favorites.length;

                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical:
                                DeviceLayout.spacing(isSmallScreen ? 10 : 12),
                            horizontal:
                                DeviceLayout.spacing(isSmallScreen ? 8 : 12),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(12)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                context: context,
                                title: 'Recipes',
                                count: recipeCount,
                                icon: Icons.restaurant_menu,
                                isSmallScreen: isSmallScreen,
                                iconColor: Colors.white,
                              ),
                              Container(
                                height: DeviceLayout.spacing(40),
                                width: DeviceLayout.spacing(1),
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildStatItem(
                                context: context,
                                title: 'Favorites',
                                count: favoriteCount,
                                icon: Icons.favorite,
                                isSmallScreen: isSmallScreen,
                                iconColor: Colors.redAccent,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Active filters display
            GetBuilder<RecipeController>(
              builder: (controller) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: controller.selectedDiets.isEmpty ? 0 : 50,
                  child: controller.selectedDiets.isEmpty
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: DeviceLayout.spacing(16),
                            vertical: DeviceLayout.spacing(4),
                          ),
                          child: Row(
                            children: [
                              // Vertical accent bar
                              Container(
                                width: DeviceLayout.spacing(4),
                                height: DeviceLayout.spacing(20),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(
                                      DeviceLayout.spacing(2)),
                                ),
                              ),
                              SizedBox(width: DeviceLayout.spacing(8)),
                              Text(
                                'Active Filters: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: DeviceLayout.fontSize(14),
                                  color: Colors.grey[700],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.selectedDiets.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          right: DeviceLayout.spacing(8)),
                                      child: Chip(
                                        label: Text(
                                          controller.selectedDiets[index],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: DeviceLayout.fontSize(12),
                                          ),
                                        ),
                                        backgroundColor: primaryColor,
                                        deleteIconColor: Colors.white,
                                        onDeleted: () {
                                          controller.toggleDietFilter(
                                              controller.selectedDiets[index]);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.clearFilters();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: DeviceLayout.spacing(8),
                                    vertical: DeviceLayout.spacing(4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(
                                        DeviceLayout.spacing(16)),
                                  ),
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(
                                      fontSize: DeviceLayout.fontSize(12),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),

            // Recipes Header
            Padding(
              padding: EdgeInsets.only(
                left: DeviceLayout.spacing(16),
                right: DeviceLayout.spacing(16),
                top: DeviceLayout.spacing(16),
                bottom: DeviceLayout.spacing(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: DeviceLayout.spacing(4),
                        height: DeviceLayout.spacing(20),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(DeviceLayout.spacing(2)),
                        ),
                      ),
                      SizedBox(width: DeviceLayout.spacing(8)),
                      Text(
                        'Recipes',
                        style: TextStyle(
                          fontSize:
                              DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recipes grid
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: DeviceLayout.spacing(10),
                      offset: Offset(0, DeviceLayout.spacing(2)),
                      spreadRadius: DeviceLayout.spacing(1),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: DeviceLayout.spacing(16),
                  vertical: DeviceLayout.spacing(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
                  child: Obx(() {
                    if (recipeController.isLoading.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                            SizedBox(height: DeviceLayout.spacing(16)),
                            Text(
                              'Loading recipes...',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      );
                    } else if (recipeController.filteredRecipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_meals,
                              size: DeviceLayout.spacing(64),
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: DeviceLayout.spacing(16)),
                            Text(
                              'No recipes found',
                              style: TextStyle(
                                fontSize: DeviceLayout.fontSize(18),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: DeviceLayout.spacing(8)),
                            Text(
                              'Try searching for a different recipe\nor removing some filters',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: DeviceLayout.spacing(24)),
                            ElevatedButton.icon(
                              icon: Icon(Icons.refresh),
                              label: Text('Refresh Recipes'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: DeviceLayout.spacing(20),
                                  vertical: DeviceLayout.spacing(12),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      DeviceLayout.spacing(8)),
                                ),
                              ),
                              onPressed: () =>
                                  recipeController.fetchRandomRecipes(),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return RecipeGrid(
                        recipes: recipeController.filteredRecipes,
                        scrollController: scrollController,
                      );
                    }
                  }),
                ),
              ),
            ),

            SizedBox(height: DeviceLayout.spacing(8)),
          ],
        ),
      ),

      // Gradient floating action button
      floatingActionButton: Container(
        width: DeviceLayout.spacing(56),
        height: DeviceLayout.spacing(56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.3),
              blurRadius: DeviceLayout.spacing(10),
              offset: Offset(0, DeviceLayout.spacing(4)),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
          ),
          child: Icon(Icons.shuffle),
          onPressed: () {
            // Animate to top if needed
            if (scrollController.hasClients) {
              scrollController.animateTo(
                0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOutQuad,
              );
            }
            // Fetch new random recipes
            recipeController.fetchRandomRecipes();
          },
          tooltip: 'Random recipes',
        ),
      ),
    );
  }

  // Helper method to build stat items
  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required bool isSmallScreen,
    Color? iconColor,
  }) {
    final iconSize = DeviceLayout.spacing(isSmallScreen ? 32 : 36);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
          ),
        ),
        SizedBox(width: DeviceLayout.spacing(isSmallScreen ? 6 : 8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: DeviceLayout.fontSize(isSmallScreen ? 12 : 13),
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Filter dialog with matching design
  void showFiltersDialog(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    final primaryColor = AppColors.primary;
    final secondaryColor = AppColors.secondary;

    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    Get.dialog(
      AlertDialog(
        title: Text(
          'Filter by Diet',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: DeviceLayout.fontSize(isSmallScreen ? 18 : 20),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DeviceLayout.spacing(16)),
        ),
        content: Container(
          width: double.maxFinite,
          height: DeviceLayout.spacing(400),
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: DeviceLayout.spacing(8)),
                child: Text(
                  'Select dietary preferences to filter recipes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: DeviceLayout.fontSize(isSmallScreen ? 13 : 14),
                  ),
                ),
              ),
              SizedBox(height: DeviceLayout.spacing(16)),
              Expanded(
                child: GetBuilder<RecipeController>(
                  builder: (controller) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.availableDiets.length,
                      itemBuilder: (context, index) {
                        final diet = controller.availableDiets[index];
                        return Obx(() => Container(
                              margin: EdgeInsets.only(
                                  bottom: DeviceLayout.spacing(8)),
                              decoration: BoxDecoration(
                                color: controller.selectedDiets.contains(diet)
                                    ? primaryColor.withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(
                                    DeviceLayout.spacing(8)),
                                border: Border.all(
                                  color: controller.selectedDiets.contains(diet)
                                      ? primaryColor.withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  diet,
                                  style: TextStyle(
                                    color:
                                        controller.selectedDiets.contains(diet)
                                            ? primaryColor
                                            : Colors.grey[800],
                                    fontWeight:
                                        controller.selectedDiets.contains(diet)
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 14 : 16),
                                  ),
                                ),
                                activeColor: primaryColor,
                                value: controller.selectedDiets.contains(diet),
                                onChanged: (bool? value) {
                                  controller.toggleDietFilter(diet);
                                },
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: DeviceLayout.spacing(8),
                                  vertical: DeviceLayout.spacing(4),
                                ),
                                dense: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      DeviceLayout.spacing(8)),
                                ),
                              ),
                            ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              recipeController.clearFilters();
              Get.back();
            },
            child: Text(
              'Clear All',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: DeviceLayout.fontSize(isSmallScreen ? 13 : 14),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor.withOpacity(0.9),
                  secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DeviceLayout.spacing(8)),
              boxShadow: [
                BoxShadow(
                  color: secondaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: DeviceLayout.fontSize(isSmallScreen ? 13 : 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DeviceLayout.spacing(8)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: DeviceLayout.spacing(16),
                  vertical: DeviceLayout.spacing(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
