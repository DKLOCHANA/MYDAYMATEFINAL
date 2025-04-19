class MealPlan {
  final List<Meal> meals;
  final Nutrients nutrients;

  MealPlan({
    required this.meals,
    required this.nutrients,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      meals: (json['meals'] as List).map((x) => Meal.fromJson(x)).toList(),
      nutrients: Nutrients.fromJson(json['nutrients']),
    );
  }
}

class Meal {
  final int id;
  final String title;
  final int readyInMinutes;
  final int servings;
  final String sourceUrl;
  final String imageType;

  Meal({
    required this.id,
    required this.title,
    required this.readyInMinutes,
    required this.servings,
    required this.sourceUrl,
    required this.imageType,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      title: json['title'],
      readyInMinutes: json['readyInMinutes'],
      servings: json['servings'],
      sourceUrl: json['sourceUrl'],
      imageType: json['imageType'],
    );
  }
}

class Nutrients {
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  Nutrients({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory Nutrients.fromJson(Map<String, dynamic> json) {
    return Nutrients(
      calories: json['calories'],
      protein: json['protein'],
      fat: json['fat'],
      carbohydrates: json['carbohydrates'],
    );
  }
}
