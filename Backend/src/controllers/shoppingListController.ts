import { Request, Response } from 'express';
import { z } from 'zod';
import { getDb } from '../db/database';
import { Ingredient } from '../models/Recipe';

const AggregateSchema = z.object({
  recipeIds: z.array(z.number().int().positive()).min(1),
});

export interface ShoppingListItem {
  name: string;
  amount: number;
  unit: string;
}

export interface ShoppingListGroup {
  category: string;
  items: ShoppingListItem[];
}

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

interface IngredientWithCategory extends Ingredient {
  category: string;
}

export const aggregateShoppingList = (req: Request, res: Response): void => {
  const parsed = AggregateSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const { recipeIds } = parsed.data;

  const placeholders = recipeIds.map(() => '?').join(', ');
  const rows = queryRows<IngredientWithCategory>(
    `SELECT i.name, i.amount, i.unit, r.category
     FROM ingredients i
     JOIN recipes r ON r.id = i.recipe_id
     WHERE i.recipe_id IN (${placeholders})`,
    recipeIds
  );

  const aggregated = new Map<string, ShoppingListItem>();

  for (const row of rows) {
    const key = `${row.name.toLowerCase()}__${row.unit.toLowerCase()}`;
    const existing = aggregated.get(key);
    if (existing) {
      existing.amount = Math.round((existing.amount + row.amount) * 100) / 100;
    } else {
      aggregated.set(key, { name: row.name, amount: row.amount, unit: row.unit });
    }
  }

  const grouped = new Map<string, ShoppingListItem[]>();

  for (const row of rows) {
    const key = `${row.name.toLowerCase()}__${row.unit.toLowerCase()}`;
    const item = aggregated.get(key);
    if (!item) continue;

    if (!grouped.has(row.category)) {
      grouped.set(row.category, []);
    }

    const group = grouped.get(row.category)!;
    if (!group.find((i) => i.name === item.name && i.unit === item.unit)) {
      group.push(item);
    }
  }

  const result: ShoppingListGroup[] = Array.from(grouped.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([category, items]) => ({
      category,
      items: items.sort((a, b) => a.name.localeCompare(b.name)),
    }));

  res.json(result);
};
