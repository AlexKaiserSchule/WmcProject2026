import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/add_edit_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'widgets/page_transitions.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
      ],
      child: const RecipeVaultApp(),
    ),
  );
}

class RecipeVaultApp extends StatelessWidget {
  const RecipeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Recipe Vault',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/recipe-detail':
            return FadePageRoute(page: const DetailScreen());
          case '/add-recipe':
            return SlidePageRoute(page: const AddEditScreen());
          case '/edit-recipe':
            return SlidePageRoute(page: const AddEditScreen());
          case '/shopping-list':
            return ScalePageRoute(page: const ShoppingListScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
