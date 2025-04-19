import 'package:get/get.dart';

class Recipe {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final List<String> dishTypes;
  final List<String> diets;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.dishTypes,
    required this.diets,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      dishTypes:
          json['dishTypes'] != null ? List<String>.from(json['dishTypes']) : [],
      diets: json['diets'] != null ? List<String>.from(json['diets']) : [],
      isFavorite: false,
    );
  }
}
