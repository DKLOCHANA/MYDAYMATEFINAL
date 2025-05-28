import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mydaymate/features/receipe_planner/controller/favorites_controller.dart';
import 'package:mydaymate/features/receipe_planner/controller/recipe_controller.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';
import 'package:mydaymate/core/utils/devices.dart';
import 'package:mydaymate/core/theme/app_colors.dart';

class RecipeDetailPage extends StatelessWidget {
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
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        // Gradient background like financial planner
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
        child: Obx(() {
          if (recipeController.isLoading.value) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(DeviceLayout.spacing(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DeviceLayout.spacing(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: DeviceLayout.spacing(48),
                      height: DeviceLayout.spacing(48),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    SizedBox(height: DeviceLayout.spacing(16)),
                    Text(
                      'Loading recipe details...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: DeviceLayout.fontSize(16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (recipeController.recipeDetail.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: DeviceLayout.spacing(60),
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: DeviceLayout.spacing(16)),
                  Text(
                    'Recipe details not available',
                    style: TextStyle(
                      fontSize: DeviceLayout.fontSize(18),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: DeviceLayout.spacing(8)),
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      padding: EdgeInsets.symmetric(
                        horizontal: DeviceLayout.spacing(16),
                        vertical: DeviceLayout.spacing(8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DeviceLayout.spacing(20)),
                        side: BorderSide(color: primaryColor, width: 1),
                      ),
                    ),
                    icon: Icon(Icons.arrow_back, color: primaryColor),
                    label: Text(
                      'Go Back',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: DeviceLayout.fontSize(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final recipe = recipeController.recipeDetail.value!;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Flexible app bar with image
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Recipe image
                        Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                  child: Icon(Icons.broken_image, size: 60)),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                        // Recipe title at bottom of image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(DeviceLayout.spacing(16)),
                            child: Text(
                              recipe.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: DeviceLayout.fontSize(
                                    isSmallScreen ? 20 : 24),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: Container(
                    margin: EdgeInsets.all(DeviceLayout.spacing(8)),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.all(DeviceLayout.spacing(8)),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          final recipeToToggle = Recipe(
                            id: recipe.id,
                            title: recipe.title,
                            image: recipe.image,
                            readyInMinutes: recipe.readyInMinutes,
                            servings: recipe.servings,
                            dishTypes: recipe.dishTypes,
                            diets: recipe.diets,
                            isFavorite: recipe.isFavorite,
                          );
                          favoritesController.toggleFavorite(recipeToToggle);
                          recipe.isFavorite = recipeToToggle.isFavorite;
                          recipeController.update();
                        },
                      ),
                    ),
                  ],
                ),

                // Recipe content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: DeviceLayout.spacing(isSmallScreen ? 8 : 10),
                      horizontal: DeviceLayout.spacing(isSmallScreen ? 16 : 20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview card with recipe info
                        Container(
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
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(16)),
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
                                  'Recipe Overview',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: DeviceLayout.fontSize(
                                        isSmallScreen ? 16 : 18),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: DeviceLayout.spacing(16)),

                                // Stats row with glass effect
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: DeviceLayout.spacing(
                                        isSmallScreen ? 10 : 12),
                                    horizontal: DeviceLayout.spacing(
                                        isSmallScreen ? 8 : 12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                        DeviceLayout.spacing(12)),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatItem(
                                        context: context,
                                        title: 'Time',
                                        value: '${recipe.readyInMinutes} min',
                                        icon: Icons.timer,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      Container(
                                        height: DeviceLayout.spacing(40),
                                        width: DeviceLayout.spacing(1),
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      _buildStatItem(
                                        context: context,
                                        title: 'Servings',
                                        value: '${recipe.servings}',
                                        icon: Icons.people,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ],
                                  ),
                                ),

                                // Diets chips
                                if (recipe.diets.isNotEmpty) ...[
                                  SizedBox(height: DeviceLayout.spacing(16)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: DeviceLayout.spacing(
                                          isSmallScreen ? 10 : 12),
                                      horizontal: DeviceLayout.spacing(
                                          isSmallScreen ? 20 : 12),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(
                                          DeviceLayout.spacing(12)),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Diets',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: DeviceLayout.fontSize(
                                                isSmallScreen ? 16 : 18),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(
                                            height: DeviceLayout.spacing(8)),
                                        Wrap(
                                          spacing: DeviceLayout.spacing(8),
                                          runSpacing: DeviceLayout.spacing(8),
                                          children: recipe.diets.map((diet) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    DeviceLayout.spacing(10),
                                                vertical:
                                                    DeviceLayout.spacing(6),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        DeviceLayout.spacing(
                                                            20)),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                diet.capitalize ?? '',
                                                style: TextStyle(
                                                  fontSize:
                                                      DeviceLayout.fontSize(
                                                          isSmallScreen
                                                              ? 11
                                                              : 12),
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: DeviceLayout.spacing(24)),

                        // Ingredients section
                        _buildSectionHeader(context, 'Ingredients',
                            Icons.shopping_basket, isSmallScreen),
                        SizedBox(height: DeviceLayout.spacing(12)),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(16)),
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  DeviceLayout.spacing(isSmallScreen ? 12 : 16),
                              vertical:
                                  DeviceLayout.spacing(isSmallScreen ? 0 : 16),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: recipe.ingredients.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey.shade200,
                                height: DeviceLayout.spacing(15),
                              ),
                              itemBuilder: (context, index) {
                                final ingredient = recipe.ingredients[index];
                                return Row(
                                  children: [
                                    Container(
                                      width: DeviceLayout.spacing(
                                          isSmallScreen ? 32 : 36),
                                      height: DeviceLayout.spacing(
                                          isSmallScreen ? 32 : 36),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryColor.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: DeviceLayout.fontSize(
                                                isSmallScreen ? 12 : 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: DeviceLayout.spacing(12)),
                                    Expanded(
                                      child: Text(
                                        '${ingredient['amount'].toStringAsFixed(1)} ${ingredient['unit']} ${ingredient['name']}',
                                        style: TextStyle(
                                          fontSize: DeviceLayout.fontSize(
                                              isSmallScreen ? 14 : 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: DeviceLayout.spacing(24)),

                        // Instructions section
                        _buildSectionHeader(context, 'Instructions',
                            Icons.format_list_numbered, isSmallScreen),
                        SizedBox(height: DeviceLayout.spacing(12)),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(DeviceLayout.spacing(16)),
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
                          child: Padding(
                            padding: EdgeInsets.all(
                                DeviceLayout.spacing(isSmallScreen ? 12 : 16)),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: recipe.instructions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: DeviceLayout.spacing(16)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: DeviceLayout.spacing(
                                            isSmallScreen ? 36 : 40),
                                        height: DeviceLayout.spacing(
                                            isSmallScreen ? 36 : 40),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              secondaryColor.withOpacity(0.8),
                                              secondaryColor,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: secondaryColor
                                                  .withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: DeviceLayout.fontSize(
                                                  isSmallScreen ? 14 : 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: DeviceLayout.spacing(12)),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: DeviceLayout.spacing(8)),
                                          child: Text(
                                            recipe.instructions[index],
                                            style: TextStyle(
                                              fontSize: DeviceLayout.fontSize(
                                                  isSmallScreen ? 14 : 15),
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: DeviceLayout.spacing(24)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: DeviceLayout.spacing(4),
          height: DeviceLayout.spacing(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(DeviceLayout.spacing(2)),
          ),
        ),
        SizedBox(width: DeviceLayout.spacing(8)),
        Icon(
          icon,
          size: DeviceLayout.fontSize(isSmallScreen ? 18 : 20),
          color: AppColors.primary,
        ),
        SizedBox(width: DeviceLayout.spacing(8)),
        Text(
          title,
          style: TextStyle(
            fontSize: DeviceLayout.fontSize(isSmallScreen ? 16 : 18),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // Helper method to build stat items
  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required bool isSmallScreen,
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
            color: Colors.white,
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
              value,
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
}
