/** @jsx React.DOM */
var React = require('react')
var Button = require('react-bootstrap/Button')
module.exports = Test = React.createClass({
  handleClick:function(){
    alert("Hai i Got a React js Button Click");
  },
  render: function() {
    console.log("testing now.")
    return (
      <div>
        <h1>hai how are u?</h1>
        <Button bsSize="large" active>Click</Button>
      </div>
      );
  }
});
