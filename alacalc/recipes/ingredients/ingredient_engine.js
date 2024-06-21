/** @jsx React.DOM */

var React = require('react')
var FilterableIngredientTable = require('alacalc/recipes/ingredients/filterable_ingredient_table')

var INGREDIENTS = [
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Fish Cakes,frozen,row', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'fish Fingers,code,frozen,row', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Lemon sole, steamed', data_source: 'cofids'},
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Mango, unripe, raw', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'Dried mixed fruit', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Cambridge Diet powder', data_source: 'cofids'}
];

module.exports = IngredinetEngine = React.createClass({
  render: function() {
    return (
      <div className="fileter-search">
        <FilterableIngredientTable ingredients={INGREDIENTS} />
      </div>
    );
  }
});