/** @jsx React.DOM */

var React = require('react')
var ModalTrigger = require('react-bootstrap/ModalTrigger')
var IngredientModal = require('alacalc/recipes/ingredients/ingredient_modal')

module.exports = IngredientInstance = React.createClass({
  render: function(){
    return(
      <ModalTrigger modal={<IngredientModal/>}>
      <div className="glyphicon glyphicon-plus"></div>
      </ModalTrigger>
    );
  }
});