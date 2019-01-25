import { createStore, applyMiddleware, compose } from 'redux';
import createSagaMiddleware from 'redux-saga'
import { rootSaga } from './actionCreators'
import logger from 'redux-logger';
import { createBrowserHistory } from 'history';
import { routerMiddleware } from 'connected-react-router';
import { createRootReducer } from './rootReducer';

export const history = createBrowserHistory();

export const configureStore = () => {

  const sagaMiddleware = createSagaMiddleware();

  const store = createStore(
    createRootReducer(history), 
    compose(
      applyMiddleware(
        routerMiddleware(history),
        logger,
        sagaMiddleware )
    )
  );

  sagaMiddleware.run(rootSaga);

  return store;
};