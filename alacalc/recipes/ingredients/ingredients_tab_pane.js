/** @jsx React.DOM */

var React = require('react')
var IngredientInstance = require('alacalc/recipes/ingredients/ingredient_instance')
var AllItems = require('alacalc/recipes/ingredients/all_items')

var INGREDIENTS = [
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Fish Cakes,frozen,row', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'fish Fingers,code,frozen,row', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Lemon sole, steamed', data_source: 'cofids'},
  {category: 'US Standard', energy_value: '10 g', Long_Desc: 'Mango, unripe, raw', data_source: 'usda_sr26'},
  {category: 'My Recipe and Ingredients', energy_value: '10 g', Long_Desc: 'Dried mixed fruit', data_source: 'custom'},
  {category: 'UK Standard', energy_value: '10 g', Long_Desc: 'Cambridge Diet powder', data_source: 'cofids'}
];

module.exports = IngredientsTabPane = React.createClass({
  componentDidMount: function(){
    $('.tinymce').tinymce({
    height: 250,
    plugins: [
        "link"      
    ],
    menubar: false,
    statusbar: false,
    toolbar1: "bold italic underline | bullist numlist | outdent indent | link image"
    });
  },
  render: function(){
    return(
      <div className="row">
        <div className="col-md-6" id="my-ingredient-list">
          <div className="ingredients-box">
              <h3>Ingredients</h3>
              <div className="pull-right">
              <IngredientInstance/></div><hr id="hr_mode_up"/>
              <div className="modal-body">
                <AllItems allitems={INGREDIENTS}/>
                <hr id="hr_mode"/>
                <p>Weight before cooking</p>
                <p>Weight after cooking</p>
              </div>
              <br/>
          </div>
        </div>
        <div className="col-md-6" id="tinymce-id">
          <div className="tinymce-panel-note">
            <div className="tinymce-note">
             <h3>Notes</h3>
              <hr id="hr_mode_for_mce"/>
              <div id="page_content_dialog_form" title="Page Content">
                <textarea id="tinymce" className="tinymce">Enter text here</textarea>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
