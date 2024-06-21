/** @jsx React.DOM */

var React = require('react')

var ItemClick = React.createClass({
  render: function() {
    return (
      <div className="item-click">
        <table>
        <td>
          <div className="glyphicon glyphicon-remove" onClick={this.props.onClick}/>&nbsp;&nbsp;
          <span className="energy-value">{this.props.title.energy_value}</span>&nbsp;&nbsp;
          <span className={'item-color ' + this.props.title.data_source}/>&nbsp;&nbsp;
          <span className="list-of-recips">{this.props.title.Long_Desc}</span>
        </td>
        </table>
      </div>
    );
  },
  //this component will be accessed by the parent through the `ref` attribute
  animate: function() {
    console.log('Pretend %s is animating', this.props.title);
  }
});

module.exports = AllItems = React.createClass({
  getInitialState: function() {
    return {allitems: this.props.allitems};
  },
  handleClick: function(index) {
    var items = 
    this.state.allitems.filter(function(item, i) {
      return index !== i;
    });
    this.setState({allitems: items});
  },
  render: function() {
    return (
      <div>
        {this.state.allitems.map(function(item, i) {
          return (
            <div>
              <ItemClick allitems={this.props.allitems} onClick={this.handleClick.bind(this, i)} key={i} title={item} ref={'item' + i} />
            </div>
          );
        }, this)}
      </div>
    );
  }
});