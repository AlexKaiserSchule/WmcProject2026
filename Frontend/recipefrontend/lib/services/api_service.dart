import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    final ext = filename.split('.').last.toLowerCase();
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
    };
    final contentType = mimeTypes[ext] ?? 'application/octet-stream';
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ));
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

  // ── Shopping List ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getShoppingList() async {
    final response = await http.get(Uri.parse('$_baseUrl/shopping-list'));
    _checkStatus(response);
    return json.decode(response.body) as List<dynamic>;
  }

  Future<List<dynamic>> aggregateShoppingList(List<int> recipeIds) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/shopping-list/aggregate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'recipeIds': recipeIds}),
    );
    _checkStatus(response);
    return json.decode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> checkItem(int id) async {
    final response = await http.put(Uri.parse('$_baseUrl/shopping-list/$id/check'));
    _checkStatus(response);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateItemAmount(int id, double amount) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/shopping-list/$id/amount'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount}),
    );
    _checkStatus(response);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> deleteCheckedItems() async {
    final response = await http.delete(Uri.parse('$_baseUrl/shopping-list/checked'));
    _checkStatus(response);
    return json.decode(response.body) as List<dynamic>;
  }

  Future<void> clearShoppingList() async {
    final response = await http.delete(Uri.parse('$_baseUrl/shopping-list'));
    _checkStatus(response);
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
