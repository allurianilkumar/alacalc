class IngredientItemsController < ApplicationController
  # Load cancan before filter
  load_and_authorize_resource :recipe
  load_and_authorize_resource

  before_filter :get_recipe

  def get_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  # GET /ingredient_items
  def index
    @ingredient_items = @recipe.ingredient_items
    # Compute the weight value for each ingredient
    (0..@ingredient_items.size-1).each do |i|
      @ingredient_items[i].compute_weight_in_grams
    end
    # Sort ingredients by grams
    @ingredient_items.sort!

    respond_to do |format|
      format.html # index.html.erb
      format.js { render 'ingredient_items/index.js.erb' }
      format.json {
        # Fetch the ingredients in order 
        ids = @ingredient_items.map{|ii| ii.ingredient_id}
        @ingredients = Ingredient.find_in_order(ids)
        # Invoke the calculation of the nutritional information 
        @ingredients.map{|i| i.calculate_nutritions_and_allergens_for_subrecipe}
        # Fetch the quantities in order 
        ids = @ingredient_items.map{|ii| ii.quantity_unit_id}
        @quantity_units = Weight.find_in_order(ids)
      }
    end
  end

  # GET /ingredient_items/cumulated
  def cumulated
    # Lists the ingredients, cumulated with the ingredients from all subrecipes.
    ingredient_items = @recipe.ingredient_items

    # Cumulate the ingredient_items of subrecipes
    @ingredient_items = IngredientItem.cumulate(ingredient_items)


    # Compute the weight value for each ingredient
    (0..@ingredient_items.size-1).each do |i|
      @ingredient_items[i].compute_weight_in_grams
    end

    # Sort ingredients by grams
    @ingredient_items.sort!

    respond_to do |format|
      format.json {
        # Fetch the ingredients in order 
        ids = @ingredient_items.map{|ii| ii.ingredient_id}
        @ingredients = Ingredient.find_in_order(ids)
        # Fetch the quantities in order 
        ids = @ingredient_items.map{|ii| ii.quantity_unit_id}
        @quantity_units = Weight.find_in_order(ids)
      }
    end
  end

  def search
    sources = []
    if not params[:custom].nil? 
        sources.push('custom')
    end
    if not params[:alacalc].nil? 
        sources.push('alacalc')
    end
    if not params[:usda].nil? 
        sources.push('usda_sr26')
    end
    if not params[:cofids].nil? 
        sources.push('cofids')
    end

    if @recipe.is_sub_recipe
      # in the case we show the ingredients of a subrecipe, make sure we do not list the subrecipe itself in the search result 
      self_ingredient_id = SubRecipe.find_by_recipe_id(@recipe.id).ingredient_id
      @ingredients = Ingredient.do_search(sources, current_user, params[:q], I18n.locale, params[:page], per_page=15, exclude_list={ :id => self_ingredient_id }) 
    else
      @ingredients = Ingredient.do_search(sources, current_user, params[:q], I18n.locale, params[:page]) 
    end

    render :layout => false  
  end

  def recipe_row
    # TODO: FIXME - security issue, as any ingredient, ingredient_item, quantity and weight can be retrieved here
    @ingredient = Ingredient.find_by_id(params[:ingredient_id])
    @ingredient_item_id = params[:ingredient_item_id]
    @quantity = params[:quantity]
    @weight = Weight.find(params[:weight_id])
    render :layout => false
  end

  def quantity_fields
    # TODO: FIXME - security issue, as any ingredient can be retrieved here
    @ingredient = Ingredient.find_by_id(params[:ingredient_id])

    if params[:locale] == 'us'
      @first_weight = @ingredient.weights.find_by_msre_desc('oz')
    else
      @first_weight = @ingredient.weights.find_by_msre_desc('g')
    end

    render :layout => false
  end

end
