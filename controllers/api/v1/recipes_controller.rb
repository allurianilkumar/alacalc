module API
  module V1
    class RecipesController < API::BaseController

       def index
         @recipes = Recipe.all
         render json: Alacalc::JsonApi::Recipes::CollectionWriter.new.write('recipes', @recipes, params)
       end

      def create
        @recipe = Recipe.new
        @recipe.name = Recipe.find(params[:name])
        render status: 201,json: Alacalc::JsonApi::Recipes::CollectionWriter.new.write('recipes', @recipe, params)
        rescue ActiveRecord::RecordInvalid => exception
        render status: 403, json: exception.record.errors
      end

      def show
      end
      
    end
  end 
end
