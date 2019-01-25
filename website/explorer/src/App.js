import React, { Component } from 'react';
import Main from './components/MainComponent';
import { configureStore, history } from './redux/configureStore';
import { Provider } from 'react-redux';
import { Route } from 'react-router';
import { ConnectedRouter } from 'connected-react-router';
import './App.css';

const store = configureStore();

class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <ConnectedRouter history={history}>
          <div className="App">
            <Route path="/" component={Main} />
          </div>
        </ConnectedRouter>
      </Provider>
    );
  }
}

export default App;
