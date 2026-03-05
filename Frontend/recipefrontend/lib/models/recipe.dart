class Ingredient {
  final int? id;
  final String name;
  final double amount;
  final String unit;

  const Ingredient({
    this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as int?,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        unit: json['unit'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'unit': unit,
      };
}

class Recipe {
  final int? id;
  final String name;
  final String? imageUrl;
  final int difficulty;
  final String category;
  final int prepTime;
  final List<String> steps;
  final List<Ingredient> ingredients;
  final String? createdAt;

  const Recipe({
    this.id,
    required this.name,
    this.imageUrl,
    required this.difficulty,
    required this.category,
    required this.prepTime,
    required this.steps,
    required this.ingredients,
    this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as int?,
        name: json['name'] as String,
        imageUrl: json['image_url'] as String?,
        difficulty: json['difficulty'] as int,
        category: json['category'] as String,
        prepTime: json['prep_time'] as int,
        steps: List<String>.from(json['steps'] as List),
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'image_url': imageUrl,
        'difficulty': difficulty,
        'category': category,
        'prep_time': prepTime,
        'steps': steps,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };
}
