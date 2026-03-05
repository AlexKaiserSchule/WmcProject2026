export interface ShoppingListItem {
  id?: number;
  name: string;
  amount: number;
  unit: string;
  category: string;
  checked: boolean;
  created_at?: string;
}

export interface ShoppingListItemRow {
  id: number;
  name: string;
  amount: number;
  unit: string;
  category: string;
  checked: number;
  created_at: string;
}

export interface ShoppingListGroup {
  category: string;
  items: ShoppingListItem[];
}
