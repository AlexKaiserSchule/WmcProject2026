import initSqlJs, { Database } from 'sql.js';
import path from 'path';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const dbPath = path.resolve(process.env.DB_PATH || './data/recipes.db');
const dir = path.dirname(dbPath);

let db: Database;

export async function initDb(): Promise<Database> {
  if (db) return db;

  const SQL = await initSqlJs();

  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  if (fs.existsSync(dbPath)) {
    const fileBuffer = fs.readFileSync(dbPath);
    db = new SQL.Database(fileBuffer);
  } else {
    db = new SQL.Database();
  }

  db.run('PRAGMA foreign_keys = ON;');

  db.run(`
    CREATE TABLE IF NOT EXISTS categories (
      id   INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT    NOT NULL UNIQUE
    );
  `);

  const existingCats = db.exec('SELECT COUNT(*) as cnt FROM categories');
  const catCount = existingCats[0]?.values[0][0] as number;
  if (catCount === 0) {
    const defaults = ['Vegan', 'Dessert', 'Hauptgericht', 'Snack', 'Frühstück'];
    for (const name of defaults) {
      db.run('INSERT OR IGNORE INTO categories (name) VALUES (?)', [name]);
    }
  }

  db.run(`
    CREATE TABLE IF NOT EXISTS recipes (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      name        TEXT    NOT NULL,
      image_url   TEXT,
      difficulty  INTEGER NOT NULL CHECK(difficulty BETWEEN 1 AND 5),
      category    TEXT    NOT NULL,
      prep_time   INTEGER NOT NULL,
      steps       TEXT    NOT NULL,
      created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
    );
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS ingredients (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      recipe_id  INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
      name       TEXT    NOT NULL,
      amount     REAL    NOT NULL,
      unit       TEXT    NOT NULL
    );
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS shopping_list (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      name       TEXT    NOT NULL,
      amount     REAL    NOT NULL,
      unit       TEXT    NOT NULL,
      category   TEXT    NOT NULL,
      checked    INTEGER NOT NULL DEFAULT 0,
      created_at TEXT    NOT NULL DEFAULT (datetime('now'))
    );
  `);

  persistDb();
  return db;
}

export function persistDb(): void {
  if (!db) return;
  const data = db.export();
  fs.writeFileSync(dbPath, Buffer.from(data));
}

export function getDb(): Database {
  if (!db) throw new Error('DB not initialised. Call initDb() first.');
  return db;
}
