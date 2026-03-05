import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  // ── Recipes ─────────────────────────────────────────────────────────────────

  Future<List<Recipe>> getRecipes({
    String? category,
    String? search,
    int? difficulty,
  }) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    if (difficulty != null) params['difficulty'] = difficulty.toString();

    final uri = Uri.parse('$_baseUrl/recipes').replace(queryParameters: params.isEmpty ? null : params);
    final response = await http.get(uri);
    _checkStatus(response);
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Recipe> getRecipeById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes/$id'));
    _checkStatus(response);
    return Recipe.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Recipe> createRecipe(Recipe recipe) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );
    _checkStatus(response);
    return Recipe.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Recipe> updateRecipe(int id, Recipe recipe) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/recipes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );
    _checkStatus(response);
    return Recipe.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteRecipe(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/recipes/$id'));
    _checkStatus(response);
  }

  // ── Image Upload ─────────────────────────────────────────────────────────────

  Future<String> uploadImage(List<int> bytes, String filename) async {
    final uri = Uri.parse('$_baseUrl/images');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _checkStatus(response);
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['imageUrl'] as String;
  }

  String imageUrl(String path) => 'http://localhost:3000$path';

  // ── Categories ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories'));
    _checkStatus(response);
    return List<Map<String, dynamic>>.from(json.decode(response.body) as List);
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException $statusCode: $body';
}
