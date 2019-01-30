import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import * as ActionTypes from '../redux/actionTypes';

const mapStateToProps = state => {
  return {
    chainSize: state.chainSize
  };
}

const mapDispactchToProps = dispatch => {
  return {
    fetchChainSize: () => dispatch({type: ActionTypes.REQUEST_CHAIN_SIZE}) 
  };
}

export class ChainSize extends Component {

  componentDidMount() {
    this.props.fetchChainSize();
  }

  render() {
    if (this.props.chainSize.errMsg) { 
      return <p>{this.props.chainSize.errMsg}</p>; 
    }
    if (this.props.chainSize.isLoading) { 
      return <p>Loading...</p>; 
    }

    return (
      <p>The size of this chain is: {this.props.chainSize.chainSize} GiB</p>
    );
  }
}

export default connect(mapStateToProps, mapDispactchToProps)(ChainSize);

ChainSize.protoType = {
  chainSize: PropTypes.shape({
    isLoading: PropTypes.bool.isRequired,
    errMsg: PropTypes.string.isRequired,
    chainSize: PropTypes.string.isRequired
  }),
  fetchChainSize: PropTypes.func.isRequired
};