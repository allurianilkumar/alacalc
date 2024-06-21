/** @jsx React.DOM */

var React = require('react')

var IngredientRow = React.createClass({
  render: function() {
    return (
      <tr>
        <td><span className={'item-color ' + this.props.ingredient.data_source}/>{this.props.ingredient.Long_Desc}</td>
      </tr>
    );
  }
});

var IngredientTable = React.createClass({
  render: function() {
    var rows = [];
    this.props.ingredients.forEach(function(ingredient) {
      if (ingredient.Long_Desc.indexOf(this.props.filterText) === -1) 
        return;
      rows.push(<IngredientRow ingredient={ingredient} key={ingredient.Long_Desc} />);
    }.bind(this));
    return (
      <table>
        <tbody>{rows}</tbody>
      </table>
    );
  }
});

var SearchBar = React.createClass({
  handleChange: function() {
    this.props.onUserInput(this.refs.filterTextInput.getDOMNode().value);
  },
  render: function() {
    return (
      <div className="row">
        <form>
          <div>
            <input className="search-box" id="search" type="text" placeholder="Search for Ingredients" value={this.props.filterText} ref="filterTextInput" onChange={this.handleChange}/>
            <img className="search-icon"  src="/assets/search_icon.png" type="image"/>
          </div>
            <p>
              <h4>To add an ingredient to your recipe use the <br/> database search above </h4>
            </p>
        </form>
      </div>
    );
  }
});

module.exports = FilterableIngredientTable = React.createClass({
  getInitialState: function() {
    return {
      filterText: null
    };
  },
  handleUserInput: function(filterText, inStockOnly) {
    this.setState({filterText: filterText});
  },
  render: function() {
    return (
      <div className='search-items'>
        <div>
          <SearchBar filterText={this.state.filterText} onUserInput={this.handleUserInput} />
          <IngredientTable ingredients={this.props.ingredients} filterText={this.state.filterText} />
        </div>
      </div>
    );
  }
});
