/** @jsx React.DOM */

var React = require('react')
var MainPanel = require('alacalc/recipes/main_panel_recipe')
var Input = require('react-bootstrap/Input')

module.exports = New_Recipe = React.createClass({
  getInitialState: function() {
    return {  data: [],
              visible: true,
              recipe_name: ''
    };
  },
  handleRecipeSubmit: function() {
    var recipe_hash = {
        recipe:{
              name: this.state.recipe_name,
              encrypted_notes: "It is not sweeddts",
              quantity_per_serving: 3,
              weight_loss:2
              }
    }
    $.ajax({
      url: '/api/v1/recipes',
      type: "POST",
      dataType: "json",
      data: recipe_hash,
      success: function(data) {
        console.log("success in a page");
      }.bind(this),
      error: function(xhr, status, err) {
        console.error("error in a page");
      }.bind(this)
    });
  },
  handleChange: function(event){
    this.setState({recipe_name: event.target.value });
  },
  handleMouseover: function(e) {
    alert("onMouseover")
    this.setState({visible: !this.state.visible });
  },
  render: function() {
    return (
      <div className="row">
        <div id="recipe-name">
          <Input id="recipe-input" type="text" name="recipe[name]" placeholder="Eneter your Recipe Name" defaultValue={this.props.recipe_name} onChange={this.handleChange} onBlur={ this.handleRecipeSubmit }/>
        </div><br/><br/>
        <div className="pull-left">
        <MainPanel/>
        </div>
      </div>  
    );
  }
});
