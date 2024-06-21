/** @jsx React.DOM */

var React = require('react')
var Modal = require('react-bootstrap/Modal')
var AllItems = require('alacalc/recipes/ingredients/all_items')
var IngredientEngine = require('alacalc/recipes/ingredients/ingredient_engine')

var INGREDIENTS = [
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Fish Cakes,frozen,row', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'fish Fingers,code,frozen,row', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Lemon sole, steamed', data_source: 'cofids'},
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Mango, unripe, raw', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'Dried mixed fruit', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Cambridge Diet powder', data_source: 'cofids'}
];

module.exports = IngredientModal = React.createClass({
  render: function() {
    return this.transferPropsTo(
      <Modal title="Ingredients" >
        <div className="modal-body-recipes">
          <div className="col-md-6 col-md-push-1">
            <IngredientEngine/>
          </div>
          <div className="all-items">
            <div className="col-md-6 col-md-push-1">
            <AllItems allitems={INGREDIENTS}/>
            </div>
          </div>
        </div>
      </Modal>
    );
  }
});