import { Request, Response } from 'express';
import { z } from 'zod';
import { getDb, persistDb } from '../db/database';
import { Recipe, RecipeRow, Ingredient } from '../models/Recipe';

const IngredientSchema = z.object({
  name: z.string().min(1),
  amount: z.number().positive(),
  unit: z.string().min(1),
});

const RecipeSchema = z.object({
  name: z.string().min(1),
  image_url: z.string().optional().nullable(),
  difficulty: z.number().int().min(1).max(5),
  category: z.string().min(1),
  prep_time: z.number().int().positive(),
  steps: z.array(z.string().min(1)).min(1),
  ingredients: z.array(IngredientSchema).min(1),
});

function rowToRecipe(row: RecipeRow, ingredients: Ingredient[]): Recipe {
  return {
    id: row.id,
    name: row.name,
    image_url: row.image_url,
    difficulty: row.difficulty,
    category: row.category,
    prep_time: row.prep_time,
    steps: JSON.parse(row.steps),
    ingredients,
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
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

function queryOne<T>(sql: string, params: (string | number | null)[] = []): T | undefined {
  const rows = queryRows<T>(sql, params);
  return rows[0];
}

function getIngredients(recipeId: number): Ingredient[] {
  return queryRows<Ingredient>(
    'SELECT id, recipe_id, name, amount, unit FROM ingredients WHERE recipe_id = ?',
    [recipeId]
  );
}

export const getAllRecipes = (req: Request, res: Response): void => {
  const { category, search, difficulty } = req.query;

  let query = 'SELECT * FROM recipes WHERE 1=1';
  const params: (string | number | null)[] = [];

  if (category) {
    query += ' AND category = ?';
    params.push(String(category));
  }
  if (difficulty) {
    query += ' AND difficulty = ?';
    params.push(Number(difficulty));
  }
  if (search) {
    query += ' AND name LIKE ?';
    params.push(`%${String(search)}%`);
  }

  query += ' ORDER BY created_at DESC';

  const rows = queryRows<RecipeRow>(query, params);
  const recipes: Recipe[] = rows.map((row) => rowToRecipe(row, getIngredients(row.id)));
  res.json(recipes);
};

export const getRecipeById = (req: Request, res: Response): void => {
  const row = queryOne<RecipeRow>('SELECT * FROM recipes WHERE id = ?', [Number(req.params.id)]);

  if (!row) {
    res.status(404).json({ error: 'Rezept nicht gefunden' });
    return;
  }

  res.json(rowToRecipe(row, getIngredients(row.id)));
};

export const createRecipe = (req: Request, res: Response): void => {
  const parsed = RecipeSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const { name, image_url, difficulty, category, prep_time, steps, ingredients } = parsed.data;
  const db = getDb();

  db.run(
    `INSERT INTO recipes (name, image_url, difficulty, category, prep_time, steps, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, datetime('now'))`,
    [name, image_url ?? null, difficulty, category, prep_time, JSON.stringify(steps)]
  );

  const newId = (db.exec('SELECT last_insert_rowid() as id')[0].values[0][0]) as number;

  for (const ing of ingredients) {
    db.run(
      'INSERT INTO ingredients (recipe_id, name, amount, unit) VALUES (?, ?, ?, ?)',
      [newId, ing.name, ing.amount, ing.unit]
    );
  }

  persistDb();

  const row = queryOne<RecipeRow>('SELECT * FROM recipes WHERE id = ?', [newId])!;
  res.status(201).json(rowToRecipe(row, getIngredients(newId)));
};

export const updateRecipe = (req: Request, res: Response): void => {
  const existing = queryOne('SELECT id FROM recipes WHERE id = ?', [Number(req.params.id)]);
  if (!existing) {
    res.status(404).json({ error: 'Rezept nicht gefunden' });
    return;
  }

  const parsed = RecipeSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const { name, image_url, difficulty, category, prep_time, steps, ingredients } = parsed.data;
  const id = Number(req.params.id);
  const db = getDb();

  db.run(
    `UPDATE recipes
     SET name = ?, image_url = ?, difficulty = ?, category = ?, prep_time = ?, steps = ?, updated_at = datetime('now')
     WHERE id = ?`,
    [name, image_url ?? null, difficulty, category, prep_time, JSON.stringify(steps), id]
  );

  db.run('DELETE FROM ingredients WHERE recipe_id = ?', [id]);

  for (const ing of ingredients) {
    db.run(
      'INSERT INTO ingredients (recipe_id, name, amount, unit) VALUES (?, ?, ?, ?)',
      [id, ing.name, ing.amount, ing.unit]
    );
  }

  persistDb();

  const row = queryOne<RecipeRow>('SELECT * FROM recipes WHERE id = ?', [id])!;
  res.json(rowToRecipe(row, getIngredients(id)));
};

export const deleteRecipe = (req: Request, res: Response): void => {
  const existing = queryOne('SELECT id FROM recipes WHERE id = ?', [Number(req.params.id)]);
  if (!existing) {
    res.status(404).json({ error: 'Rezept nicht gefunden' });
    return;
  }

  getDb().run('DELETE FROM recipes WHERE id = ?', [Number(req.params.id)]);
  persistDb();
  res.status(204).send();
};
