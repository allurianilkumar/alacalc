# encoding: utf-8
#
def uk_to_us(str)
  # Converts written out numbers to digits
  quant_map = {"chilli" => "chili",
               "yoghurt" => "yogurt",
               "yoghourt" => "yogurt",
  }
  # \b marks a word boundary
  quant_map.each{|k, v| str.sub!(/\b#{k}\b/, v)}


  # replace special characters
  spec_map = {"½" => " 1/2",
  }
  spec_map.each{|k, v| str.sub!(/#{k}/, v)}

  return str

end

def convert_numbers_to_digits(str)
  # Converts written out numbers to digits
  quant_map = {"one" => "1",
               "two" => "2",
               "three" => "3",
               "four" => "4",
               "five" => "5",
               "six" => "6",
               "seven" => "7",
               "eight" => "8",
               "nine" => "9",
               "ten" => "10",
               "eleven" => "11",
               "twelve" => "12",
               "thirteen" => "13",
               "fourteen" => "14",
               "½" => " 1/2",
               "¼" => " 1/4",
  }
  # \b marks a word boundary
  quant_map.each{|k, v| str.sub!(/\b#{k}\b/, v)}


  # replace special characters
  spec_map = {"¼" => " 1/4",
  }
  spec_map.each{|k, v| str.sub!(/#{k}/, v)}

  return str

end


def base_ingredients
    bi = {"rice" => {"NDB_No" => "20050", "data_source" => "usda_sr26"},
          "oil" => nil,
          "olive oil" => {"NDB_No" => "4053", "data_source" => "usda_sr26"},
          "vegetable oil" => {"NDB_No" => "4513", "data_source" => "usda_sr26"},
          "pork tenderloin" => {"NDB_No" => "10218", "data_source" => "usda_sr26"},
          "teriyaki sauce" => {"NDB_No" => "6112", "data_source" => "usda_sr26"},
          "lemon grass" => {"NDB_No" => "11927", "data_source" => "usda_sr26"},
          "lemongrass" => {"NDB_No" => "11972", "data_source" => "usda_sr26"},
          "lemon" => {"NDB_No" => "9152", "data_source" => "usda_sr26"},
          "root ginger" => {"NDB_No" => "11216", "data_source" => "usda_sr26"},
          "ginger root" => {"NDB_No" => "11216", "data_source" => "usda_sr26"},
          "soba noodles" => {"NDB_No" => "20114", "data_source" => "usda_sr26"},
          "green pepper" => {"NDB_No" => "11333", "data_source" => "usda_sr26"},
          "red pepper" => {"NDB_No" => "11821", "data_source" => "usda_sr26"},
          "bay leaves" => {"NDB_No" => "2004", "data_source" => "usda_sr26"},
          "bacon" => nil,
          "pasta" => nil,
          "cheese" => nil,
          "courgette" => {"NDB_No" => "11477", "data_source" => "usda_sr26"},
          "milk" => {"NDB_No" => "1078", "data_source" => "usda_sr26"},
          "tomato" => nil,
          "lamb" => nil,
          "egg" => {"NDB_No" => "1123", "data_source" => "usda_sr26"},
          "egg yolk" => {"NDB_No" => "1125", "data_source" => "usda_sr26"},
          "peas" => nil,
          "curry" => nil,
          "salt" => {"NDB_No" => "2047", "data_source" => "usda_sr26"}, 
          "juice" => nil, 
          "beans" => nil,
          "sweetcorn" => nil,
          "tomatoes" => nil,
          "chilli" => nil,
          "chili" => nil,
          "cardamom" => {"NDB_No" => "2006", "data_source" => "usda_sr26"},
          "cumin" => {"NDB_No" => "2014", "data_source" => "usda_sr26"},
          "red chilli" => {"NDB_No" => "11819", "data_source" => "usda_sr26"},
          "green chilli" => {"NDB_No" => "11670", "data_source" => "usda_sr26"},
          "red chili" => {"NDB_No" => "11819", "data_source" => "usda_sr26"},
          "green chili" => {"NDB_No" => "11670", "data_source" => "usda_sr26"},
          "mustard" => {"NDB_No" => "2046", "data_source" => "usda_sr26"},
          "coriander" => nil,
          "coriander seed" => {"NDB_No" => "2013", "data_source" => "usda_sr26"},
          "garlic" => {"NDB_No" => "11215", "data_source" => "usda_sr26"},
          "celery" => {"NDB_No" => "11143", "data_source" => "usda_sr26"},
          "sesame seed" => {"NDB_No" => "12023", "data_source" => "usda_sr26"},
          "fish" => nil,
          "sugar" => {"NDB_No" => "19335", "data_source" => "usda_sr26"},
          "mint" => {"NDB_No" => "2064", "data_source" => "usda_sr26"},
          "greek yoghurt" => {"NDB_No" => "1256", "data_source" => "usda_sr26"},
          "carrot" => {"NDB_No" => "11124", "data_source" => "usda_sr26"},
          "naan bread" => {"NDB_No" => "28307", "data_source" => "usda_sr26"},
          "flour" => {"NDB_No" => "20481", "data_source" => "usda_sr26"},
          "basil" => {"NDB_No" => "2044", "data_source" => "usda_sr26"},
          "bouillon" => {"NDB_No" => "6981", "data_source" => "usda_sr26"},
          "rosemary" => {"NDB_No" => "2063", "data_source" => "usda_sr26"},
          "thyme" => {"NDB_No" => "2049", "data_source" => "usda_sr26"},
          "cloves" => {"NDB_No" => "2011", "data_source" => "usda_sr26"},
          "paprika" => {"NDB_No" => "2028", "data_source" => "usda_sr26"},
          "chili powder" => {"NDB_No" => "2009", "data_source" => "usda_sr26"},
          "cinnamon" => nil,
          "ground cinnamon" => {"NDB_No" => "2010", "data_source" => "usda_sr26"},
          "yogurt" => {"NDB_No" => "1116", "data_source" => "usda_sr26"},
          "chives" => {"NDB_No" => "11156", "data_source" => "usda_sr26"},
          "jam" => {"NDB_No" => "19297", "data_source" => "usda_sr26"},
          "water" => {"NDB_No" => "14411", "data_source" => "usda_sr26"},
          "leek" => {"NDB_No" => "11246", "data_source" => "usda_sr26"},
          "light cream" => {"NDB_No" => "1052", "data_source" => "usda_sr26"},
          "double cream" => {"NDB_No" => "12-334", "data_source" => "cofids"},
          "chocolate" => {"NDB_No" => "17-089", "data_source" => "cofids"},
          "suet" => {"NDB_No" => "17-011", "data_source" => "cofids"},
          "vegetable suet" => {"NDB_No" => "17-012", "data_source" => "cofids"},
          "chicken" => {"NDB_No" => "5113", "data_source" => "usda_sr26"},
          "chicken stock" => {"NDB_No" => "6172", "data_source" => "usda_sr26"},
          "tarragon" => {"NDB_No" => "2041", "data_source" => "usda_sr26"},
          "pepper" => {"NDB_No" => "2030", "data_source" => "usda_sr26"},
          "peppercorns" => {"NDB_No" => "2030", "data_source" => "usda_sr26"},
          "cocoa powder" => {"NDB_No" => "14192", "data_source" => "usda_sr26"},
          "bicarbonate" => {"NDB_No" => "18372", "data_source" => "usda_sr26"},
          "parsley" => nil,
          "vanilla extract"  => {"NDB_No" => "2050", "data_source" => "usda_sr26"},
          "butter"  => {"NDB_No" => "1145", "data_source" => "usda_sr26"},
          "unsalted butter"  => {"NDB_No" => "1145", "data_source" => "usda_sr26"},
          "vinegar"  => {"NDB_No" => "17-339", "data_source" => "usda_sr26"},
          "wine vinegar"  => {"NDB_No" => "2068", "data_source" => "usda_sr26"},
          "balsamic vinegar"  => {"NDB_No" => "2069", "data_source" => "usda_sr26"},
          "strawberries"  => {"NDB_No" => "9316", "data_source" => "usda_sr26"},
          "blueberries"  => {"NDB_No" => "9050", "data_source" => "usda_sr26"},
          "potatoe"  => {"NDB_No" => "11352", "data_source" => "usda_sr26"},
          "sweet potatoe"  => {"NDB_No" => "11505", "data_source" => "usda_sr26"},
          "mushroom"  => {"NDB_No" => "11260", "data_source" => "usda_sr26"},
          "morel mushroom"  => {"NDB_No" => "11240", "data_source" => "usda_sr26"},
          "white wine"  => {"NDB_No" => "14106", "data_source" => "usda_sr26"},
          "sundried tomato"  => {"NDB_No" => "11955", "data_source" => "usda_sr26"},
          "flour" => {"NDB_No" => "20082", "data_source" => "usda_sr26"},
          "breadcrumbs" => {"NDB_No" => "18079", "data_source" => "usda_sr26"},
          "ground beef"  => {"NDB_No" => "13047", "data_source" => "usda_sr26"},
          "crackers"  => {"NDB_No" => "18235", "data_source" => "usda_sr26"},
          "ketchup"  => {"NDB_No" => "17-513", "data_source" => "cofids"},
          "steak sauce"  => {"NDB_No" => "27048", "data_source" => "usda_sr26"},
          "thyme leaves" => nil,
          "vinegar" => nil,
          "ginger" => nil,
          "soy sauce" => nil,
          "seasoning" => nil,
          "pork" => nil,
          "lime zest" => nil,
          "baking powder" => {"NDB_No" => "18369", "data_source" => "usda_sr26"},
          "lime juice" => nil,
          "spring onion" => {"NDB_No" => "11291", "data_source" => "usda_sr26"},
          "onion" => {"NDB_No" => "11282", "data_source" => "usda_sr26"}}

    # Sort list by number of words
    bi_names = bi.keys()
    bi_names = bi_names.sort_by { |i| -(i.split().length) }

    return [bi_names, bi]
end


def parse_ingredient_from_string_func(str, db_clean)
    # This function extracts the ingredient from a string containing the ingredient description. 
    # The result is an array containing the ingredient description and its properties ordered by importance.
    #
    # For example: 
    #
    #  "whole skinless, boneless chicken breasts"
    #  => 
    #   {
    #    "ingredient": ["chicken", "breast"],
    #    "properties": ["skinless", "boneless"]
    #   }


    ingredient = nil
    base_ingredient = nil
    properties = []

    base_ingredients = base_ingredients()[0]

    # Remove any remaining special characters
    str = str.gsub(/[^A-Za-z ]/, '')

    # Convert everything to small case
    str = str.downcase

    # Auxiliry words that change the ingredient, e.g. smoked samon  
    auxiliaries_1st = ["smoked", "dried", "powder"]

    # Auxiliary that does not change the ingredient type and should remain part of the search term 
    auxiliaries_2nd = ["chopped", "grated", "minced", "melted", "crushed", "drained", "rinsed", "tinned", "quartered", "small", "large", "fresh", "halved", "ground", "shredded", "salted", "plain"]
    auxiliaries_2nd += ["boneless"]

    # Auxiliary that does not change the ingredient type and can therefore be removed
    adjectives = ["finely", "coarsely"]

    # Filling words that can safely be removed
    filler_words = ["and", "to", "of", "or", "one", "two", "three", "four", "five", "six", "a"]
    filler_words.each do |w|
      str = str.gsub(/(^| )#{w}($| )/, ' ') 
    end

    # Detect the ingredient in the base ingredient list
    base_ingredients.each do |b|
      if str.include? b
        str = str.sub(b, '')
        # FIXME: Search for more than one base ingredient?
        base_ingredient = b
        break
      end
    end

    # FIXME: Detect the ingredient from the base ingredient

    # Detect the ingredient in the base ingredient list
    (auxiliaries_1st + auxiliaries_2nd).each do |a|
      if str.include? a
        # Check if there is an adjective in front of the property
        # e.g. finely crushed
        adjectives.each do |w|
          if str.include? w + " " + a
              a = w + " " + a
              break
          end
        end
        str = str.sub(a, '')
        properties << a
      end
    end

    if db_clean 
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
    end

    return ingredient, base_ingredient, properties
end

def parse_quantity_from_string_func(str, verbose)
    # This function breaks down a string containing the ingredient, amount and unit of an ingredient in a recipe into its components. 
    # For example: 
    # "1 onion, chopped" => Quantity: 1, Amount: nil, Ingredient "onion, chopped"
    # "450g tinned chilli beans" => Quantity: 450, Amount: "g", Ingredient: "tinned chilli beans"

    measures = ["ounces?", "cups?", "tbsp", "g", "kg", "mg", "cans?", "tins?", "packets?", "tsp", 
                "(?:tea|table|dessert)spoons?", "sprigs?", "ml", "bunch", "cloves?", 
                "inch", "m", "cm", "l", "liters", "sheets?", "slices?", "cloves?", "whole", "sticks?", 
                "fl oz", "pounds?", "pint", "pt", "pn", "pinch", "pods?"]
    measures_str = measures.join("|")

    # Detect the measure and quantity 
    str = str.strip 

    # Convert written numbers to digits
    str = convert_numbers_to_digits(str)

    # Convert fractions such as "5/4" or "2 1/2" or "1 1/4" to floats 
    newstr = nil
    while newstr != str
        newstr = str.sub %r{(\d*\s*\d+\s*\/\s*\d+)} do |match|
            int, nom, denom = str.scan(/(\d*)\s*(\d+)\s*\/\s*(\d+)/)[0]
            quant = " " + (int.to_f + nom.to_f / denom.to_f).to_s + " "
        end
        newstr, str = str, newstr
    end
    str = str.strip 

    rest = nil

    if rest.nil?
      # Handle the standard case where the unit comes straight after the quantity
      # "1.5 g of fish" or "10cans of butter" or "2 garlic cloves"
      quant, measure, rest = str.scan(/(\d+\.?\d*)\s*(#{measures_str})\s+(.*)/)[0]
    end

    if rest.nil?
      # Sometimes we get something like: 
      # "1.5 (340g) tins sweetcorn kernels, drained"
      quant, measure, rest = str.scan(/(\d+\.?\d*)\s*(#{measures_str})\W\s*(.*)/)[0] 
    end

    if rest.nil?
      # Sometimes there is a word in between the quantity and the unit, e.g.
      # "2 garlic cloves"
      # This is only expected for a subset of measures
      measures_sep = ["cans?", "tins?", "packets?", "sprigs?", "bunch", "cloves?", 
                      "sheets?", "slices?", "cloves?", "pods?"]
      measures_sep_str = measures_sep.join("|")
      quant, ingredient, measure, rest = str.scan(/(\d+\.?\d*)\b(.*)(#{measures_sep_str})\b(.*)/)[0]
      if not ingredient.nil?
          rest = ingredient + " " + rest.to_s
      end
    end

    if rest.nil?
      # Sometimes we do not have a measure, for example "1 onion, chopped" or "3 skinless, boneless chicken breasts"
      quant, rest = str.scan(/(^\d+\.?\d*)\s+(.*)/)[0]
    end

    if rest.nil?
      # And finally sometimes we have no quantity 
      # Sometimes we do not have a measure, for example "1 onion, chopped" or "3 skinless, boneless chicken breasts"
      measure, rest = str.scan(/(#{measures_str})\W\s*(.*)/)[0] 
      quant = 1
    end

    print "Extracting quantities from '" + str + "'..."
    if rest.nil? 
      print "nothing found. giving up\n"
      rest = str
    else
      print " found ", quant, " ", measure, "\n"
    end

    return quant, measure, rest

end

def get_db_ingredient_from_str(str, verbose)
    # Finds the db ingredient that best matches the string.

    ing, base_ing, properties = parse_ingredient_from_string_func(str, false)
    print "Getting db ingredient from '" + str + "'..."

  
    # If the base ingredient is associated with a db entry directly, then just use that
    # FIXME: Take properties into account
    bis = base_ingredients()[1]
    if bis.has_key?(base_ing) and not bis[base_ing].nil?
        conditions = bis[base_ing]
        ingredient = Ingredient.where(conditions).first

        if properties.length > 0
            print "found from precompiled list (ignoring properties): ", ingredient.Long_Desc
        else
            print "found from precompiled list: ", ingredient.Long_Desc
        end
        print "\n"

    # Otherwise we need to try and find the ingredient with a db query
    else
        query = base_ing

        for source in ["usda_sr26", "cofids"]
            ingredient = Ingredient.do_search([source],
                                                User.current,
                                                query,
                                                I18n.locale,
                                                page=1)[0]
            # reload the ingredient as do_search only returns minimal information
            if not ingredient.nil?
                ingredient = Ingredient.find ingredient.id
                break
            end
        end

        if verbose
            # Found the ingredient? Great, we can stop here!
            if not ingredient.nil?
              print "found from query search: ", ingredient.Long_Desc, "\n"
            else
              print "giving up :(\n"
            end
        end
    end

    return ingredient

end

def convert_unit(quant, from, to)
    if to == "ml"
        if from == "cup"
            return quant * 236.588237
        elsif from == "fl oz"
            return quant * 29.5735296
        elsif from == "tsp"
            return quant * 4.92892159
        elsif from == "tbsp"
            return quant * 14.7867648
        elsif from == "ml"
            return quant
        elsif from == "pt"
            return quant * 500 # Approximate imperial and liquid pint
        elsif from == "l"
            return 1000 * quant
        end

    elsif from == "ml"
        return 1.0/convert_unit(1, to, from) * quant

    else
        x = convert_unit(quant, from, "ml")
        y = convert_unit(x, "ml", to)
        return y
    end

end


def get_db_measure_from_str(ingredient, quant, measure)
    # Finds the measure 
    if ingredient.nil?
        return [nil, nil]
    end

    # Manually assembled weight list
    # Maps NDB_No, data_source to measure to alternative measure
    altweights = {["2004", "usda_sr26"] => {nil => [0.3, "g"]},
                  ["2049", "usda_sr26"] => {"sprigs" => [3, "g"],
                                            "sprig" => [3, "g"]},
                  ["2063", "usda_sr26"] => {"sprigs" => [3, "g"],
                                            "sprig" => [3, "g"]},
                  ["5113", "usda_sr26"] => {"whole" => [1, "chicken, bone and skin removed"],
                                            nil => [3, "g"]},
                  ["11670", "usda_sr26"] => {"whole" => [1, "pepper"],
                                            nil => [3, "pepper"]},
                  ["11819", "usda_sr26"] => {"whole" => [1, "pepper"],
                                            nil => [3, "pepper"]},
                  ["11143", "usda_sr26"] => {"sticks" => [1, 'strip (4" long)'],
                                            "stick" => [3, 'strip (4" long)']},
                  ["2041", "usda_sr26"] => {"bunch" => [1, 'oz']},
                  ["2006", "usda_sr26"] => {"pods" => [0.15, 'tsp, ground']},
                  ["12-334", "cofids"] => {"ml" => [1, 'g']},
                  ["12-334", "cofids"] => {"fl oz" => [29.57, 'g']},
                 }

    # Check if the weight was specified manually
    weights = altweights[[ingredient.NDB_No, ingredient.data_source]]
    if not weights.nil?
        conversion_fact, unit = weights[measure]
        if not conversion_fact.nil?
            unit = ingredient.weights.where(:msre_desc => unit).first
            return [quant.to_f*conversion_fact, unit]
        end
    end

    # Standardize unit measure names
    if ['tablespoon', 'table spoon', 'tablespoons', 'table spoons'].include? measure
        measure = 'tbsp'
    elsif ['teaspoon', 'tea spoon', 'teaspoons', 'tea spoons'].include? measure
        measure = 'tsp'
    elsif ['floz', 'fluid ounce', 'fluidounce'].include? measure
        measure = 'fl oz'
    elsif ['pounds', 'pounds'].include? measure
        measure = 'lb'
    elsif ['pint', 'pints'].include? measure
        measure = 'pt'
    elsif ['ounce', 'ounces'].include? measure
        measure = 'oz'
    elsif ['pinch', 'pinches' ].include? measure
        measure = 'pn'
    end

    # Check if a direct search yields works already
    unit = ingredient.weights.where(:msre_desc => measure).first
    if not unit.nil?
        return [quant.to_f, unit]
    end

    # Weight measures
    if measure == 'g'
        unit = ingredient.weights.where(:msre_desc => 'g').first
        return [quant.to_f, unit]
    elsif measure == 'kg'
        unit = ingredient.weights.where(:msre_desc => 'g').first
        quant = quant.to_f * 1000
        return [quant, unit]
    elsif measure == 'oz'
        unit = ingredient.weights.where(:msre_desc => 'g').first
        quant = quant.to_f * 28.3495231
        return [quant, unit]
    elsif measure == 'lb'
        unit = ingredient.weights.where(:msre_desc => 'g').first
        quant = quant.to_f * 453.59237
        return [quant, unit]
    elsif measure == 'pn'
        unit = ingredient.weights.where(:msre_desc => 'g').first
        quant = quant.to_f * 0.25
        return [quant, unit]
    end

    # Volume measures
    vol_unit = ingredient.weights.where("msre_desc LIKE 'cup%' or msre_desc LIKE 'tbsp%' or msre_desc LIKE 'tsp%' or msre_desc LIKE 'fl oz%' or msre_desc='ml' or msre_desc='l'").first
    if not vol_unit.nil? and ['cup', 'tsp', 'tbsp', 'ml', 'l', 'fl oz', 'pt'].include? measure 

        msre = vol_unit.msre_desc
        # Clean up msre description, e.g. "fl oz (equivalent XXg)" -> "fl oz"
        ['cup', 'tsp', 'tbsp', 'fl oz'].each do |m|
            msre = m if msre.include? m
        end

        # Convert volume unit
        quant = convert_unit(quant.to_f, measure, msre)
        return [quant, vol_unit]
    end

    # Counting measures
    count_unit = ingredient.weights.where("msre_desc LIKE 'medium%' or msre_desc LIKE 'piece%'").first
    if not count_unit.nil?
        return [quant, count_unit]
    end

    # Giving up
    return [quant, nil]

end

def parse_multi_line_func(str)
    # Creates an Recipe from the str with the closest matching ingredients and quantities

    ing_items = []
    str.split("\n").each do |line|
        ing_item = parse_single_line_func(line) 
        ing_items << ing_item if not ing_item.nil?
    end

    ing_items

end


def parse_single_line_func(str)
    # Creates an IngredientItem from the str with the closest matching ingredient and quantity

    puts "-------------------------------------------------------------------------------------------"
    if str.strip == ''
        puts "Ignoring empty line"
        return nil
    end

    verbose = true

    str = uk_to_us(str)

    quant, measure, rest = parse_quantity_from_string_func(str, verbose)
    ingredient = get_db_ingredient_from_str(rest, verbose)
    quantity, weight = get_db_measure_from_str(ingredient, quant, measure)


    if ingredient.nil? or weight.nil?
        if not ingredient.nil?
            puts ingredient.Long_Desc
            ingredient.weights.each do |w|
                puts w.msre_desc
            end
        end
        if verbose 
          puts "(!!) Opps, I dont know what to do with ", str
        end
        return nil
    else
      return IngredientItem.new :ingredient => ingredient, :quantity_unit => weight, :quantity => quantity
    end

end

