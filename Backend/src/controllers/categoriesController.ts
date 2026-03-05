import { Request, Response } from 'express';
import { z } from 'zod';
import { getDb, persistDb } from '../db/database';

interface CategoryRow {
  id: number;
  name: string;
}

const CategorySchema = z.object({
  name: z.string().min(1),
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

export const getCategories = (_req: Request, res: Response): void => {
  const rows = queryRows<CategoryRow>('SELECT * FROM categories ORDER BY name');
  res.json(rows);
};

export const createCategory = (req: Request, res: Response): void => {
  const parsed = CategorySchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.flatten() });
    return;
  }

  const { name } = parsed.data;
  const existing = queryOne<CategoryRow>('SELECT * FROM categories WHERE name = ?', [name]);
  if (existing) {
    res.status(409).json({ error: 'Kategorie existiert bereits' });
    return;
  }

  getDb().run('INSERT INTO categories (name) VALUES (?)', [name]);
  persistDb();

  const created = queryOne<CategoryRow>('SELECT * FROM categories WHERE name = ?', [name])!;
  res.status(201).json(created);
};

export const deleteCategory = (req: Request, res: Response): void => {
  const id = Number(req.params.id);
  const existing = queryOne<CategoryRow>('SELECT * FROM categories WHERE id = ?', [id]);
  if (!existing) {
    res.status(404).json({ error: 'Kategorie nicht gefunden' });
    return;
  }

  const inUse = queryOne<{ cnt: number }>(
    'SELECT COUNT(*) as cnt FROM recipes WHERE category = ?',
    [existing.name]
  );
  if (inUse && inUse.cnt > 0) {
    res.status(409).json({ error: `Kategorie wird von ${inUse.cnt} Rezept(en) verwendet und kann nicht gelöscht werden` });
    return;
  }

  getDb().run('DELETE FROM categories WHERE id = ?', [id]);
  persistDb();
  res.status(204).send();
};
