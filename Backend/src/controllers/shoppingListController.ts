import { Request, Response } from 'express';
import { z } from 'zod';
import { getDb, persistDb } from '../db/database';
import { Ingredient } from '../models/Recipe';
import { ShoppingListItem, ShoppingListItemRow, ShoppingListGroup } from '../models/ShoppingList';

const AggregateSchema = z.object({
  recipeIds: z.array(z.number().int().positive()).min(1),
});

const AmountSchema = z.object({
  amount: z.number().positive(),
});

function queryRows<T>(sql: string, params: (string | number | null)[] = []): T[] {
  const db = getDb();
  const result = db.exec(sql, params);
  if (!result.length) return [];
  const { columns, values } = result[0];
  return values.map((row: unknown[]) => {
    const obj: Record<string, unknown> = {};
    columns.forEach((col: string, i: number) => { obj[col] = row[i]; });
    return obj as T;
  });
}

function queryOne<T>(sql: string, params: (string | number | null)[] = []): T | undefined {
  return queryRows<T>(sql, params)[0];
}

function rowToItem(row: ShoppingListItemRow): ShoppingListItem {
  return { ...row, checked: row.checked === 1 };
}

function groupItems(items: ShoppingListItem[]): ShoppingListGroup[] {
  const grouped = new Map<string, ShoppingListItem[]>();
  for (const item of items) {
    if (!grouped.has(item.category)) grouped.set(item.category, []);
    grouped.get(item.category)!.push(item);
  }
  return Array.from(grouped.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([category, items]) => ({
      category,
      items: items.sort((a, b) => a.name.localeCompare(b.name)),
    }));
}

interface IngredientWithCategory extends Ingredient {
  category: string;
}

export const getShoppingList = (_req: Request, res: Response): void => {
  const rows = queryRows<ShoppingListItemRow>(
    'SELECT * FROM shopping_list ORDER BY category, name'
  );
  res.json(groupItems(rows.map(rowToItem)));
};

export const aggregateShoppingList = (req: Request, res: Response): void => {
  const parsed = AggregateSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const { recipeIds } = parsed.data;
  const db = getDb();

  const placeholders = recipeIds.map(() => '?').join(', ');
  const rows = queryRows<IngredientWithCategory>(
    `SELECT i.name, i.amount, i.unit, r.category
     FROM ingredients i
     JOIN recipes r ON r.id = i.recipe_id
     WHERE i.recipe_id IN (${placeholders})`,
    recipeIds
  );

  const aggregated = new Map<string, IngredientWithCategory>();
  for (const row of rows) {
    const key = `${row.name.toLowerCase()}__${row.unit.toLowerCase()}`;
    const existing = aggregated.get(key);
    if (existing) {
      existing.amount = Math.round((existing.amount + row.amount) * 100) / 100;
    } else {
      aggregated.set(key, { ...row });
    }
  }

  for (const item of aggregated.values()) {
    const key = `${item.name.toLowerCase()}__${item.unit.toLowerCase()}`;
    const existingRow = queryOne<ShoppingListItemRow>(
      'SELECT * FROM shopping_list WHERE LOWER(name) = ? AND LOWER(unit) = ?',
      [item.name.toLowerCase(), item.unit.toLowerCase()]
    );
    if (existingRow) {
      const newAmount = Math.round((existingRow.amount + item.amount) * 100) / 100;
      db.run('UPDATE shopping_list SET amount = ? WHERE id = ?', [newAmount, existingRow.id]);
    } else {
      db.run(
        'INSERT INTO shopping_list (name, amount, unit, category) VALUES (?, ?, ?, ?)',
        [item.name, item.amount, item.unit, item.category]
      );
    }
  }
  persistDb();

  const saved = queryRows<ShoppingListItemRow>('SELECT * FROM shopping_list ORDER BY category, name');
  res.status(201).json(groupItems(saved.map(rowToItem)));
};

export const checkItem = (req: Request, res: Response): void => {
  const id = Number(req.params.id);
  const row = queryOne<ShoppingListItemRow>('SELECT * FROM shopping_list WHERE id = ?', [id]);
  if (!row) {
    res.status(404).json({ error: 'Eintrag nicht gefunden' });
    return;
  }

  const newChecked = row.checked === 1 ? 0 : 1;
  getDb().run('UPDATE shopping_list SET checked = ? WHERE id = ?', [newChecked, id]);
  persistDb();

  const updated = queryOne<ShoppingListItemRow>('SELECT * FROM shopping_list WHERE id = ?', [id])!;
  res.json(rowToItem(updated));
};

export const updateAmount = (req: Request, res: Response): void => {
  const id = Number(req.params.id);
  const parsed = AmountSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const row = queryOne<ShoppingListItemRow>('SELECT * FROM shopping_list WHERE id = ?', [id]);
  if (!row) {
    res.status(404).json({ error: 'Eintrag nicht gefunden' });
    return;
  }

  getDb().run('UPDATE shopping_list SET amount = ? WHERE id = ?', [parsed.data.amount, id]);
  persistDb();

  const updated = queryOne<ShoppingListItemRow>('SELECT * FROM shopping_list WHERE id = ?', [id])!;
  res.json(rowToItem(updated));
};

export const deleteChecked = (_req: Request, res: Response): void => {
  getDb().run('DELETE FROM shopping_list WHERE checked = 1');
  persistDb();

  const remaining = queryRows<ShoppingListItemRow>('SELECT * FROM shopping_list ORDER BY category, name');
  res.json(groupItems(remaining.map(rowToItem)));
};

export const clearShoppingList = (_req: Request, res: Response): void => {
  getDb().run('DELETE FROM shopping_list');
  persistDb();
  res.status(204).send();
};
