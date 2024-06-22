class ControlpanelsController < ApplicationController
  authorize_resource 

  def index
    @paid_recipes = Recipe.of_user(current_user).where('paid IS NOT NULL').order('updated_at desc').limit(7)
    @unpaid_recipes = Recipe.of_user(current_user).where('paid IS NULL').order('updated_at desc').limit(7)
    @ingredients = Ingredient.of_user(current_user).order('updated_at desc').limit(7)
    @user_recipes_count = Recipe.of_user(current_user).count
    @user_ingredients_count = Ingredient.of_user(current_user).count
  end

end
