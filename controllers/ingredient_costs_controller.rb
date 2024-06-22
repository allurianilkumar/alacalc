class IngredientCostsController < ApplicationController
  # Load cancan before filter
  load_and_authorize_resource :recipe
  load_and_authorize_resource

  # GET /ingredient_costs
  # GET /ingredient_costs.json
  def index
    if @recipe.paid? or params[:unlock]
      @ingredient_costs = @recipe.compute_cost()
    end

    current_user.reload # The user credits changed, hence reload the user
    @user = current_user

    respond_to do |format|
      format.html
      format.js
      format.xlsx
    end
  end

  def get_ingredient_cost
    @all_ingredient_costs = []
    @used_ingredients = []
    @unused_ingredients = []
    @missing_ingredients = []

    # Collect all ingredients that occur in the user's recipes
    recipe_ingredients = Set.new []
    current_user.recipes.each do |recipe|
      items = recipe.ingredient_items.includes(:ingredient => [:sub_recipe_join, :translations])
      items.each do |ingredient_item|
        if not ingredient_item.ingredient.deleted?
          recipe_ingredients.add ingredient_item.ingredient
        end
      end
    end

    # Collect all ingredients that have a costing
    all_ingredient_costs = IngredientCost.includes(:ingredient => [:sub_recipe_join, :weights, :translations]).where(:user_id => current_user.id)

    # Remove the costs of deleted ingredients.
    @all_ingredient_costs = []
    all_ingredient_costs.each do |c|
        if not (c.ingredient.nil? or c.ingredient.deleted?) # FIXME: The c.ingredient.nil? is required due to a bug in the unscoped version of IngredientCost.ingredient (i.e. deleted ingredients can be referenced with ic.ingredient)
          @all_ingredient_costs << c
        end
    end

    @all_ingredient_costs.sort_by { |i| i.ingredient.Long_Desc } # Order by translated name. Note, we do not use a SQL statement here because the translation might not exist and a fallback must be used instead.
    all_ingredients = Set.new []
    @all_ingredient_costs.each do |ingredient_cost|
      all_ingredients.add ingredient_cost.ingredient
    end

    # Get the ingredients without a costing
    missing = recipe_ingredients - all_ingredients
    @missing_ingredient_costs = []
    missing.each do |m|
      if not m.sub_recipe?
        ingredient_cost = IngredientCost.new
        ingredient_cost.ingredient = m
        @missing_ingredient_costs << ingredient_cost
      end
    end
    @missing_ingredient_costs.sort_by { |i| i.ingredient.Long_Desc }

    @missing_ids =[]
    @missing_ingredient_costs.each do |missing_id|
      @missing_ids << missing_id.ingredient_id
    end

    @sub_recipe_missing_ids = []
    recipe_ingredients.each do |ingredient|
      if ingredient.sub_recipe?
        ingredient.sub_recipe.ingredient_items.each do |child_item|
          if @missing_ids.include?(child_item.ingredient_id)
            @sub_recipe_missing_ids << ingredient.id
          end
        end
      end
    end

    # Get the used ingredients with a costing
    used = recipe_ingredients & all_ingredients
    # TODO: Optimise this loop
    @used_ingredient_costs = []
    used.each do |u|
      @used_ingredient_costs << IngredientCost.where(:ingredient_id => u.id).first
    end

    # Get the unused ingredients with a costing
    unused = all_ingredients - (recipe_ingredients & all_ingredients)
    # TODO: Optimise this loop
    @unused_ingredient_costs = []
    unused.each do |u|
      @unused_ingredient_costs << IngredientCost.where(:ingredient_id => u.id).first
    end

    # Get the cost overview for all recipes
    @recipe_costs = []
    @recipe_costs_unpaid = []
    current_user.recipes.order('name ASC').each do |recipe|
      if recipe.paid?
        @recipe_costs << Hash['recipe' => recipe, 'costs' => recipe.compute_cost()]
      else
        @recipe_costs_unpaid << Hash['recipe' => recipe, 'costs' => nil]
      end
    end
  end

  def users_ingredient_costs

    @user = current_user
    get_ingredient_cost

    respond_to do |format|
      format.html # users_ingredient_costs.html.erb
      format.js
    end
  end

  def update_individual

    @costs = []
    if params.has_key?(:ingredient_costs)
      params[:ingredient_costs].each do |ingredient_cost|
        ic = IngredientCost.find_by_id(ingredient_cost[0])
        if ic.nil?
          ic = IngredientCost.new
        end
        ic.assign_attributes(ingredient_cost[1])
        ic.user = current_user
        ic.save
        @costs << ic
      end
    end

    @user = current_user
    get_ingredient_cost

    respond_to do |format|
      format.html { render '/ingredient_costs/users_ingredient_costs' }
      format.js { render '/ingredient_costs/users_ingredient_costs.js' }
    end
  end

  # GET /ingredients
  def ingredients
    # path parameters e.g. @ingredient = Ingredient.find_by_id(params[:ingredient_id])
    render :layout => false
  end

  # GET /ingredient_cost_row
  def ingredient_cost_row
    # path parameters e.g. @ingredient = Ingredient.find_by_id(params[:ingredient_id])
    @ingredient = Ingredient.find_by_id(params[:ingredient_id])
    @array_position = params[:position]
    render :layout => false
  end

  def recipe_costs
    render :layout => false
  end

  def recipe_breakdown
    render :layout => false
  end

  def breakdown_cost_boxes
    @user = current_user
    @ingredient_item = IngredientItem.find_by_id(params[:ingredient_item_id])
    render :layout => false
  end

  # GET /ingredient_costs/new
  # GET /ingredient_costs/new.json
  def new
    @ingredient_cost = IngredientCost.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /ingredient_costs/1/edit
  def edit
    @ingredient_cost = IngredientCost.find(params[:id])
  end

  # POST /ingredient_costs
  # POST /ingredient_costs.json
  def create
    @ingredient_cost = IngredientCost.new()
    @ingredient_cost.assign_attributes(params[:ingredient_cost])
    @ingredient_cost.user = current_user

    respond_to do |format|
      if @ingredient_cost.save
        format.html { redirect_to ingredient_costs_url, notice: 'Ingredient cost was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /ingredient_costs/1
  # PUT /ingredient_costs/1.json
  def update
    @ingredient_cost = IngredientCost.find(params[:id])

    respond_to do |format|
      if @ingredient_cost.update_attributes(params[:ingredient_cost])
        format.html { redirect_to ingredient_costs_url }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /ingredient_costs/1
  # DELETE /ingredient_costs/1.json
  def destroy
    @ingredient_cost = IngredientCost.find(params[:id])
    @ingredient_cost.destroy

    respond_to do |format|
      format.html { redirect_to ingredient_costs_url }
      format.json { head :ok }
    end
  end

end
