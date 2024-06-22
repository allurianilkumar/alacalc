class WeightsController < ApplicationController
  # Load cancan before filter
  load_and_authorize_resource :ingredient
  load_and_authorize_resource

  before_filter :get_ingredient
  def get_ingredient
    @ingredient = Ingredient.find(params[:ingredient_id])
  end
  
  # GET /weights
  def index
    @weights = @ingredient.weights
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /weights/1/edit
  def edit
    @weight = @ingredient.weights.find(params[:id])
  end

  # POST /weights
  def create
    @weight = @ingredient.weights.build(params[:weight])

    respond_to do |format|
      @weights = @ingredient.weights
      if @weight.save
        format.html { redirect_to(ingredient_weights_path(@ingredient)) }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @weights.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weights/1
  def destroy
    @weight =  @ingredient.weights.find(params[:id])
    @weight.destroy

    respond_to do |format|
      format.html { redirect_to(ingredient_weights_url) }
    end
  end

end
