import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

enum LoadingState { idle, loading, error }

class RecipeProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Recipe> _recipes = [];
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';

  String _searchQuery = '';
  String? _selectedCategory;
  int? _selectedDifficulty;

  List<Recipe> get recipes => _recipes;
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  int? get selectedDifficulty => _selectedDifficulty;

  Future<void> loadRecipes() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _recipes = await _api.getRecipes(
        category: _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        difficulty: _selectedDifficulty,
      );
      _state = LoadingState.idle;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadRecipes();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    loadRecipes();
  }

  void setDifficulty(int? difficulty) {
    _selectedDifficulty = difficulty;
    loadRecipes();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedDifficulty = null;
    loadRecipes();
  }

  Future<void> deleteRecipe(int id) async {
    await _api.deleteRecipe(id);
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
