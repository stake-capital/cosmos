import * as ActionTypes from './actionTypes';

const API = 'https://private-cc47d-cosmosexplorer.apiary-mock.com';
const CHAIN_SIZE = '/chain_size';

export const fetchChainSize = () => (dispatch) => {
  dispatch(requestChainSize());
  
  fetch(API + CHAIN_SIZE)
    .then(response => {
      if (response.ok) {
        return response.json()
      } else {
        return new Error('Error while fetching...');
      }
    })
    .then(data => {
      if (data.error !== "") {
        return new Error(data.error)
      }
      else {
        dispatch(receiveChainSize(data.result.chain_size));
      }
    })
    .catch(error => dispatch(failedChainSize(error)));
}

export const requestChainSize = () => ({
  type: ActionTypes.REQUEST_CHAIN_SIZE,
  payload: null
});

export const receiveChainSize = (chainSize) => ({
  type: ActionTypes.RECEIVE_CHAIN_SIZE,
  payload: chainSize
});

export const failedChainSize = (err) => ({
  type: ActionTypes.FAILED_CHAIN_SIZE,
  payload: err
});