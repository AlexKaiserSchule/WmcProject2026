import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response } from 'express';
import cors from 'cors';
import { initDb } from './db/database';
import recipesRouter from './routes/recipes';
import shoppingListRouter from './routes/shoppingList';
import categoriesRouter from './routes/categories';

const app = express();
const port = Number(process.env.PORT) || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (_req: Request, res: Response) => {
  res.json({ message: 'Recipe Vault API is running' });
});

app.use('/api/recipes', recipesRouter);
app.use('/api/shopping-list', shoppingListRouter);
app.use('/api/categories', categoriesRouter);

async function bootstrap() {
  await initDb();
  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}

bootstrap();
