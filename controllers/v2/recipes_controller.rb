class V2::RecipesController < ApplicationController

  def index
  @recipes = Recipe.all
  end

  def new
    @recipes = Recipe.new
  end

  def show
    @recipes = Recipe.first
  end
  
end