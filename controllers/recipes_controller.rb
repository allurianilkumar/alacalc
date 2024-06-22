# encoding: utf-8

class RecipesController < ApplicationController
  include ActionView::Helpers::NumberHelper
  # Load cancan before filter
  load_and_authorize_resource

  def instant
    render :layout => false
  end

  def optimize
    # TODO: add correct behaviour for when recipe is unpaid AND user has no credits
  end

  def instant_parser
    desc = params["recipe"]
    # Break into newlines
    desc = desc.split(/\n/).reject(&:empty?)

    @ingredients = []
    desc.each do |line| 
      line = clean(line)
      quant, measure, rest = detect_quantity(line, verbose=false)
      if not rest.nil?
        ingredient = find_db_ingredients(rest, verbose=false)
      end

      print line.strip().ljust(60)
      print "=> "
      print "Quantity: ", quant.to_s.ljust(6), "Amount: ", (measure.nil? ? "None" : measure).ljust(10), "Ingredient: ", rest, "\n"
      print "=> ".rjust(63)
      print "Ingredient break down: ", (rest.nil? ? "None" : break_down_ingredient(rest)), "\n"
      print "=> ".rjust(63)
      print "Db ingredient: ", (ingredient.nil? ? "None" : ingredient.Long_Desc + " (" + ingredient.data_source + ")") + "\n\n"
      if not ingredient.nil?
        @ingredients << ingredient
      end
    end

    respond_to do |format|
        format.json 
    end
  end

  # GET /recipes
  def index
    @new_name = t('recipes.default_recipe_name').titleize
    @recipes = Recipe.of_user(current_user).search(params[:search]).order('updated_at desc')

    # Even if retry_scale tries to avoid nil results as much as it can, it sometimes still happens; so lets compactify the result to be 100% sure
    @recipes.delete_if {|x| x == nil}

    # Load tags
    @tags = Recipe.of_user(current_user).tag_counts_on(:tags, :order => "count desc")

    @user_recipes = Recipe.of_user(current_user).limit(1)
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json
    end
  end

  def list
    @recipes = Recipe.of_user(current_user).search(params[:search]).order('updated_at desc')
    if params[:only] == 'paid'
      @recipes =  @recipes.where('recipes.paid IS NOT NULL')
    elsif params[:only] == 'unpaid'
      @recipes =  @recipes.where(:paid => nil)
    end
    if params[:tag]
      @recipes = @recipes.tagged_with(params[:tag])
    end
    @recipes.delete_if {|x| x == nil}
    @user_recipes = Recipe.of_user(current_user).limit(1)
    render :layout => false
  end

  def sub_menu
  end

  # GET /recipes/all
  def all
    @recipes = Recipe.order('updated_at desc').paginate(:per_page => 50, :page => params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /recipes/1/public
  def show_public
    secret = params["key"]
    @access_granted = ((not @recipe.publication_secret.nil?) and (@recipe.publication_secret == secret))

    if @access_granted 
      # !!!!!!!!!!!! This is a dangerous !!!!!!!!!!!!! 
      # We allow the user with the access granted to 
      # pretend to be the user of the recipe of the rest of this function 
      old_user = User.current
      User.current = @recipe.user
      User.current.set_attr_encryption_key

      begin
        @ingredients, @ingredient_items, @quantity_units = _vars_for_ingredient_items_json(@recipe)

        # Render the page before the user idendity is forgotten again.
        respond_to do |format|
          format.html
        end
      ensure
        User.current.forget_attr_encryption_key 
        User.current = old_user
      end

    end

  end

  # GET /recipes/1
  def show
    #@recipe.reload
    respond_to do |format|
      format.html { redirect_to nutrition_recipe_path(@recipe) }
    end
  end

  def _vars_for_ingredient_items_json(recipe)

    ingredient_items = recipe.ingredient_items
    # Compute the weight value for each ingredient
    (0..ingredient_items.size-1).each do |i|
      ingredient_items[i].compute_weight_in_grams
    end
    # Sort ingredients by grams
    ingredient_items.sort!

    # Fetch the ingredients in order 
    ids = ingredient_items.map{|ii| ii.ingredient_id}
    ingredients = Ingredient.find_in_order(ids)
    # Invoke the calculation of the nutritional information 
    ingredients.map{|i| i.calculate_nutritions_and_allergens_for_subrecipe}
    # Fetch the quantities in order 
    ids = ingredient_items.map{|ii| ii.quantity_unit_id}
    quantity_units = Weight.find_in_order(ids)

    return ingredients, ingredient_items, quantity_units

  end

  # GET /recipes/1/nutrition
  def nutrition
    @ingredients, @ingredient_items, @quantity_units = _vars_for_ingredient_items_json(@recipe)
    if not @recipe.paid?
      owner = @recipe.user
      owner.reload
      if (owner.subscription_end.nil? or owner.subscription_end < Date.today) and owner.credits <= 0
        redirect_to recipe_ingredient_items_path(@recipe), :notice => t('recipes.reasons.still_locked')
      else
        @recipe.pay_recipe
      end
    end
    current_user.reload
  end

  # GET /recipes/1
  def export_img
    @recipe = Recipe.find_by_id(params[:recipes])
    @recipe.reload
    @recipe.ingredient_items.reload

    @ingredient_items = @recipe.ingredient_items
    # Compute the weight value for each ingredient
    (0..@ingredient_items.size-1).each do |i|
      @ingredient_items[i].compute_weight_in_grams
    end
    # Sort ingredients by grams
    @ingredient_items.sort!


    # Fetch the ingredients in order
    ids = @ingredient_items.map{|ii| ii.ingredient_id}
    @ingredients = Ingredient.find_in_order(ids)
    # Fetch the quantities in order
    ids = @ingredient_items.map{|ii| ii.quantity_unit_id}
    @quantity_units = Weight.find_in_order(ids)
    @ingredients, @ingredient_items, @quantity_units = _vars_for_ingredient_items_json(@recipe)

    @design = params[:design]

    @kit = IMGKit.new(render_to_string(:layout => false, :action => "#{self.action_name}.html.erb"), :width => params[:width], :'javascript-delay' => 500)
    @kit.stylesheets << "#{Rails.root.to_s}/public/stylesheets/recipe_graphics.css"
    @kit.stylesheets << "#{Rails.root.to_s}/public/stylesheets/bootstrap.css"
    respond_to do |format|
      format.jpg {send_data(@kit.to_jpg, :type => 'image/jpeg', :filename => @recipe.name.parameterize + '-' + @design + '-' + Date.today.to_s(:db) + '.jpg')}
      #format.jpg {send_data(@kit.to_jpg, :type => 'image/jpeg', :filename => 'recipe.jpg')}
      format.html { render :layout => false }
      format.png {send_data(@kit.to_png, :type => 'image/png', :filename => @recipe.name.parameterize + '-' + @design + '-' + Date.today.to_s(:db) + '.png')}
    end
  end

  # GET /recipes/1/versions
  def versions
    @versions = @recipe.versions
    respond_to do |format|
      format.html
    end
  end


  # Helper function for export 
  def generate_pdf(html, css_files, filename)
    # Prepare html content for PDFKit
    def translate_paths(body, env)
      # Change relative paths to absolute, code taken from PDFKit::Middleware
      root = PDFKit.configuration.root_url || "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/"
      body.gsub(/(href|src)=(['"])\/([^\"']*|[^"']*)['"]/, '\1=\2' + root + '\3\2')
    end
    html = translate_paths(html, env)

    # Generate PDF
    kit = PDFKit.new(html, :page_size => 'A4')
    css_files.each do |css|
      kit.stylesheets << "#{Rails.root}/public/stylesheets/" + css + ".css"
    end
    kit.to_file(filename)
  end


  # Helper function for export 
  def merge_pdfs(input_files, output_file)
    options = "-q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite"
    system "gs #{options} -sOutputFile=#{output_file} " + input_files.join(" ")
  end

  # GET /recipes/1/export
  def export
    respond_to do |format|
      format.html { # The browser sends a html request, but we want to render the PDF

        require 'tempfile'
        pdffiles = Array.new()

        recipe_ids = params[:recipes].split(',')
        recipe_ids.each do |id|

          @recipe = Recipe.find_by_id(id)
          @ingredients, @ingredient_items, @quantity_units = _vars_for_ingredient_items_json(@recipe)
          current_user.reload

          # Generate the html content
          if @recipe.paid? and @recipe.user == current_user
            html = render_to_string :layout => 'pdf'

          # Cancan does not check URL parameters, so we need to check manually of the user 
          # may view the recipe
          elsif @recipe.user != current_user  
            html = render_to_string :layout => 'pdf', :message => t('recipes.reasons.wrong_user')
            
          elsif @recipe.paid? == false
            html = render_to_string :message => t('recipes.reasons.still_locked'), :layout => 'pdf'
          end

          # Specify the css files to be loaded, taken from export.html.haml
          css_files = ['recipe', 'recipe_graphics', 'pdf_master', 'pdf_' + params[:set]]

          pdffiles << Tempfile.new('alacalc_recipe.pdf')
          pdffiles.last.close
          generate_pdf(html, css_files, pdffiles.last.path)
        end
        
        # Concatonate the PDFs
        output = Tempfile.new('alacalc_recipe.pdf')
        output.close
        merge_pdfs(pdffiles.map{|f| f.path}, output.path)

        # Read the output data and send it off. Note, we do not use send_file 
        # here because we want to delete the file in a second again.
        #send_file output.path, :filename => "alacalc_recipes.pdf", :type => 'application/pdf'
        send_data output.open.read, :type => "application/pdf"

        # Delete temporary files
        pdffiles.each do |file|
          file.unlink
        end
        output.unlink
      }

      format.xls {

        @recipes = {}

        if params[:recipes]
          params[:recipes].split(',').each do |id|
            recipe = Recipe.find_by_id(id)
            @recipes[id] = recipe
            
            # Cancan does not check URL parameters, so we need to check manually of the user 
            # may view the recipe
            if recipe.paid? and recipe.user == current_user
              @recipes[id][:display] = true
              recipe.ingredient_items = recipe.ingredient_items

              # Compute the weight value for each ingredient
              (0..recipe.ingredient_items.size-1).each do |i|
                recipe.ingredient_items[i].compute_weight_in_grams
              end

              recipe.notes = ActionView::Base.full_sanitizer.sanitize(recipe.notes)

              # Sort ingredients by grams
              recipe.ingredient_items.sort!
              @recipes[id][:items] = recipe.ingredient_items
              nutritional_values = recipe.nutritional_values

              @recipes[id][:nutrition] = nutritional_values
              @dv_values = recipe.dv_values(nutritional_values)

              @recipes[id][:dv] = @dv_values
              @gda_values = recipe.gda_values(nutritional_values)
              @traffic_light_colors = recipe.traffic_light_colors(nutritional_values)

              @recipes[id][:gda] = @gda_values

              @recipes[id][:traffic_light_colors] = @traffic_light_colors
              allergens = allergens_str(recipe.allergen_information)

              @recipes[id][:allergens] = allergens
              current_user.reload # The user credits might have changed, hence reload the user

            elsif recipe.user != current_user
              @recipes[id][:display] = false
              @recipes[id][:reason] = t('recipes.reasons.wrong_user')

            elsif recipe.paid? == false
              @recipes[id][:display] = false
              @recipes[id][:reason] = t('recipes.reasons.still_locked')

            end

          end
        end

        if params.include?("multi-export")
          send_data xls_export_multiple(@recipes), :type => :xls, :filename => 'alacalc_recipes.xls'

        else 
          recipe = @recipes.values.first
          send_data xls_export(recipe), :type => :xls, :filename => 'alacalc_' + recipe.name + '.xls'
        end
      }
    end
  end

  def xls_export_multiple(recipes)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet0 = book.create_worksheet :name => t('export.excel_sheet_name').capitalize 
    counter = 0
    row = sheet0.row(counter)
    xls_export_multiple_titles(row)
    counter += 1

    recipes.each do |r|
      row = sheet0.row(counter)
      xls_export_multiple_recipe(row, r[1])
      counter += 1
    end

    blob = StringIO.new('')
    book.write blob 
    return blob.string
  end

  def xls_export_multiple_titles(row)
    row.push t('recipes.name').capitalize 
    row.push t('recipes.notes').capitalize
    row.push t('export.created_at')

    row.push t('recipes.serving_size').capitalize

    # Ingredient list
    row.push t('recipes.ingredient_list').capitalize 

    # Allergen list
    row.push t('recipes.allergens').capitalize 

    # RIs % TODO: Wrap in loop using the sample recipe
    row.push "Calories RI: " + t('nutrients.gda.each_portion_contains')
    row.push "Calories RI: " + t('nutrients.gda.each_portion_contains') + ' (unit)'
    row.push "Calories RI: " + t('nutrients.gda.adults_daily_amount')
    row.push "Calories RI: " + t('nutrients.gda.adults_daily_amount')+ ' (unit)'
    row.push "Fat RI: " + t('nutrients.gda.each_portion_contains')
    row.push "Fat RI: " + t('nutrients.gda.each_portion_contains')+ ' (unit)'
    row.push "Fat RI: " + t('nutrients.gda.adults_daily_amount')
    row.push "Fat RI: " + t('nutrients.gda.adults_daily_amount')+ ' (unit)'
    row.push "Saturates RI: " + t('nutrients.gda.each_portion_contains')
    row.push "Saturates RI: " + t('nutrients.gda.each_portion_contains')+ ' (unit)'
    row.push "Saturates RI: " + t('nutrients.gda.adults_daily_amount')
    row.push "Saturates RI: " + t('nutrients.gda.adults_daily_amount')+ ' (unit)'
    row.push "Sugars RI: " + t('nutrients.gda.each_portion_contains')
    row.push "Sugars RI: " + t('nutrients.gda.each_portion_contains')+ ' (unit)'
    row.push "Sugars RI: " + t('nutrients.gda.adults_daily_amount')
    row.push "Sugars RI: " + t('nutrients.gda.adults_daily_amount')+ ' (unit)'
    row.push "Salt RI: " + t('nutrients.gda.each_portion_contains')
    row.push "Salt RI: " + t('nutrients.gda.each_portion_contains')+ ' (unit)'
    row.push "Salt RI: " + t('nutrients.gda.adults_daily_amount')
    row.push "Salt RI: " + t('nutrients.gda.adults_daily_amount')+ ' (unit)'

    # Traffic lights 
    Recipe.traffic_light_colors_hash.keys.each do |name|
      row.push "Traffic light color: " + t('recipes.traffic_light.' + name)
    end

    # All nutrients
    Ingredient.nutrients.each do |name|
      row.push t('nutrients.' + name.to_s) + " (per 100g)"
      row.push t('nutrients.' + name.to_s) + " (per 100g, unit)"
      row.push t('nutrients.' + name.to_s) + " (per serving)"
      row.push t('nutrients.' + name.to_s) + " (per serving, unit)"
    end

    # Extra columns
    row.push "Extra 1" 
    row.push "Extra 2" 
    row.push "Extra 3" 
    row.push "Extra 4" 
    row.push "Extra 5" 

  end

  def xls_export_multiple_recipe(row, recipe)
    row.push recipe.name
    if recipe[:display]
      row.push recipe.notes
    else
      row.push t('recipes.reasons.multi_export_not_calculated') + ' ' + recipe[:reason] 
      return
    end
    row.push recipe.created_at.to_s

    row.push recipe.quantity_per_serving.to_s + 'g'

    # Ingredient list
    ings = Array.new
    recipe.ingredient_items.each do |ingredient_item| 
      s = ingredient_item.ingredient.Long_Desc
      s += " ("
      if recipe.total_weight == 0
        s += '0' + t('nutrients.units.percent') 
      else 
        s += number_with_precision((ingredient_item.compute_weight_in_grams/recipe.total_weight*100), :precision => 1, :strip_insignificant_zeros => true).to_s + t('nutrients.units.percent') 
      end
      s += ")"
      ings.push s
      #ings.push (number_with_precision(ingredient_item.compute_weight_in_grams/recipe.total_weight*recipe.quantity_per_serving, :precision => 1, :strip_insignificant_zeros => true).to_s) + t('nutrients.units.g')
    end 
    row.push ings.join(", ") 

    # Allergen list
    row.push recipe[:allergens]

    # GDAs
    recipe[:gda].each do |gda, value| 
      if value['Value']['value'] == 0 or value['Value']['value'] == nil
        row.push t('nutrients.precision.nil') 
        row.push value['Value']['unit'] 
      elsif value['Value']['value'] < 0.05 
        row.push t('nutrients.precision.trace') 
        row.push '' 
      else 
        row.push number_with_precision(value['Value']['value'], :precision => configatron.gda_precision[gda], :strip_insignificant_zeros => true) 
        row.push value['Value']['unit'] 
      end
      row.push number_with_precision(value['Percentage']['value'], :precision => 0, :significant => true, :strip_insignificant_zeros => true) 
      row.push value['Percentage']['unit'] 
    end

    # Traffic lights 
    recipe[:traffic_light_colors].each do |name, color|
      if name == "Sugars" and color == "red" 
        row.push t('recipes.traffic_light.' + color[0]) + " (" + t("recipes.traffic_light_sugar_warning") + ")"
      else
        row.push t('recipes.traffic_light.' + color[0])
      end 
    end

    # Nutritional table
    Ingredient.nutrients.each do |n|
    #recipe[:nutrition].each do |name, nutritional_value|
      name = n.to_s
      nutritional_value = recipe[:nutrition][name]

      # Convert the Sodium value to mg
      if name == "Sodium" and nutritional_value["unit"] == "g"
        nutritional_value["unit"] = "mg"
        nutritional_value["value"] *= 1000
      end

      if 0.0 < nutritional_value["value"] and nutritional_value["value"] < 0.05 
        row.push t('nutrients.precision.trace')
        row.push ''  # No unit
      else 
        row.push number_with_precision(nutritional_value["value"], :precision => configatron.nutrient_precision[name], :strip_insignificant_zeros => true) 
        row.push t('nutrients.units.' + nutritional_value["unit"])
      end
      if 0.0 < nutritional_value["value"] and nutritional_value["value"]*recipe.quantity_per_serving.to_f/100.0 < 0.05 
        row.push t('nutrients.precision.trace') 
        row.push ''  # No unit
      else
        row.push number_with_precision(nutritional_value["value"]*recipe.quantity_per_serving.to_f/100.0, :precision => configatron.nutrient_precision[name], :strip_insignificant_zeros => true) 
        row.push t('nutrients.units.' + nutritional_value["unit"])
      end
    end
  end

#Simon can this be removed? It appears duplicate of line 609
  def allergens_str(allergens)
    result = ''

    if allergens.size() > 0
      # Find the index of the first and last gluten_from entry, as they have to be printed in brackets
      s = allergens.find_all {|a| a.to_s.starts_with?('gluten_from') }.first
      e = allergens.find_all {|a| a.to_s.starts_with?('gluten_from') }.last
      allergens.each do |a|
         if a != allergens.last and a != :gluten
           stopper = ', ' 
         else
           stopper = ' ' 
         end

         if a == s # If a is the first gluten source we need to add the words: "(from"
           stopper = ")"  + stopper if a == e # Add the closing bracket in the case that there is only one source of gluten
           result += " (#{ t('allergens.from') } #{ t('allergens.'+a.to_s) + stopper }"
         elsif a == e
           result += t('allergens.'+a.to_s) + ')' + stopper # close the bracket after the last gluten source
         else
           result += t('allergens.'+a.to_s) + stopper 
         end
       end
     else
       result += t('allergens.no_allergens')
     end
  end

  def xls_export(recipe)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet0 = book.create_worksheet :name => t('export.overview').capitalize 
    counter = 0
    row = sheet0.row(counter)
    row.push t('recipes.name').capitalize 
    row.push recipe.name 
    counter += 1
    row = sheet0.row(counter)
    row.push t('recipes.serving_size').capitalize
    row.push recipe.quantity_per_serving.to_s + 'g'
    counter += 1
    row = sheet0.row(counter)
    row.push t('recipes.notes').capitalize
    counter += 1
    row = sheet0.row(counter)
    row.push recipe.notes 
    counter += 1
    row = sheet0.row(counter)
    row.push t('export.created_at')
    row.push recipe.created_at.to_s
    counter += 1
    row = sheet0.row(counter)
    row.push t('export.pointer_to_sheets')

    # Ingredient list
    sheet1 = book.create_worksheet :name => t('recipes.ingredients').capitalize
    counter = 0
    row = sheet1.row(counter)
    row.push t('recipes.ingredient_list').capitalize 
    counter += 2
    row = sheet1.row(counter)
    row.push t('export.percentage_per_100g')
    row.push t('export.weight_per_100g')
    row.push t('recipes.name').capitalize
    recipe.ingredient_items.each do |ingredient_item| 
      counter += 1
      row = sheet1.row(counter)
      if recipe.total_weight == 0
        row.push '0' + t('nutrients.units.percent') 
      else 
        row.push number_with_precision((ingredient_item.compute_weight_in_grams/recipe.total_weight*100), :precision => 1, :strip_insignificant_zeros => true).to_s + t('nutrients.units.percent') 
      end
      row.push (number_with_precision(ingredient_item.compute_weight_in_grams/recipe.total_weight*recipe.quantity_per_serving, :precision => 1, :strip_insignificant_zeros => true).to_s) + t('nutrients.units.g')
      row.push ingredient_item.ingredient.Long_Desc
    end 

    # Allergen list
    sheet2 = book.create_worksheet :name => t('recipes.allergens').capitalize 
    counter = 0
    row = sheet2.row(counter)
    row.push t('recipes.allergens').capitalize 
    counter += 2
    row = sheet2.row(counter)
    row.push t('allergens.contains')
    row.push recipe[:allergens]
    counter += 2
    row = sheet2.row(counter)
    row.push t('allergens.guideline')

    # Reference intake
    sheet3 = book.create_worksheet :name => t('recipes.xls_export.ri')
    counter = 0
    row = sheet3.row(counter)
    row.push t('recipes.xls_export.ri') 
    counter += 2
    row = sheet3.row(counter)
    row.push t('nutrients.uk_2013.each') + t('nutrients.uk_2013.portion_contains')
    counter += 1
    @gda_values.each do |gda, value| 
      sheet3.row(counter).push gda
      if gda == 'Calories'
        @gda_values[gda]['Value']['unit'] = ''
      end 
      if @gda_values[gda]['Value']['value'] == 0 or @gda_values[gda]['Value']['value'] == nil
        sheet3.row(counter+1).push t('nutrients.precision.nil') + @gda_values[gda]['Value']['unit'] 
      elsif @gda_values[gda]['Value']['value'] < 0.05 
        sheet3.row(counter+1).push t('nutrients.precision.trace') 
      else 
        sheet3.row(counter+1).push number_with_precision(@gda_values[gda]['Value']['value'], :precision => configatron.gda_precision[gda], :strip_insignificant_zeros => true) + @gda_values[gda]['Value']['unit'] 
      end
      sheet3.row(counter+2).push number_with_precision(@gda_values[gda]['Percentage']['value'], :precision => 0, :significant => true, :strip_insignificant_zeros => true) + @gda_values[gda]['Percentage']['unit'] 
    end
    counter += 3
    row = sheet3.row(counter)
    row.push t('nutrients.uk_2013.adults_daily_amount') 

    # Nutritional table
    sheet4 = book.create_worksheet :name => t('recipes.typical').capitalize 
    counter = 0
    row = sheet4.row(counter)
    row.push t('recipes.typical').capitalize 
    counter += 2
    row = sheet4.row(counter)
    row.push t('recipes.name').capitalize 
    row.push t('recipes.per_100g')
    row.push t('nav.unit')
    row.push t('recipes.per') + ' ' + number_with_precision(recipe.quantity_per_serving, :precision => 0).to_s + t('nutrients.units.g') + " " + t('recipes.serving')
    row.push t('nav.unit')
    counter += 1
    recipe[:nutrition].each do |name, nutritional_value|
      row = sheet4.row(counter)
      counter += 1
      row.push t('nutrients.' + name)

      # Convert the Sodium value to mg
      if name == "Sodium" and nutritional_value["unit"] == "g"
        nutritional_value["unit"] = "mg"
        nutritional_value["value"] *= 1000
      end

      if 0.0 < nutritional_value["value"] and nutritional_value["value"] < 0.05 
        row.push t('nutrients.precision.trace')
        row.push t('nutrients.units.' + nutritional_value["unit"])
      else 
        row.push number_with_precision(nutritional_value["value"], :precision => configatron.nutrient_precision[name], :strip_insignificant_zeros => true)
        row.push t('nutrients.units.' + nutritional_value["unit"])
      end
      if 0.0 < nutritional_value["value"] and nutritional_value["value"]*recipe.quantity_per_serving.to_f/100.0 < 0.05 
        row.push t('nutrients.precision.trace')
        row.push t('nutrients.units.' + nutritional_value["unit"])
      else
        row.push number_with_precision(nutritional_value["value"]*recipe.quantity_per_serving.to_f/100.0, :precision => configatron.nutrient_precision[name], :strip_insignificant_zeros => true)
        row.push t('nutrients.units.' + nutritional_value["unit"])
      end
    end

    # Traffic lights 
    sheet5 = book.create_worksheet :name => t('recipes.traffic_lights').capitalize 
    counter = 0
    row = sheet5.row(counter)
    row.push t('recipes.traffic_lights').capitalize 
    counter += 2
    row = sheet5.row(counter)
    @traffic_light_colors.each do |name, color|
      row = sheet5.row(counter)
      counter += 1
      row.push t('recipes.traffic_light.' + name)
      row.push t('recipes.traffic_light.' + color[0])
    end
    if @traffic_light_colors["Sugars"][0] == "red" 
      row = sheet5.row(counter)
      counter += 1
      row.push t("recipes.traffic_light_sugar_warning") 
    end 

    #output to blob object
    blob = StringIO.new('')
    book.write blob 
    return blob.string
  end

  def allergens_str(allergens)
    result = ''

    if allergens.size() > 0
      # Find the index of the first and last gluten_from entry, as they have to be printed in brackets
      s = allergens.find_all {|a| a.to_s.starts_with?('gluten_from') }.first
      e = allergens.find_all {|a| a.to_s.starts_with?('gluten_from') }.last
      allergens.each do |a|
         if a != allergens.last and a != :gluten
           stopper = ', ' 
         else
           stopper = ' ' 
         end

         if a == s # If a is the first gluten source we need to add the words: "(from"
           stopper = ")"  + stopper if a == e # Add the closing bracket in the case that there is only one source of gluten
           result += " (#{ t('allergens.from') } #{ t('allergens.'+a.to_s) + stopper }"
         elsif a == e
           result += t('allergens.'+a.to_s) + ')' + stopper # close the bracket after the last gluten source
         else
           result += t('allergens.'+a.to_s) + stopper 
         end
       end
     else
       result += t('allergens.no_allergens')
     end

     return result
  end

  def friendly_filename(filename)
      # Replaces all characters other than basic letters and digits to '_'s
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s/, '_')
  end

  # GET /recipes/1/edit
  def edit
    @recipe.reload
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # POST /recipes/:ID/clone
  def clone
    @recipe_clone = @recipe.clone

    respond_to do |format|
      format.html { redirect_to recipe_ingredient_items_path(@recipe_clone, :ref => params[:ref]) }
      format.js
    end
  end

  # POST /recipes/clone_multiple
  def clone_multiple
    params[:recipes].split(',').each do |id|
      recipe = Recipe.find_by_id(id)
      recipe.clone
    end

    respond_to do |format|
      format.html { redirect_to recipes_path( :ref => params[:ref], :notice => 'Duplicated!' ) }
      format.js
    end
  end

  # POST /recipes
  def create
    @recipe = Recipe.new(params[:recipe])
    if Recipe.of_user(current_user).find_by_name(@recipe.name).present?
      @recipe.name = force_valid(@recipe.name)
    end

    @recipe.user = current_user
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to recipe_ingredient_items_path(@recipe, :ref => params[:ref]) }
        format.js
      else
        format.html { redirect_to(recipes_url, :notice => @recipe.errors.full_messages.join('. '))}
        format.xml  { render :xml => @recipe, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /recipes/1/create_public_secret
  def create_public_secret

    if @recipe.publication_secret.nil?
      @recipe.publication_secret = SecureRandom.hex(10)
      @recipe.save
    end

    respond_to do |format|
        format.html { redirect_to( recipe_path(@recipe) ) }
    end

  end

  # PUT /recipes/1
  def update
    @ingredients = []

    respond_to do |format|
      begin
        success = @recipe.update_attributes(params[:recipe])
        # Reload the recipe, otherwise some ingredients are not loaded correctly
        @recipe.reload

        @ingredient_items = @recipe.ingredient_items

        # Compute the weight value for each ingredient
        (0..@ingredient_items.size-1).each do |i|
          @ingredient_items[i].compute_weight_in_grams
        end

        # Sort ingredients by grams
        @ingredient_items.sort!

        if success
          format.html { redirect_to(recipe_ingredient_items_path(@recipe)) }
          format.js  { render 'ingredient_items/index.js.erb' }
        else
          format.html { render 'ingredient_items/index.html.erb' }
          format.xml { render :xml => @recipe.errors, :status => :unprocessable_entity }
          format.js { render 'ingredient_items/index.js.erb' }
        end

      rescue ActiveRecord::RecordNotFound
        @recipe.errors[:base] << "ActiveRecord::RecordNotFound exception: " + $!.to_s
        format.html { render 'ingredient_items/index.html.erb' }
        format.xml { render :xml => @recipe.errors, :status => :unprocessable_entity }
        format.js { render 'ingredient_items/index.js.erb' }
      end
    end
  end

  # PUT /recipes/1
  def update_basics

    respond_to do |format|
      begin
        if @recipe.update_attributes(params[:recipe])
          format.html { redirect_to( edit_recipe_path(@recipe) ) }
        else
          format.html { render 'edit.html.haml' }
          format.xml { render :xml => @recipe.errors, :status => :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotFound
        @recipe.errors[:base] << "ActiveRecord::RecordNotFound exception: " + $!.to_s
        format.html { render 'edit.html.haml' }
        format.xml { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end


  # PUT /recipes/1
  def update_adjustments
    respond_to do |format|
      if @recipe.update_attributes(params[:recipe])
        format.html { redirect_to( nutrition_recipe_path(@recipe) ) }
      else
        @ingredients, @ingredient_items, @quantity_units = _vars_for_ingredient_items_json(@recipe) 
        format.html { render :controller => :recipe, :action => :nutrition }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  def destroy

    respond_to do |format|
      if @recipe.destroy
        format.html { redirect_to recipes_url}
      else
        format.html { redirect_to(recipes_url, :notice => @recipe.errors.full_messages.join('. '))}
      end
    end
  end

  def destroy_multiple
    @errors = []
    (params[:recipes] || []).split(',').each do |recipe|
      @recipe = Recipe.find_by_id(recipe)
      if can? :destroy, @recipe
        if not @recipe.destroy
          @errors.push @recipe.name + ' - ' + @recipe.errors.full_messages.join('. ')
        end
      end
    end
    respond_to do |format|
      if @errors.empty?
        format.html { redirect_to(recipes_url)}
      else
        format.html { redirect_to(recipes_url, :notice => t('nav.errors') + '<br>' + @errors.join('<br>'))}
      end
    end

  end

  def unlock
    @recipe.unfreeze_recipe
    respond_to do |format|
      format.html { redirect_to(recipe_ingredient_items_path(@recipe)) }
    end
  end

  # PUT /recipes/uploadimage
  # PUT /recipes/uploadimage.json
  def uploadimage
    result = Hash.new

    result['status'] = true
    result['error_messages'] = []
    result['data'] = Hash.new

    if !params[:recipe_image][:recipe_id].nil?
      if RecipeImage.where(:recipe_id => 
          params[:recipe_image][:recipe_id]).length == 0
        @upload = RecipeImage.new(params[:recipe_image])
      else
        @upload = RecipeImage.where(:recipe_id => 
          params[:recipe_image][:recipe_id]).first
        @upload.update_attributes(params[:recipe_image])
      end

      if @upload.save
        result['data']['url'] = @upload.img.url(:medium)
      else
        result['status'] &= false
        @upload.errors.full_messages.each do |message|
          result['error_messages'].push(message)
        end
      end
    else
      result['status'] &= false
      result['error_messages'].push(t('recipes.images.invalid_params'))
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

  private

  def undo_link
    view_context.link_to(t('nav.undo'), revert_version_path(@recipe.versions.scoped.last), :method => :post)
  end

  def clean(str)
    # Clean the given string, for example converts or removes non-printable characters 
    str = str.gsub(/[⅕¼½¾]/, '⅕' => 0.2, '¼' => 0.25, '½' => 0.5, '¾' => 0.75)

    return str
  end

  def break_down_ingredient(str)
    # This function breaks down a string containing the ingredient description into its components. 
    # The result is an array containing the description of the ingredient from most important to least important.
    # For example: "whole skinless, boneless chicken breasts" => ["chicken", "breast", "whole", "skinless", "boneless"]

    base_ingredients = ["rice",
                        "oil",
                        "eggs",
                        "peas",
                        "curry",
                        "salt", 
                        "juice", 
                        "beans",
                        "sweetcorn",
                        "tomatoes",
                        "chillies",
                        "coriander",
                        "garlic",
                        "cinnamon",
                        "chicken",
                        "mushroom",
                        "pepper",
                        "parsley",
                        "butter",
                        "onion"]

    # Remove any remaining special characters
    str = str.gsub(/[^A-Za-z ]/, '')

    # Auxiliry words that change the ingredient, e.g. smoked samon  
    auxiliaries_1st = ["smoked", "dried", "powder"]

    # Auxiliary that does not change the ingredient type and should remain part of the search term 
    auxiliaries_2nd = ["chopped", "grated", "minced", "melted", "crushed", "drained", "rinsed"]

    # Auxiliary that does not change the ingredient type and can therefore be removed
    auxiliaries_3rd = ["finely", "quartered"]
    auxiliaries_3rd.each do |w|
      str = str.gsub(/(^| )#{w}($| )/, ' ') 
    end

    # Filling words that can safely be removed
    filler_words = ["and", "to", "of", "or", "one", "two", "three", "four", "five", "six", "a"]
    filler_words.each do |w|
      str = str.gsub(/(^| )#{w}($| )/, ' ') 
    end

    # Detect the ingredient in the base ingredient list
    base = nil
    base_ingredients.each do |b|
      if str.include? b
        str = str.sub(b, '')
        base = b
        break
      end
    end

    # Detect the ingredient in the base ingredient list
    aux = []
    auxiliaries_1st.each do |a|
      if str.include? a
        str = str.sub(a, '')
        aux << a
        break
      end
    end

    breakdown = (base.nil? ? str.split() : [base] + str.split()) + aux

    # Now we remove all words that do not occur in the database
    breakdown.each do |b|
      ingredient = Ingredient.do_search(sources=["usda_sr26", "cofids", "alacalc"],
                                        current_user=User.current,
                                        query="(%"+b+"%)",
                                        locale=I18n.locale,
                                        per_page=1,
                                        exclude_list={},
                                        strict_search=true)[0]
      if ingredient.nil?
        breakdown.delete(b)
      end
    end


    return breakdown
  end

  def detect_quantity(str, verbose=false)
    # This function breaks down a string containing the ingredient, amount and unit of an ingredient in a recipe into its components. 
    # For example: 
    # "1 onion, chopped" => Quantity: 1, Amount: nil, Ingredient "onion, chopped"
    # "450g tinned chilli beans" => Quantity: 450, Amount: "g", Ingredient: "tinned chilli beans"

    measures = ["tbsp", "g", "kg", "mg", "cans?", "tins?", "packets?", "tsp", "(?:tea|table|dessert)spoons?", "sprigs?", "ml", "bunch", "cloves?", "inch", "m", "cm", "l", "liters", "sheets?"]
    measures_str = measures.join("|")

    # Detect the measure and quantity 

    # Looking for a string of the form:
    # "1.5 g of fish" or "10cans of butter"
    quant, measure, rest = str.strip.scan(/(\d+\.?\d*)\s*(#{measures_str})\s+(.*)/)[0]

    if rest.nil?
      # Sometimes we get something like: 
      # "1 1/4 (340g) tins sweetcorn kernels, drained"
      quant, measure, rest = str.strip.scan(/(\d+\.?\d*)\s*(#{measures_str})\W\s*(.*)/)[0] 
    end

    if rest.nil?
      # Sometimes we do not have a measure, for example "1 onion, chopped" or "3 whole skinless, boneless chicken breasts"
      quant, rest = str.strip.scan(/(^\d+\.?\d*)\s+(.*)/)[0]
    end

    if rest.nil? 
      puts "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts "Opps, I dont know what to do with ", str
      print "Found ", quant, " ", measure, " of ", rest, "\n"
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
    else
      print str.strip().ljust(60)
      print "=> "
      print "Quantity: ", quant.to_s.ljust(6), "Amount: ", measure.to_s.ljust(10), "Ingredient ", rest, "\n"
    end

    return quant, measure, rest

  end

  def find_db_ingredients(str, verbose=false)
    # From a string describing the ingredient, find the closest ingredient in the database.

    str_cmp = break_down_ingredient(str)

    ingredient = nil
    str_cmp.length.downto(0).each do |i|
      query = str_cmp[0..i].join(" ")
  
      ingredient = Ingredient.do_search(["usda_sr26", "cofids", "alacalc"],
                                        User.current,
                                        query,
                                        I18n.locale,
                                        page=1)[0]

      if verbose
        print "Query db: '" + (query + "'").ljust(50) + " Result: " 
        if ingredient.nil?
          puts "None"
        else
          puts ingredient.Long_Desc 
        end

        # Found the ingredient? Great, we can stop here!
        if not ingredient.nil?
          puts ":) Found the ingredient I was looking for."
          break
        end
      end

    end

    if verbose and ingredient.nil?
        puts ":( Giving up"
    end

    return ingredient

  end

  def force_valid(name)
    (1..99).each do |i|
      if not Recipe.of_user(current_user).find_by_name(name + ' ' + i.to_s).present?
        name = name + ' ' + i.to_s
        return name
      end
    end
  end
end


