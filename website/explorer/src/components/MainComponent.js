import React, { Component } from 'react';
import PropTypes from 'prop-types';
import ChainSize from './ChainSizeComponent';

class Main extends Component {

  render() {
    return (
      <div>
        <ChainSize />
      </div>
    );
  }

}

export default Main;

Main.protoType = {
  ChainSize: PropTypes.element
}