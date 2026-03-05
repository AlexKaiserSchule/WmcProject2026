import { Router } from 'express';
import {
  getShoppingList,
  aggregateShoppingList,
  checkItem,
  updateAmount,
  deleteChecked,
  clearShoppingList,
} from '../controllers/shoppingListController';

const router = Router();

router.get('/', getShoppingList);
router.post('/aggregate', aggregateShoppingList);
router.put('/:id/check', checkItem);
router.put('/:id/amount', updateAmount);
router.delete('/checked', deleteChecked);
router.delete('/', clearShoppingList);

export default router;
