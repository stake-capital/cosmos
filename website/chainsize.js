import React, { Component } from 'react';

const API = 'https://private-cc47d-cosmosexplorer.apiary-mock.com';
const CHAIN_SIZE = '/chain_size';

class Chainsize extends Component {

  constructor(props) {
    super(props);
    this.state = {
      chain_size: "",
      isLoading: false,
      error: null
    }
  }

  componentDidMount() {
    this.setState({ isLoading: true });

    fetch(API + CHAIN_SIZE)
      .then(response => {
        if (response.ok) {
          return response.json()
        } else {
          return new Error('Error while fetching...');
        }
      })
      .then(data => this.setState({ 
        chain_size: data.result.chain_size, 
        isLoading: false 
      }))
      .catch(error => this.setState({ error, isLoading: false }));
  }

  render() {
    if (this.state.error) { return <p>{this.state.error.message}</p>; }
    if (this.state.isLoading) { return <p>Loading...</p>; }

    return (
      <div>
        <p>The size of this chain is: {this.state.chain_size} GiB</p>
      </div>
    );
  }
}

export default Chainsize;