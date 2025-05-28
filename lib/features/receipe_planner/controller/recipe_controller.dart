import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mydaymate/features/receipe_planner/model/recipe.dart';
import 'package:mydaymate/features/receipe_planner/model/recipe_detail.dart';
import 'dart:convert';

import 'favorites_controller.dart';

class RecipeController extends GetxController {
  // Replace with your actual API key
  final String apiKey = '325dad3c608f4575aa8939a80e0f1026';
  final String baseUrl = 'https://api.spoonacular.com/';

  var isLoading = false.obs;
  var recipes = <Recipe>[].obs;
  var filteredRecipes = <Recipe>[].obs;
  var recipeDetail = Rx<RecipeDetail?>(null);

  // Filter states
  var selectedDiets = <String>[].obs;
  var searchQuery = ''.obs;

  var availableDiets = [
    'Gluten Free',
    'Ketogenic',
    'Vegetarian',
    'Lacto-Vegetarian',
    'Ovo-Vegetarian',
    'Vegan',
    'Pescetarian',
    'Paleo',
    'Primal',
    'Whole30',
  ].obs;

  // Add these new variables
  var availableIngredients = <String>[].obs;
  var suggestedIngredients = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRandomRecipes();
  }

  Future<void> fetchRandomRecipes() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}recipes/random?apiKey=$apiKey&number=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recipeList = data['recipes'];

        recipes.value =
            recipeList.map((json) => Recipe.fromJson(json)).toList();
        applyFilters();
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) {
      fetchRandomRecipes();
      return;
    }

    isLoading.value = true;
    searchQuery.value = query;

    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}recipes/complexSearch?apiKey=$apiKey&query=$query&number=20&addRecipeInformation=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recipeList = data['results'];

        recipes.value =
            recipeList.map((json) => Recipe.fromJson(json)).toList();
        applyFilters();
      } else {
        throw Exception('Failed to search recipes');
      }
    } catch (e) {
      print('Error searching recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRecipeDetail(int id) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}recipes/$id/information?apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        recipeDetail.value = RecipeDetail.fromJson(data);

        // Check if this recipe is in favorites
        final favoritesController = Get.find<FavoritesController>();
        recipeDetail.value!.isFavorite =
            favoritesController.isRecipeFavorite(id);
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      print('Error fetching recipe details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDietFilter(String diet) {
    if (selectedDiets.contains(diet)) {
      selectedDiets.remove(diet);
    } else {
      selectedDiets.add(diet);
    }
    applyFilters();
  }

  void applyFilters() {
    if (selectedDiets.isEmpty) {
      filteredRecipes.value = recipes;
    } else {
      filteredRecipes.value = recipes.where((recipe) {
        for (var diet in selectedDiets) {
          if (!recipe.diets.contains(diet.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    // Update favorite status
    final favoritesController = Get.find<FavoritesController>();
    for (var recipe in filteredRecipes) {
      recipe.isFavorite = favoritesController.isRecipeFavorite(recipe.id);
    }
  }

  void clearFilters() {
    selectedDiets.clear();
    applyFilters();
  }

  // New API functions
  Future<void> getRecipesByMealType(String mealType) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}recipes/complexSearch?apiKey=$apiKey&type=$mealType&number=20&addRecipeInformation=true'),
      );
      handleRecipeResponse(response);
    } catch (e) {
      print('Error fetching $mealType recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRecipesByCuisine(String cuisine) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}recipes/complexSearch?apiKey=$apiKey&cuisine=$cuisine&number=20&addRecipeInformation=true'),
      );
      handleRecipeResponse(response);
    } catch (e) {
      print('Error fetching $cuisine recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMealPlanForDay(int targetCalories) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}mealplanner/generate?apiKey=$apiKey&timeFrame=day&targetCalories=$targetCalories'),
      );
      // Handle meal plan response
    } catch (e) {
      print('Error generating meal plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getWinePairing(String food) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}food/wine/pairing?apiKey=$apiKey&food=$food'),
      );
      // Handle wine pairing response
    } catch (e) {
      print('Error getting wine pairing: $e');
    }
  }

  Future<void> getNutritionInfo(int recipeId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}recipes/$recipeId/nutritionWidget.json?apiKey=$apiKey'),
      );
      // Handle nutrition info response
    } catch (e) {
      print('Error getting nutrition info: $e');
    }
  }

  Future<void> getRecipeEquipment(int recipeId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}recipes/$recipeId/equipmentWidget.json?apiKey=$apiKey'),
      );
      // Handle equipment response
    } catch (e) {
      print('Error getting equipment info: $e');
    }
  }

  Future<void> getSimilarRecipes(int recipeId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${baseUrl}recipes/$recipeId/similar?apiKey=$apiKey&number=4'),
      );
      // Handle similar recipes response
    } catch (e) {
      print('Error getting similar recipes: $e');
    }
  }

  Future<void> getQuickAnswer(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}recipes/quickAnswer?apiKey=$apiKey&q=$query'),
      );
      // Handle quick answer response
    } catch (e) {
      print('Error getting quick answer: $e');
    }
  }

  Future<void> searchByIngredients() async {
    if (availableIngredients.isEmpty) return;

    isLoading.value = true;
    try {
      final ingredients = availableIngredients.join(',');
      final response = await http.get(
        Uri.parse(
          '${baseUrl}recipes/findByIngredients?apiKey=$apiKey&ingredients=$ingredients&number=20&ranking=2&ignorePantry=true',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        recipes.value = data.map((json) => Recipe.fromJson(json)).toList();

        // Include recipes in filtered recipes
        filteredRecipes.value = recipes;

        // Also update favorite status for each recipe
        final favoritesController = Get.find<FavoritesController>();
        for (var recipe in recipes) {
          recipe.isFavorite = favoritesController.isRecipeFavorite(recipe.id);
        }

        // Apply any active filters
        applyFilters();
      }
    } catch (e) {
      print('Error searching by ingredients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getIngredientSuggestions(String query) async {
    if (query.length < 2) {
      suggestedIngredients.clear();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${baseUrl}food/ingredients/autocomplete?apiKey=$apiKey&query=$query&number=5',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        suggestedIngredients.value =
            data.map((item) => item['name'].toString()).toList();
      }
    } catch (e) {
      print('Error getting ingredient suggestions: $e');
    }
  }

  void addIngredient(String ingredient) {
    if (!availableIngredients.contains(ingredient)) {
      availableIngredients.add(ingredient);
    }
    suggestedIngredients.clear();
  }

  void removeIngredient(String ingredient) {
    availableIngredients.remove(ingredient);
  }

  // Helper method to handle recipe responses
  void handleRecipeResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipeList = data['results'] ?? data['recipes'] ?? [];
      recipes.value = recipeList.map((json) => Recipe.fromJson(json)).toList();
      applyFilters();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
