class FoodGroupsController < ApplicationController
  # GET /food_groups
  def index
    @food_groups = FoodGroup.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /food_groups/1
  def show
    @food_group = FoodGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /food_groups/new
  def new
    @food_group = FoodGroup.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /food_groups/1/edit
  def edit
    @food_group = FoodGroup.find(params[:id])
  end

  # POST /food_groups
  def create
    @food_group = FoodGroup.new(params[:food_group])

    respond_to do |format|
      if @food_group.save
        format.html { redirect_to(@food_group, :notice => 'Food group was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /food_groups/1
  def update
    @food_group = FoodGroup.find(params[:id])

    respond_to do |format|
      if @food_group.update_attributes(params[:food_group])
        format.html { redirect_to(@food_group, :notice => 'Food group was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /food_groups/1
  def destroy
    @food_group = FoodGroup.find(params[:id])
    @food_group.destroy

    respond_to do |format|
      format.html { redirect_to(food_groups_url) }
    end
  end
end
