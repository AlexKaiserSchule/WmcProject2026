import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';
import '../services/api_service.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<String> _categories = [];
  late AnimationController _fabController;
  late Animation<double> _fabRotation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabRotation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService().getCategories();
      if (mounted) setState(() => _categories = cats.map((c) => c['name'] as String).toList());
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Vault',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showThemePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/shopping-list'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterChips(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
      floatingActionButton: RotationTransition(
        turns: _fabRotation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
          ),
          child: FloatingActionButton(
            onPressed: () async {
              _fabController.forward().then((_) => _fabController.reverse());
              await Navigator.pushNamed(context, '/add-recipe');
              if (mounted) context.read<RecipeProvider>().loadRecipes();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final theme = Theme.of(context);
    final categories = _categories;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Alle'),
              selected: provider.selectedCategory == null,
              onSelected: (_) => provider.setCategory(null),
            ),
            const SizedBox(width: 8),
            ...categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: provider.selectedCategory == cat,
                    onSelected: (selected) =>
                        provider.setCategory(selected ? cat : null),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    if (provider.state == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == LoadingState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Backend nicht erreichbar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => provider.loadRecipes(),
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    if (provider.recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Noch keine Rezepte',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tippe auf + um dein erstes Rezept anzulegen',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRecipes(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: provider.recipes.length,
        itemBuilder: (context, index) {
          final recipe = provider.recipes[index];
          return RecipeCard(
            recipe: recipe,
            index: index,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                '/recipe-detail',
                arguments: recipe.id,
              );
              if (mounted) provider.loadRecipes();
            },
            onDelete: () => _confirmDelete(context, recipe.id!, recipe.name),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rezept suchen...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<RecipeProvider>().setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {});
          context.read<RecipeProvider>().setSearch(value);
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme wählen',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            ...AppTheme.values.map((theme) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor,
                    radius: 16,
                  ),
                  title: Text(theme.label),
                  trailing: themeProvider.currentTheme == theme
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    themeProvider.setTheme(theme);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rezept löschen?'),
        content: Text('„$name" wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<RecipeProvider>().deleteRecipe(id);
              Navigator.pop(ctx);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
