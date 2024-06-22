class IngredientsController < ApplicationController
  # Load cancan before filter
  load_and_authorize_resource

  # GET /ingredients
  helper_method :sort_column, :sort_direction

  def index
    query = Ingredient.generate_searchstring(params[:search])
    @ingredients = Ingredient.search(query,
                                     :page => params[:page], 
                                     :per_page => 20, 
                                     :index => "ingredient_#{ I18n.locale }", 
                                     :with => { :user_id => current_user.id, :is_subrecipe => false},
                                     :ranker => :sph04, 
                                     :sort_mode => :extended, 
                                     :select => 'weight() as w',
                                     :order => 'w DESC, alpha_order ASC', 
                                     :star => true, 
                                     :retry_stale => true, 
                                     :include => :translations)

    # Even if retry_scale tries to avoid nil results as much as it can, it sometimes still happens; so lets compactify the result to be 100% sure
    @ingredients.delete_if {|x| x == nil}

    @user_ingredients = Ingredient.of_user(current_user).limit(1)
    respond_to do |format|
      format.html # index.html.haml
      format.js  { render 'ingredients/index.js.erb' }
    end
  end

  # GET /ingredients/new
  def new
    if params['copy_from']
      @ingredient.update_from_ingredient(Ingredient.find(params['copy_from']), current_user)
    end
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /ingredients/1/edit
  def edit
  end

  # POST /ingredients
  def create
    @ingredient.user = current_user

    Ingredient.nutrients.each do |nutrient|
      if params[:ingredient][nutrient.to_s].downcase == 'trace' or params[:ingredient][nutrient.to_s].downcase == 'tr'
        @ingredient[nutrient] = 1e-13
      end
    end

    respond_to do |format|
      if @ingredient.save
         format.html { redirect_to(edit_ingredient_path(@ingredient, :recipe_id => params[:recipe_id])) }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @ingredient.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ingredients/1
  def update

    Ingredient.nutrients.each do |nutrient|
      if params[:ingredient][nutrient.to_s].downcase == 'trace' or params[:ingredient][nutrient.to_s].downcase == 'tr'
        params[:ingredient][nutrient.to_s] = 1e-13
      end
    end

    respond_to do |format|
      if @ingredient.update_attributes(params[:ingredient])
        format.html { redirect_to(edit_ingredient_path(@ingredient)) }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @ingredient.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ingredients/1
  def destroy
    @ingredient.destroy

    respond_to do |format|
      format.html { redirect_to(ingredients_url) }
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

    @ingredients = Ingredient.do_search(sources, current_user, params[:q], I18n.locale, params[:page])

    render :layout => false  
  end

  def nutrients
    @recipe_selections = Recipe.selections
    if params[:ingredient_id].nil?
    else
      @ingredient = Ingredient.find_by_id(params[:ingredient_id])
      if not @ingredient["Sodium"].nil?
        @ingredient['Salt'] = @ingredient["Sodium"]*58.5/23.0
      end
    end
    render :layout => false
  end
  respond_to do |format|
    format.html
    format.json
  end

end
