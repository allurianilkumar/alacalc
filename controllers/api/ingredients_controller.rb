
module API
    class IngredientsController < BaseController
        # Load cancan before filter
        load_and_authorize_resource

        def index
            per_page = params[:per_page] || 15  # The number of results per pagination page
            page = params[:page] || 1  # The pagination page
            locale = params[:locale] || I18n.locale  # The translation language to be used

            # Mysql qyery
            select = :id, :updated_at
            @ingredients = Ingredient.select(select).paginate(:per_page => per_page, :page => page).includes(:translations).where :data_source => 'custom'

            respond_to do |format|
                format.json { render :json => @ingredients, :only => [:id, :Long_Desc, :updated_at] }
            end
        end

        def search
            query = params[:query] # The search query
            # The data sources.
            sources = params[:sources]
            sources = sources.split(',') if not sources.nil?
            per_page = params[:per_page] || 15  # The number of results per pagination page
            page = params[:page] || 1  # The pagination page
            locale = params[:locale] || I18n.locale  # The translation language to be used

            # List of IDs to be excluded
            if not params[:exclude_ids].nil? 
                exclude_ids = {:ids => params[:exclude_ids]} 
            else
                exclude_ids = {}  
            end

            # Perform the search
            @ingredients = Ingredient.do_search(sources, current_user, query, locale, page, per_page, exclude_ids) 

            respond_to do |format|
                format.json { render :json => @ingredients, :only => [:id, :Long_Desc, :data_source, :updated_at] }
            end
        end

        def parse_ingredient_from_string
            # This function extracts the ingredient from a string containing the ingredient description. 
            # The result is an array containing the ingredient description and its properties ordered by importance.
            #
            # For example: 
            #
            #  "whole skinless, boneless chicken breasts"
            #  => 
            #   {
            #    "ingredient": ["chicken", "breast"],
            #    "properties": ["whole", "skinless", "boneless"]
            #   }

            str = params[:string].downcase
            db_clean = params[:db_clean]

            ingredient, base_ingredient, properties = parse_ingredient_from_string_func(str, db_clean)
            
            respond_to do |format|
                format.json { render :json => {"ingredient" => ingredient, 
                                               "base_ingredient" => base_ingredient,
                                               "properties" => properties } }
            end

          end

          def parse_quantity_from_string
            # This function breaks down a string containing the ingredient, amount and unit of an ingredient in a recipe into its components. 
            # For example: 
            # "1 onion, chopped" => Quantity: 1, Amount: nil, Ingredient "onion, chopped"
            # "450g tinned chilli beans" => Quantity: 450, Amount: "g", Ingredient: "tinned chilli beans"

            str = params[:string]
            verbose = params[:verbose]

            quant, measure, rest = parse_quantity_from_string_func(str, verbose)

            respond_to do |format|
                format.json { render :json => {"quantity" => quant, 
                                               "measure" => measure,
                                               "residual" => rest } }
            end

          end


    end
end
