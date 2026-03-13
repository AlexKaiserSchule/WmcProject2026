import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _picker = ImagePicker();
  final _nameCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  late AnimationController _stepAnimationController;
  late Animation<double> _stepFadeAnimation;

  String _category = 'Hauptgericht';
  int _difficulty = 3;
  String? _imageUrl;
  bool _saving = false;
  int _currentStep = 0;

  final List<Map<String, TextEditingController>> _ingredientCtrls = [];
  final List<TextEditingController> _stepCtrls = [];
  List<String> _categories = ['Vegan', 'Dessert', 'Hauptgericht', 'Snack', 'Frühstück'];

  int? _editId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _stepFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stepAnimationController, curve: Curves.easeIn),
    );
    _stepAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadCategories();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _editId = args;
      _loadExisting(args);
    } else {
      _addIngredient();
      _addStep();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _api.getCategories();
      final names = cats.map((c) => c['name'] as String).toList();
      if (mounted && names.isNotEmpty) {
        setState(() {
          _categories = names;
          if (!_categories.contains(_category)) _category = _categories.first;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadExisting(int id) async {
    try {
      final r = await _api.getRecipeById(id);
      setState(() {
        _nameCtrl.text = r.name;
        _prepTimeCtrl.text = r.prepTime.toString();
        _category = r.category;
        _difficulty = r.difficulty;
        _imageUrl = r.imageUrl;
        for (final ing in r.ingredients) {
          _ingredientCtrls.add({
            'name': TextEditingController(text: ing.name),
            'amount': TextEditingController(text: _fmtAmt(ing.amount)),
            'unit': TextEditingController(text: ing.unit),
          });
        }
        for (final s in r.steps) {
          _stepCtrls.add(TextEditingController(text: s));
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _prepTimeCtrl.dispose();
    _stepAnimationController.dispose();
    for (final m in _ingredientCtrls) { m.values.forEach((c) => c.dispose()); }
    for (final c in _stepCtrls) { c.dispose(); }
    super.dispose();
  }

  void _addIngredient() => setState(() => _ingredientCtrls.add({
    'name': TextEditingController(), 'amount': TextEditingController(), 'unit': TextEditingController(),
  }));

  void _addStep() => setState(() => _stepCtrls.add(TextEditingController()));

  String _fmtAmt(double a) => a == a.roundToDouble() ? a.toInt().toString() : a.toStringAsFixed(1);

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final url = await _api.uploadImage(bytes, file.name);
      setState(() => _imageUrl = url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload fehlgeschlagen: $e')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredientCtrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mindestens eine Zutat hinzufügen')));
      return;
    }
    if (_stepCtrls.isEmpty || _stepCtrls.every((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mindestens einen Schritt hinzufügen')));
      return;
    }

    setState(() => _saving = true);
    final recipe = Recipe(
      name: _nameCtrl.text.trim(),
      imageUrl: _imageUrl,
      difficulty: _difficulty,
      category: _category,
      prepTime: int.parse(_prepTimeCtrl.text.trim()),
      steps: _stepCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
      ingredients: _ingredientCtrls.where((m) => m['name']!.text.trim().isNotEmpty).map((m) => Ingredient(
        name: m['name']!.text.trim(),
        amount: double.tryParse(m['amount']!.text.trim()) ?? 1,
        unit: m['unit']!.text.trim().isEmpty ? 'Stk' : m['unit']!.text.trim(),
      )).toList(),
    );

    try {
      if (_editId != null) {
        await _api.updateRecipe(_editId!, recipe);
      } else {
        await _api.createRecipe(recipe);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_editId != null ? 'Rezept bearbeiten' : 'Neues Rezept')),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                    _stepAnimationController.reset();
                    _stepAnimationController.forward();
                  } else {
                    _save();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                    _stepAnimationController.reset();
                    _stepAnimationController.forward();
                  }
                },
                onStepTapped: (s) {
                  setState(() => _currentStep = s);
                  _stepAnimationController.reset();
                  _stepAnimationController.forward();
                },
                controlsBuilder: (ctx, details) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(children: [
                    ElevatedButton(onPressed: details.onStepContinue, child: Text(_currentStep == 3 ? 'Speichern' : 'Weiter')),
                    if (_currentStep > 0) ...[const SizedBox(width: 12), TextButton(onPressed: details.onStepCancel, child: const Text('Zurück'))],
                  ]),
                ),
                steps: [
                  Step(
                    title: const Text('Grunddaten'),
                    isActive: _currentStep >= 0,
                    content: FadeTransition(
                      opacity: _stepFadeAnimation,
                      child: _stepBasic(theme),
                    ),
                  ),
                  Step(
                    title: const Text('Zutaten'),
                    isActive: _currentStep >= 1,
                    content: FadeTransition(
                      opacity: _stepFadeAnimation,
                      child: _stepIngredients(),
                    ),
                  ),
                  Step(
                    title: const Text('Anleitung'),
                    isActive: _currentStep >= 2,
                    content: FadeTransition(
                      opacity: _stepFadeAnimation,
                      child: _stepSteps(),
                    ),
                  ),
                  Step(
                    title: const Text('Bild'),
                    isActive: _currentStep >= 3,
                    content: FadeTransition(
                      opacity: _stepFadeAnimation,
                      child: _stepImage(theme),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _stepBasic(ThemeData theme) => Column(children: [
    TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Name eingeben' : null),
    const SizedBox(height: 12),
    TextFormField(controller: _prepTimeCtrl, decoration: const InputDecoration(labelText: 'Zubereitungszeit (Min)'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => v == null || v.isEmpty || (int.tryParse(v) ?? 0) <= 0 ? 'Gültige Zahl eingeben' : null),
    const SizedBox(height: 12),
    DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Kategorie'), items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _category = v!)),
    const SizedBox(height: 16),
    Row(children: [
      Text('Schwierigkeit:', style: theme.textTheme.bodyLarge),
      const SizedBox(width: 12),
      RatingBar.builder(initialRating: _difficulty.toDouble(), minRating: 1, itemCount: 5, itemSize: 32, itemBuilder: (_, __) => Icon(Icons.star, color: theme.colorScheme.primary), onRatingUpdate: (v) => _difficulty = v.toInt()),
    ]),
  ]);

  Widget _stepIngredients() => Column(children: [
    ..._ingredientCtrls.asMap().entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        Row(children: [
          Expanded(flex: 3, child: TextFormField(controller: e.value['amount'], decoration: const InputDecoration(labelText: 'Menge', hintText: 'z.B. 200', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)), keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))])),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: TextFormField(controller: e.value['unit'], decoration: const InputDecoration(labelText: 'Einheit', hintText: 'z.B. g', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)))),
          const SizedBox(width: 12),
          Expanded(flex: 5, child: TextFormField(controller: e.value['name'], decoration: const InputDecoration(labelText: 'Zutat', hintText: 'z.B. Mehl', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)))),
          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: _ingredientCtrls.length > 1 ? () => setState(() { _ingredientCtrls[e.key].values.forEach((c) => c.dispose()); _ingredientCtrls.removeAt(e.key); }) : null),
        ]),
      ]),
    )),
    TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add), label: const Text('Zutat hinzufügen')),
  ]);

  Widget _stepSteps() => Column(children: [
    ..._stepCtrls.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 14, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12))),
      const SizedBox(width: 8),
      Expanded(child: TextFormField(controller: e.value, decoration: const InputDecoration(labelText: 'Schritt'), maxLines: 3)),
      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: _stepCtrls.length > 1 ? () => setState(() { _stepCtrls[e.key].dispose(); _stepCtrls.removeAt(e.key); }) : null),
    ]))),
    TextButton.icon(onPressed: _addStep, icon: const Icon(Icons.add), label: const Text('Schritt hinzufügen')),
  ]);

  Widget _stepImage(ThemeData theme) => Column(children: [
    if (_imageUrl != null) ...[
      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_api.imageUrl(_imageUrl!), height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 180, child: Center(child: Icon(Icons.broken_image, size: 48))))),
      const SizedBox(height: 12),
    ],
    OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: Text(_imageUrl != null ? 'Bild ändern' : 'Bild hochladen')),
  ]);
}
