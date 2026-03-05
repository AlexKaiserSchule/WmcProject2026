import { Router } from 'express';
import { aggregateShoppingList } from '../controllers/shoppingListController';

const router = Router();

router.post('/aggregate', aggregateShoppingList);

export default router;
