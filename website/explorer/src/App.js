import React, { Component } from 'react';
import Main from './components/MainComponent';
import { configureStore } from './redux/configureStore';
import { Provider } from 'react-redux';
import { BrowserRouter, Route } from 'react-router-dom';
import './App.css';

const store = configureStore();

class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <BrowserRouter>
          <div className="App">
            <Route path="/" component={Main} />
          </div>
        </BrowserRouter>
      </Provider>
    );
  }
}

export default App;
