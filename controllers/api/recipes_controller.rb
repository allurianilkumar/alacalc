load "app/controllers/api/parser.rb"

module API
    class RecipesController < BaseController
        # Load cancan before filter
        load_and_authorize_resource

        def show
            respond_to do |format|
                format.json { render :json => @recipe }
            end
        end

        def parse
          old_user = User.current
          tmp_user = User.find_by_email("test_subscription@alacalc.com")
          User.current = tmp_user
          User.current.set_attr_encryption_key

          begin 
              # Parses a multiline string and find the closest ingredient, weight unit and amount in the database.
              recipe = Recipe.new
              recipe.name = "Instant recipe"
              recipe.ingredient_items = parse_multi_line_func(params[:string])

           ensure
              User.current.forget_attr_encryption_key
              User.current = old_user
           end

          respond_to do |format|
              format.json { render :json => recipe }
          end
        end

    end

end
