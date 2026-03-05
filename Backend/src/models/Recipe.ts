export interface Ingredient {
  id?: number;
  recipe_id?: number;
  name: string;
  amount: number;
  unit: string;
}

export interface Recipe {
  id?: number;
  name: string;
  image_url?: string | null;
  difficulty: number;
  category: string;
  prep_time: number;
  steps: string[];
  ingredients: Ingredient[];
  created_at?: string;
  updated_at?: string;
}

export interface RecipeRow {
  id: number;
  name: string;
  image_url: string | null;
  difficulty: number;
  category: string;
  prep_time: number;
  steps: string;
  created_at: string;
  updated_at: string;
}
