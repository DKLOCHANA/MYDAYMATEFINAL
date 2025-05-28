import 'package:get/get.dart';

class Message {
  final String text;
  final bool isUser;
  final String? imageUrl; // New field for images
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    this.imageUrl,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UserProfile {
  String? name;
  String? age;
  List<String> medicalConditions = [];
  Map<String, String> dailyRoutine = {};
  List<String> hobbies = [];
  Map<String, String> mealTimes = {};
  List<String> favoriteFoods = [];
  Map<String, dynamic> additionalInfo = {};
  bool onboardingCompleted = false;

  UserProfile({
    this.name,
    this.age,
    List<String>? medicalConditions,
    Map<String, String>? dailyRoutine,
    List<String>? hobbies,
    Map<String, String>? mealTimes,
    List<String>? favoriteFoods,
    Map<String, dynamic>? additionalInfo,
    this.onboardingCompleted = false,
  }) {
    this.medicalConditions = medicalConditions ?? [];
    this.dailyRoutine = dailyRoutine ?? {};
    this.hobbies = hobbies ?? [];
    this.mealTimes = mealTimes ?? {};
    this.favoriteFoods = favoriteFoods ?? [];
    this.additionalInfo = additionalInfo ?? {};
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'medicalConditions': medicalConditions,
      'dailyRoutine': dailyRoutine,
      'hobbies': hobbies,
      'mealTimes': mealTimes,
      'favoriteFoods': favoriteFoods,
      'additionalInfo': additionalInfo,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      dailyRoutine: Map<String, String>.from(json['dailyRoutine'] ?? {}),
      hobbies: List<String>.from(json['hobbies'] ?? []),
      mealTimes: Map<String, String>.from(json['mealTimes'] ?? {}),
      favoriteFoods: List<String>.from(json['favoriteFoods'] ?? []),
      additionalInfo: json['additionalInfo'] ?? {},
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }

  String getSummary() {
    return """
Name: $name
Age: $age
Medical Conditions: ${medicalConditions.join(', ')}
Daily Routine: ${dailyRoutine.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
Hobbies: ${hobbies.join(', ')}
Meal Times: ${mealTimes.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
Favorite Foods: ${favoriteFoods.join(', ')}
""";
  }
}
