/** @jsx React.DOM */

var React = require('react')
var TabbedArea = require('react-bootstrap/TabbedArea')
var TabPane = require('react-bootstrap/TabPane')
var IngredientsTabPane = require('alacalc/recipes/ingredients/ingredients_tab_pane')

var INGREDIENTS = [
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Fish Cakes,frozen,row', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'fish Fingers,code,frozen,row', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Lemon sole, steamed', data_source: 'cofids'},
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Mango, unripe, raw', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'Dried mixed fruit', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Cambridge Diet powder', data_source: 'cofids'}
];


module.exports = TabbedAreaInstance = React.createClass({
  getInitialState: function() {
    return { data: [] };
  },
  componentDidMount: function() {
    $.ajax({
      url: "/api/v1/recipes.json",
      type: 'GET',
      dataType: "json",
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error("error in a page");
      }.bind(this)
    });
  },
  render: function(){
    return(
      <div className="Ingredients-tab">
        <div id="tab1" className="tabbedarea">
          <TabbedArea defaultActiveKey={1}>
              <TabPane id="tabpane1" key={1} tab="Ingredients">
                <div className="ingredients_tab_pane">
                  <IngredientsTabPane />
                </div>
              </TabPane>
              <TabPane id="tabpane2" key={2} tab="Nutrition">Nutrition</TabPane>
              <TabPane id="tabpane3" key={3} tab="Costings">Costings...</TabPane>
              <TabPane id="tabpane4" key={4} tab="Optimisation">Optimisation...</TabPane>
           </TabbedArea>
        </div>
      </div>
    );
  }
});
