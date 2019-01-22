import { combineReducers, createStore, applyMiddleware } from 'redux';
import { ChainSize } from './chainSizeReducer';
import thunk from 'redux-thunk';
import logger from 'redux-logger';

export const configureStore = () => {

  const combinedReducers = combineReducers({
    chainSize: ChainSize
  });

  const store = createStore(
    combinedReducers, 
    applyMiddleware(thunk, logger));

  return store;
};