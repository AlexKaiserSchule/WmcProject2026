import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  Recipe? _recipe;
  bool _loading = true;
  bool _loaded = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final id = ModalRoute.of(context)!.settings.arguments as int;
    _loadRecipe(id);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe(int id) async {
    try {
      final recipe = await _api.getRecipeById(id);
      setState(() {
        _recipe = recipe;
        _loading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Rezept nicht gefunden')),
      );
    }

    final recipe = _recipe!;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: _buildHeroImage(recipe),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/edit-recipe',
                      arguments: recipe.id);
                  _loadRecipe(recipe.id!);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, recipe),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(recipe, theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Zutaten', theme),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record, size: 8),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatAmount(ing.amount)} ${ing.unit} ${ing.name}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Anleitung', theme),
                  const SizedBox(height: 8),
                  ...recipe.steps.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  Text(
                    'Zubereitungszeit: ${recipe.prepTime} Min.',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addToShoppingList(recipe),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Zur Einkaufsliste'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareRecipe(recipe),
                          icon: const Icon(Icons.share),
                          label: const Text('Teilen'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Recipe recipe) {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return Hero(
        tag: 'recipe-${recipe.id}',
        child: Image.network(
          _api.imageUrl(recipe.imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imagePlaceholder(),
        ),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Recipe recipe, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(recipe.category,
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
        ),
        const SizedBox(width: 12),
        RatingBarIndicator(
          rating: recipe.difficulty.toDouble(),
          itemBuilder: (_, __) =>
              Icon(Icons.star, color: theme.colorScheme.primary),
          itemCount: 5,
          itemSize: 20,
        ),
        const Spacer(),
        Icon(Icons.timer_outlined,
            size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text('${recipe.prepTime} Min.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  String _formatAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
  }

  void _addToShoppingList(Recipe recipe) {
    context.read<ShoppingListProvider>().aggregateFromRecipes([recipe.id!]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zutaten von „${recipe.name}" zur Einkaufsliste hinzugefügt'),
        action: SnackBarAction(
          label: 'Anzeigen',
          onPressed: () => Navigator.pushNamed(context, '/shopping-list'),
        ),
      ),
    );
  }

  void _shareRecipe(Recipe recipe) {
    final text = StringBuffer();
    text.writeln('🍽️ ${recipe.name}');
    text.writeln('Kategorie: ${recipe.category}');
    text.writeln('Schwierigkeit: ${"⭐" * recipe.difficulty}');
    text.writeln('Zubereitungszeit: ${recipe.prepTime} Min.');
    text.writeln('');
    text.writeln('Zutaten:');
    for (final ing in recipe.ingredients) {
      text.writeln('  - ${_formatAmount(ing.amount)} ${ing.unit} ${ing.name}');
    }
    text.writeln('');
    text.writeln('Anleitung:');
    for (int i = 0; i < recipe.steps.length; i++) {
      text.writeln('  ${i + 1}. ${recipe.steps[i]}');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rezept teilen'),
        content: SingleChildScrollView(
          child: SelectableText(text.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rezept löschen?'),
        content: Text('„${recipe.name}" wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<RecipeProvider>().deleteRecipe(recipe.id!);
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
