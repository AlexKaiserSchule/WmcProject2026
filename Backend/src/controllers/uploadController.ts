import { Request, Response } from 'express';
import { getDb, persistDb } from '../db/database';

interface ImageRow {
  id: number;
  mime_type: string;
  data: Uint8Array;
  created_at: string;
}

function queryOne<T>(sql: string, params: (string | number | null)[] = []): T | undefined {
  const db = getDb();
  const result = db.exec(sql, params);
  if (!result.length) return undefined;
  const { columns, values } = result[0];
  const obj: Record<string, unknown> = {};
  columns.forEach((col: string, i: number) => { obj[col] = values[0][i]; });
  return obj as T;
}

export const uploadImage = (req: Request, res: Response): void => {
  if (!req.file) {
    res.status(400).json({ error: 'Kein Bild hochgeladen' });
    return;
  }

  const { mimetype, buffer } = req.file;
  const db = getDb();

  db.run(
    'INSERT INTO images (mime_type, data) VALUES (?, ?)',
    [mimetype, buffer]
  );

  const newId = (db.exec('SELECT last_insert_rowid() as id')[0].values[0][0]) as number;
  persistDb();

  res.status(201).json({ imageUrl: `/api/images/${newId}` });
};

export const getImage = (req: Request, res: Response): void => {
  const id = Number(req.params.id);
  const row = queryOne<ImageRow>('SELECT id, mime_type, data FROM images WHERE id = ?', [id]);

  if (!row) {
    res.status(404).json({ error: 'Bild nicht gefunden' });
    return;
  }

  res.setHeader('Content-Type', row.mime_type);
  res.setHeader('Cache-Control', 'public, max-age=31536000');
  res.send(Buffer.from(row.data));
};

export const deleteImage = (req: Request, res: Response): void => {
  const id = Number(req.params.id);
  const existing = queryOne('SELECT id FROM images WHERE id = ?', [id]);

  if (!existing) {
    res.status(404).json({ error: 'Bild nicht gefunden' });
    return;
  }

  getDb().run('DELETE FROM images WHERE id = ?', [id]);
  persistDb();
  res.status(204).send();
};
