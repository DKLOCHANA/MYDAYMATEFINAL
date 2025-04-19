class RecipeDetail {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final String summary;
  final List<String> dishTypes;
  final List<String> diets;
  final List<Map<String, dynamic>> ingredients;
  final List<String> instructions;
  bool isFavorite;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.summary,
    required this.dishTypes,
    required this.diets,
    required this.ingredients,
    required this.instructions,
    this.isFavorite = false,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    // Parse ingredients
    List<Map<String, dynamic>> ingredients = [];
    if (json['extendedIngredients'] != null) {
      for (var item in json['extendedIngredients']) {
        ingredients.add({
          'name': item['name'] ?? '',
          'amount': item['amount'] ?? 0,
          'unit': item['unit'] ?? '',
        });
      }
    }

    // Parse instructions
    List<String> instructions = [];
    if (json['analyzedInstructions'] != null &&
        json['analyzedInstructions'].isNotEmpty) {
      for (var step in json['analyzedInstructions'][0]['steps']) {
        instructions.add(step['step']);
      }
    }

    return RecipeDetail(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      summary: json['summary'] ?? '',
      dishTypes:
          json['dishTypes'] != null ? List<String>.from(json['dishTypes']) : [],
      diets: json['diets'] != null ? List<String>.from(json['diets']) : [],
      ingredients: ingredients,
      instructions: instructions,
      isFavorite: false,
    );
  }
}
