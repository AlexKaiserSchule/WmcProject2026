import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ShoppingListItem {
  final int id;
  final String name;
  final double amount;
  final String unit;
  final String category;
  final bool checked;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
    required this.checked,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => ShoppingListItem(
        id: json['id'] as int,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        unit: json['unit'] as String,
        category: json['category'] as String,
        checked: json['checked'] as bool,
      );
}

class ShoppingListGroup {
  final String category;
  final List<ShoppingListItem> items;

  ShoppingListGroup({required this.category, required this.items});

  factory ShoppingListGroup.fromJson(Map<String, dynamic> json) => ShoppingListGroup(
        category: json['category'] as String,
        items: (json['items'] as List)
            .map((i) => ShoppingListItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}

enum ShoppingListState { idle, loading, error }

class ShoppingListProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<ShoppingListGroup> _groups = [];
  ShoppingListState _state = ShoppingListState.idle;
  String _errorMessage = '';

  List<ShoppingListGroup> get groups => _groups;
  ShoppingListState get state => _state;
  String get errorMessage => _errorMessage;

  int get totalItems => _groups.fold(0, (sum, g) => sum + g.items.length);
  int get checkedItems => _groups.fold(
      0, (sum, g) => sum + g.items.where((i) => i.checked).length);

  Future<void> loadList() async {
    _state = ShoppingListState.loading;
    notifyListeners();
    try {
      final data = await _api.getShoppingList();
      _groups = data
          .map((g) => ShoppingListGroup.fromJson(g as Map<String, dynamic>))
          .toList();
      _state = ShoppingListState.idle;
    } catch (e) {
      _state = ShoppingListState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> aggregateFromRecipes(List<int> recipeIds) async {
    _state = ShoppingListState.loading;
    notifyListeners();
    try {
      final data = await _api.aggregateShoppingList(recipeIds);
      _groups = data
          .map((g) => ShoppingListGroup.fromJson(g as Map<String, dynamic>))
          .toList();
      _state = ShoppingListState.idle;
    } catch (e) {
      _state = ShoppingListState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> toggleCheck(int itemId) async {
    try {
      await _api.checkItem(itemId);
      await loadList();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> updateAmount(int itemId, double amount) async {
    try {
      await _api.updateItemAmount(itemId, amount);
      await loadList();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> deleteChecked() async {
    try {
      final data = await _api.deleteCheckedItems();
      _groups = data
          .map((g) => ShoppingListGroup.fromJson(g as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> clearAll() async {
    try {
      await _api.clearShoppingList();
      _groups = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
}
