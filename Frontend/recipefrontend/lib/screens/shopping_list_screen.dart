import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingListProvider>().loadList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'),
        actions: [
          if (provider.checkedItems > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Abgehakte löschen',
              onPressed: () => _confirmDeleteChecked(context, provider),
            ),
          if (provider.totalItems > 0)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Alle löschen',
              onPressed: () => _confirmClearAll(context, provider),
            ),
        ],
      ),
      body: _buildBody(context, provider, theme),
    );
  }

  Widget _buildBody(BuildContext context, ShoppingListProvider provider, ThemeData theme) {
    if (provider.state == ShoppingListState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == ShoppingListState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Fehler beim Laden', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => provider.loadList(),
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    if (provider.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Einkaufsliste ist leer', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Füge Rezepte zur Einkaufsliste hinzu', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadList(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: provider.groups.length,
        itemBuilder: (context, index) {
          final group = provider.groups[index];
          return _buildGroup(context, group, provider, theme);
        },
      ),
    );
  }

  Widget _buildGroup(BuildContext context, ShoppingListGroup group, ShoppingListProvider provider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            group.category,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...group.items.map((item) => _buildItem(context, item, provider, theme)),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildItem(BuildContext context, ShoppingListItem item, ShoppingListProvider provider, ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: item.checked ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3) : null,
        ),
        child: ListTile(
          leading: AnimatedScale(
            scale: item.checked ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Checkbox(
              value: item.checked,
              onChanged: (_) => provider.toggleCheck(item.id),
              activeColor: theme.colorScheme.primary,
            ),
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              decoration: item.checked ? TextDecoration.lineThrough : null,
              color: item.checked ? Colors.grey : theme.colorScheme.onSurface,
              fontSize: 16,
            ),
            child: Text(item.name),
          ),
          subtitle: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: item.checked ? Colors.grey : theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
            child: Text('${_fmtAmt(item.amount)} ${item.unit}'),
          ),
          trailing: AnimatedOpacity(
            opacity: item.checked ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: item.checked ? null : () => _showAmountDialog(context, item, provider),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtAmt(double a) => a == a.roundToDouble() ? a.toInt().toString() : a.toStringAsFixed(1);

  void _showAmountDialog(BuildContext context, ShoppingListItem item, ShoppingListProvider provider) {
    final ctrl = TextEditingController(text: _fmtAmt(item.amount));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Menge für ${item.name}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: item.unit),
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); ctrl.dispose(); }, child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                provider.updateAmount(item.id, val);
                Navigator.pop(ctx);
              }
              ctrl.dispose();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChecked(BuildContext context, ShoppingListProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abgehakte löschen?'),
        content: Text('${provider.checkedItems} Einträge werden gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { provider.deleteChecked(); Navigator.pop(ctx); },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, ShoppingListProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alle löschen?'),
        content: const Text('Die gesamte Einkaufsliste wird geleert.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { provider.clearAll(); Navigator.pop(ctx); },
            child: const Text('Alle löschen'),
          ),
        ],
      ),
    );
  }
}
